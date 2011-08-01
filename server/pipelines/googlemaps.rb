require "net/http"
require "uri"
require "json"

GOOGLE_API_KEY = "AIzaSyAZhGvwfAhLysave_1NXQAeozjrlDRBVd8"

pipeline "googlemaps", 10, do
  if (bin[:stub] != nil && bin[:stub].place != nil && bin[:stub].place.google_uri == nil)
    if (bin[:stub].place.lat != nil && bin[:stub].place.long != nil)
      #extend the listing based on Google data
      req_url = "https://maps.googleapis.com/maps/api/place/search/json?location=#{bin[:stub].place.lat},#{bin[:stub].place.long}&radius=1&sensor=true&key=#{GOOGLE_API_KEY}&name=#{CGI::escape(bin[:stub].place.title)}"
      
      uri = URI.parse(req_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      response = http.request(Net::HTTP::Get.new(uri.request_uri))
      
      if (response != nil && response.body != nil)
        #parse JSON
        rep_json = JSON.parse(response.body)
        if (rep_json != nil)
          rep_json["results"].each do |result|
            #check if we have the right one
            src_place_name = bin[:stub].place.title.gsub(/[^A-Za-z0-9 ]/,"").downcase
            target_place_name = result["name"].gsub(/[^A-Za-z0-9 ]/,"").downcase
            hit_count = 0
            word_count = 0
            src_place_name.split(/\s+/).each do |word|
              word_count = word_count + 1
              hit_count = hit_count + 1 if target_place_name.include?(word)
            end
            puts (hit_count.to_f / word_count.to_f)
            if ((hit_count.to_f / word_count.to_f) >= 0.7)
              #got a hit
              detail_url = "https://maps.googleapis.com/maps/api/place/details/json?reference=#{result["reference"]}&sensor=true&key=#{GOOGLE_API_KEY}"

              detail_uri = URI.parse(detail_url)
              detail_http = Net::HTTP.new(detail_uri.host, detail_uri.port)
              detail_http.use_ssl = true
              detail_http.verify_mode = OpenSSL::SSL::VERIFY_NONE
              detail_response = detail_http.request(Net::HTTP::Get.new(detail_uri.request_uri))
              
              if (detail_response != nil && detail_response.body != nil)
                #parse JSON
                detail_json = JSON.parse(detail_response.body)
                if (detail_json != nil && detail_json["result"] != nil)
                  #overwrite place details
                  place_obj = bin[:stub].place
                  place_obj.title = detail_json["result"]["name"]
                  place_obj.phone = detail_json["result"]["formatted_phone_number"] if detail_json["result"]["formatted_phone_number"] != nil
                  place_obj.google_uri = detail_json["result"]["url"]
                  place_obj.tags = [] if place_obj.tags == nil
                  if (detail_json["result"]["types"] != nil && detail_json["result"]["types"].length > 0)
                    detail_json["result"]["types"].each {|tag| place_obj.tags << tag unless place_obj.tags.include?(tag)}
                    place_obj.type = detail_json["result"]["types"][0]
                  end
                  address = ""
                  detail_json["result"]["address_components"].each do |part|
                    address = "#{part["long_name"]} #{address}" if part["types"].include?("street_number")
                    address = "#{address} #{part["long_name"]}" if part["types"].include?("route")
                    place_obj.suburb = part["long_name"] if part["types"].include?("locality") && part["long_name"] != nil
                  end
                  address = address.gsub(/\s+/," ")
                  place_obj.address = address if address.length > 0
                  puts "Writing update for #{place_obj.title}"
                  place_obj.save
                end
              end
              break
            end
          end
        end
        
      end
    end
  else
  
    #Otherwise try to extract some Google Maps URI out of page
  end
end