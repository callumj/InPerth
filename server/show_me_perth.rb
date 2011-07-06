require 'open-uri'
require 'cgi'

load "#{File.dirname(__FILE__)}/init.rb"

ROOT_URL = "http://www.showmeperth.com.au"

now = Time.now
begin_wk = now.beginning_of_week
end_wk = now.end_of_week

urls = []
urls << "http://www.showmeperth.com.au/events/search?page=0&start_date[value][year]=#{begin_wk.year.to_s}&start_date[value][month]=#{begin_wk.month.to_s}&start_date[value][day]=#{begin_wk.day.to_s}&end_date[value][year]=#{end_wk.year.to_s}&end_date[value][month]=#{end_wk.month.to_s}&end_date[value][day]=#{end_wk.day.to_s}"

#created a Show Me Perth provider if needed
provider = Provider.where(:title => "Show Me Perth").first
if provider == nil
  provider = Provider.new(:title => "Show Me Perth", :active => true, :uri => urls[0])
  provider.classifiers = ["event"]
  provider.pipelines = ["showmeperth"]
  provider.save
end

urls.each do |url|
  puts open(url)
  doc = Nokogiri::HTML(open(url))
  
  event_listings = doc.css("div.teaser-node")
  event_listings.each do |event_div|
    #get basic info
    title = CGI.unescapeHTML(event_div.xpath(".//h4/a").inner_html.strip)
    
    existing_entry = Stub.where(:title => title, :provider_id => provider.id).first

    if existing_entry == nil
      link = "#{ROOT_URL}#{event_div.xpath(".//a[@class = \"thumb-link\"]").attr("href")}"
    
      #build the date
      date = event_div.css("div.date").inner_text.strip.gsub(/Date:/,"").strip.gsub(/[-].*/,"").strip
      date_parts = date.split(/\s+/)
      day = date_parts[0].to_i
      month = date_parts[1]
      year = "20#{date_parts[2]}".to_i
      time_obj = Time.new(year,month,day)
    
      time_obj = Time.now if (time_obj <=> Time.now) == 1
    
      #grab the meta
      desc_div = event_div.xpath(".//div[@class = \"teaser\"]")
      desc_div.xpath(".//a").remove
      desc = desc_div.inner_text.strip.gsub(/^\W+/,"")
    
      tags = []
    
      terms = event_div.xpath(".//div[@class = \"item-list\"]/ul/li/a")
      terms.each do |term|
        clean = term.inner_html.strip
        clean.split(/[\/]/).each do |inner|
          tags << inner.gsub(/\W/,"")
        end
      end
    
      ins = Stub.new(:title => title, :uri => link, :description => desc, :tags => tags, :classifiers => provider.classifiers, :created_at => time_obj)
      ins.provider = provider
      ins.save
      puts "Saved #{title}"
    end
  end
  
  #see if there are any more pages
  next_page_a = doc.css("li.pager-next").xpath(".//a")
  if next_page_a != nil && next_page_a.length > 0
    urls << "#{ROOT_URL}#{CGI.unescapeHTML(next_page_a.attr("href").to_s)}"
  end
end