require 'net/http'
require 'nokogiri'
require 'digest/sha1'
require 'fileutils'
require 'waz-blobs'

MAX_REDIRECTION ||= 10

#meths
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
    addr = url_obj.path
    addr = url_obj.request_uri if url_obj.respond_to?(:request_uri)
    req = Net::HTTP::Get.new(addr, {"User-Agent" => args[:user_agent]})
    res = Net::HTTP.start(url_obj.host, url_obj.port) {|http| http.request(req) }
    if (res.header["location"] != nil)
      find_url = res.header["location"]
      find_url = "http://#{url_obj.host}:#{url_obj.port}/#{find_url}" unless (find_url.start_with?("http://"))
    else
      body = res.body
      break
    end
    
    redirect_count = redirect_count + 1
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
  
  args[:user_agent] = "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3"
  
  args[:tmp_dir] = "/tmp" if args[:tmp_dir] == nil
  
  data = extract_modify_page(:url => args[:url])

  dir_loc = "/#{args[:tmp_dir]}/#{Digest::SHA1.hexdigest(data[:final_url])}"
  Dir.mkdir(dir_loc) unless File.exists?(dir_loc)

  page_url = URI.parse(data[:final_url])

  #grab all files into directory
  data[:files].keys.each do |key|
    begin
      url = data[:files][key]
      url.strip!
      real_url = url
      real_url = page_url + url if (page_url != nil && !(url.start_with?("http")))
      body = nil
      redirect_count = 0
      until (redirect_count > MAX_REDIRECTION || body != nil)
        url_obj = URI.parse(real_url)
        addr = url_obj.path
        addr = url_obj.request_uri if url_obj.respond_to?(:request_uri)
        req = Net::HTTP::Get.new(addr, {"User-Agent" => args[:user_agent]})
        res = Net::HTTP.start(url_obj.host, url_obj.port) {|http| http.request(req) }
        if (res.header["location"] != nil && res.header["location"].length > 0)
          real_url = res.header["location"]
          real_url = "http://#{url_obj.host}:#{url_obj.port}/#{real_url}" unless (real_url.start_with?("http://"))
        else
          body = res.body
          break
        end

        redirect_count = redirect_count + 1
      end
      
      if (body != nil)
        open("#{dir_loc}/#{key}", "wb") { |file|
          file.write(body)
         }
      end
    rescue Exception => e 
      puts "\tError fetching resource"
    end
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

pipeline "offlinecache", 10, do
  if (bin[:stub] != nil && (bin[:stub].offline_archive == nil || bin[:stub].offline_archive.empty?))
    WAZ::Storage::Base.establish_connection!(:account_name => "inperth", :access_key => "AsI7F8Z8s1XS0S03PnQPTstj7wSi7aOUoxAmpCXi1Ke8XQaU+w7pz1IZwyoPkLAJrCpa1ak0QSMVJHa2tFhNiw==")
    container = WAZ::Blobs::Container.find('offline-cache')
    
    arch = archive_mobile_page(:url => bin[:stub].uri)
    file = open(arch)
    
    #upload to Azure
    blob = container.store("#{bin[:stub]._id}.zip", file, 'application/zip')
  
    #remove archive
    FileUtils.rm_rf(arch)
  
    #store info
    bin[:stub].offline_archive = blob.url
    bin[:stub].save
    
  end
  
end