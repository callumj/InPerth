require 'cgi'
require 'net/http'

MAX_REDIRECTION = 10

pipeline "urbanspoon", 1, do
  if (bin[:stub] != nil)    
    urbanspoon_url = ""
    if (bin[:rss_item] != nil)
      san_content =CGI.unescape(bin[:rss_item].content)
    
      find = san_content.match(/(http:\/\/www.urbanspoon.com(\/[A-Za-z0-9_-]+)+)/)
    end
    
    if (find != nil && find.length >= 2)
      urbanspoon_url = find[1]
    else
      #need to grab urbanspoon url from the actual post page
      puts "\tDelving into page to grab urbanspoon link"
      find_url = bin[:stub].uri
      body = nil
      redirect_count = 0
      until (redirect_count > MAX_REDIRECTION || body != nil)
        url_obj = URI.parse(find_url)
        req = Net::HTTP::Get.new(url_obj.request_uri, {"User-Agent" =>
                "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.10) Gecko/20100915 Ubuntu/10.04 (lucid) Firefox/3.6.10"})
        res = Net::HTTP.start(url_obj.host, url_obj.port) {|http| http.request(req) }
        if (res.header["location"] != nil)
          find_url = res.header["location"]
          puts "\tFollowing redirection"
        else
          body = res.body
          break
        end
        
        redirect_count
      end
      doc = Nokogiri::HTML(body)

      body = doc.xpath("//body").to_s
      san_content =CGI.unescape(body)
      find = san_content.match(/(http:\/\/www.urbanspoon.com\/r(\/[A-Za-z0-9_-]+)+)/)
      
      if (find != nil && find.length >= 2)
        urbanspoon_url = find[1]
      end
    end
    
    #grab details about place
    if (urbanspoon_url.strip.length > 0)
    
      url_obj = URI.parse(urbanspoon_url)
      req = Net::HTTP::Get.new(url_obj.request_uri, {"User-Agent" =>
              "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.10) Gecko/20100915 Ubuntu/10.04 (lucid) Firefox/3.6.10"})
      res = Net::HTTP.start(url_obj.host, url_obj.port) {|http| http.request(req) }
      doc = Nokogiri::HTML(res.body)
          
      place_title = doc.css("h1.page-title").inner_text.strip
      phone_no = doc.css("span.phone").inner_text.strip
      street_address = doc.css("span.street-address").inner_text.strip
      suburb = doc.css("span.locality").inner_text.strip
      place_url_obj = doc.css("a.url")
      place_url = nil
      if place_url_obj != nil && !(place_url_obj.empty?)
        place_url = place_url_obj.attribute("href").to_s.strip
      end
    
      #get lat/long from Google Maps URL
      lat,long = 0.0
      gmaps_div = doc.css("div#rest-map-holder").to_s
      marks_find = gmaps_div.match(/markers=([-0-9.]+),([-0-9.]+)/)
      if (marks_find != nil && marks_find.length >= 3)
        lat = marks_find[1].to_f
        long = marks_find[2].to_f
      end
      
      entry = Place.where(:title => place_title, :suburb => suburb).first
      
      if (entry == nil)
        #create place meta
        entry = Place.new
        entry.urbanspoon_uri = urbanspoon_url
        entry.title = place_title
        entry.phone = phone_no
        entry.address = street_address
        entry.suburb = suburb
        entry.lat = lat
        entry.long = long
        entry.site_uri = place_url
        entry.type = "food"
        
        entry.save
      end
      
      #add content based meta data
      bin[:stub].tags.each {|tag| entry.tags << tag unless entry.tags.include?(tag)}
      entry.save
      puts "Writing #{entry.title}"
    
      bin[:stub].place = entry if bin[:stub].place == nil
      bin[:stub].save
    end
  end
end