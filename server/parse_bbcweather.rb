require 'net/http'
require 'cgi'
load "#{File.dirname(__FILE__)}/init.rb"

URL = "http://newsrss.bbc.co.uk/weather/forecast/92/ObservationsRSS.xml"
URL_NEXT = "http://newsrss.bbc.co.uk/weather/forecast/92/Next3DaysRSS.xml"

conversion_guide  = {
  :sun => /.*sun.*/i,
  :clouds => /.*cloud.*/i,
  :rain => [/.*shower.*/i,/.*rain.*/i]
}

weather_results = {}

for type in conversion_guide.keys do
  obj = conversion_guide[type]
  conversion_guide[type] = [obj] unless obj.class == Array
end

parse_url = URI.parse(URL)
req = Net::HTTP::Get.new(parse_url.request_uri)
res = Net::HTTP.start(parse_url.host, parse_url.port) {|http| http.request(req) }

doc = Nokogiri::HTML(res.body)

current_weather = doc.xpath("//channel/item")

#regex the type
type = current_weather.xpath(".//title").inner_text
actual_type = :sun

for simple_type in conversion_guide.keys do
  for regex in conversion_guide[simple_type] do
    if regex.match(type) != nil
      actual_type = simple_type
      break
    end
  end
end

#regex the temp
temp_container = CGI.unescape(current_weather.xpath(".//description").inner_text).strip
temp_container.gsub!(/[^A-Za-z0-9_,\s:]/,"")
temp_extract = temp_container.match(/^Temperature: ([0-9]+)C/)
if (temp_extract.length >= 1)
  weather_results[:day0] = {:type => actual_type, :temp => temp_extract[1]}
end


#fetch next 3 days
parse_url = URI.parse(URL_NEXT)
req = Net::HTTP::Get.new(parse_url.request_uri)
res = Net::HTTP.start(parse_url.host, parse_url.port) {|http| http.request(req) }

doc = Nokogiri::HTML(res.body)
all_items = doc.xpath("//channel/item")

day = 1
all_items.each do |item|
  
  #regex the type
  type = item.xpath(".//title").inner_text
  day_actual_type = :sun

  for simple_type in conversion_guide.keys do
    for regex in conversion_guide[simple_type] do
      if regex.match(type) != nil
        day_actual_type = simple_type
        break
      end
    end
  end
  
  #parse min and max
  
  temp_container = CGI.unescape(item.xpath(".//description").inner_text).strip
  temp_container.gsub!(/[^A-Za-z0-9_,\s:]/,"")
  temp_extract = temp_container.scan(/\s*Temp:\s*([0-9]+)C\s*/)
  if (temp_extract != nil && temp_extract.length >= 2)
    temp_extract.sort! 
    weather_results["day#{day}".to_sym] = {:type => day_actual_type, :low_temp => temp_extract[0][0], :high_temp => temp_extract[1][0]}
  end
  
  
  day = day + 1
end

x = Meta.where(:name => "weather").first
x = Meta.new(:name => "weather") if x == nil
x.meta = weather_results
x.save