require 'net/http'
load "#{File.dirname(__FILE__)}/init.rb"

conversion_guide  = {
  :sun => /.*sun.*/i,
  :cloudy => /.*cloudy.*/i,
  :clouds => /.*cloud.*/i,
  :rain => [/.*showers.*/i,/.*rain.*/i]
}

weather_results = {}

for type in conversion_guide.keys do
  obj = conversion_guide[type]
  conversion_guide[type] = [obj] unless obj.class == Array
end

URL = "http://www.google.com.au/ig/api?weather=Perth,WA"
parse_url = URI.parse(URL)
req = Net::HTTP::Get.new(parse_url.request_uri)
res = Net::HTTP.start(parse_url.host, parse_url.port) {|http| http.request(req) }

doc = Nokogiri::HTML(res.body)
current_weather = doc.xpath("//xml_api_reply/weather/current_conditions")

#process current weather
type = current_weather.xpath(".//condition").attr("data").to_s
temp = current_weather.xpath(".//temp_c").attr("data").to_s

actual_type = :sun

for simple_type in conversion_guide.keys do
  for regex in conversion_guide[simple_type] do
    if regex.match(type) != nil
      actual_type = simple_type
      break
    end
  end
  weather_results[:day0] = {:type => actual_type, :temp => temp}
end

#look at 3 day forcast
future_weather = doc.xpath("//xml_api_reply/weather/forecast_conditions")

day = 1
for day_weather in future_weather do
  day_type = day_weather.xpath(".//condition").attr("data")
  day_actual_type = :sun
  for simple_type in conversion_guide.keys do
    for regex in conversion_guide[simple_type] do
      if regex.match(day_type) != nil
        day_actual_type = simple_type
        break
      end
    end
  end
  
  temp_low_far = day_weather.xpath(".//low").attr("data").to_s
  temp_low_cel = (((5.0/9.0).to_f)*((temp_low_far.to_i-32).to_f)).round(1).to_s
  temp_high_far = day_weather.xpath(".//high").attr("data").to_s
  temp_high_cel = (((5.0/9.0).to_f)*((temp_high_far.to_i-32).to_f)).round(1).to_s
  
  weather_results["day#{day}".to_sym] = {:type => day_actual_type, :low_temp => temp_low_cel, :high_temp => temp_high_cel}
  day = day + 1
end

x = Meta.new(:name => "weather", :meta => weather_results)
x.save