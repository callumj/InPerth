require 'net/http'
require 'nokogiri'
require 'digest/sha1'
require 'fileutils'
require 'waz-blobs'

load "#{File.dirname(__FILE__)}/init.rb"

MAX_REDIRECTION = 10
def extract_modify_page(args = {})
  return nil unless args[:url] != nil
  args[:user_agent] = "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3"
  
  file_stor = {}
  
  #download initial web page
  body = nil
  find_url = args[:url]
  redirect_count = 0
  until (redirect_count > MAX_REDIRECTION || body != nil)
    url_obj = URI.parse(find_url)
    req = Net::HTTP::Get.new(url_obj.request_uri, {"User-Agent" => args[:user_agent]})
    res = Net::HTTP.start(url_obj.host, url_obj.port) {|http| http.request(req) }
    if (res.header["location"] != nil)
      find_url = res.header["location"]
    else
      body = res.body
      break
    end
    
    redirect_count
  end
  doc = Nokogiri::HTML(body)
  
  css = doc.xpath("//link[@rel=\"stylesheet\"]")
  css.each do |sheet|
    addr = sheet.attr("href")
    track = "#{Digest::SHA1.hexdigest(addr)}.css"
    sheet.set_attribute("href",track)
    file_stor[track] = addr
  end
  
  images = doc.xpath("//img")
  images.each do |img|
    addr = img.attr("src")
    track = "#{Digest::SHA1.hexdigest(addr)}#{File.extname(addr)}"
    img.set_attribute("src",track)
    file_stor[track] = addr
  end
  
  #sum stoopid scripts want you enable javascript if it can't find the js, just remove all js
  doc.xpath("//script").remove
  
  return {:doc => doc, :files => file_stor, :final_url => find_url}
end

def archive_mobile_page(args={})
  return nil unless args[:url] != nil
  
  args[:tmp_dir] = "/tmp" if args[:tmp_dir] == nil
  
  data = extract_modify_page(:url => args[:url])

  dir_loc = "/#{args[:tmp_dir]}/#{Digest::SHA1.hexdigest(data[:final_url])}"
  Dir.mkdir(dir_loc) unless File.exists?(dir_loc)

  page_url = URI.parse(data[:final_url])

  #grab all files into directory
  data[:files].keys.each do |key|
    url = data[:files][key]
    url.strip!
    real_url = page_url + url
  
    Net::HTTP.start(real_url.host) { |http|
      req = Net::HTTP::Get.new(real_url.request_uri, {"User-Agent" => "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3"})
      res = Net::HTTP.start(real_url.host, real_url.port) {|http| http.request(req) }
      open("#{dir_loc}/#{key}", "wb") { |file|
        file.write(res.body)
       }
    }
  end

  #write the actual page
  open("#{dir_loc}/#{Digest::SHA1.hexdigest(data[:final_url])}.html", "wb") { |file|
    file.write(data[:doc].to_s)
   }
 
  #perform compression
  final = system("zip -r #{args[:tmp_dir]}/#{Digest::SHA1.hexdigest(data[:final_url])}.zip #{dir_loc}")

  #cleanup
  FileUtils.rm_rf(dir_loc) if (final)
  
  "#{args[:tmp_dir]}/#{Digest::SHA1.hexdigest(data[:final_url])}.zip"
end

stubs_waiting = Stub.where(:offline_archive => nil).sort(:created_at.desc).limit(10).all

WAZ::Storage::Base.establish_connection!(:account_name => "inperth", :access_key => "YPmmxkq+NWoVLuqFRm+Lbqx4vw/Vcg45o5h9UnkJXoeUedBqCzj9fnzDyKepQ7k6lOnDH3mvLUWdk702kthZpA==")
container = WAZ::Blobs::Container.create('offline-cache')

stubs_waiting.each do |stub|
  puts "#{stub.title}"
  
  arch = archive_mobile_page(:url => stub.uri)
  
  #read it
  file = File.open(arch)
  raw = file.gets
  
  #upload to Azure
  blob = container.store("#{stub._id}.zip", raw, 'application/zip',)
  
  #remove archive
  FileUtils.rm_rf(arch)
  
  #store info
  stub.info = offline_archive.path
  stub.save
end
