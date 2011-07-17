require 'cgi'
require 'net/http'

MAX_REDIRECTION = 10

pipeline "enjoyperth", 1 do
  #we can skip the RSS content as the RSS body is very limited
  #go straight to
  
  if (bin[:stub] != nil && bin[:stub].place == nil)
    san_content = ""

    puts "\tDelving into page to grab content"
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
    
    #get some better tags in the stub
    if (bin[:stopwords] != nil)
      actual_content = doc.css("div.description").inner_text
      all_words = []
      actual_content.strip.split(/\s+/).each do |word| 
        if word.strip.match(/^\w/) != nil
          word_clean = word.gsub(/\W/, "").downcase
          all_words << word_clean unless bin[:stopwords].include?(word_clean)
        end
      end
      high_score = 0
      data = {}
      all_words.each do |word|
        count = actual_content.strip.scan(/\s+#{word}\s+/).size
        high_score = count if count > high_score
        if data.key?(count)
          data[count] = data[count] << word unless data[count].include?(word)
        else
          data[count] = [word]
        end
      end
      keyword_ary =  keyword_array(data, high_score, 4)
      keyword_ary = keyword_ary[0, 5] if keyword_ary.size > 5
      
      bin[:stub].tags = keyword_ary
      bin[:stub].save
    end
    
    #do some place extraction
    where_con = doc.css("div.address")
    where_con.xpath(".//h3").remove
    pure_data = where_con.inner_text.strip
    
    san = pure_data.split(/\n/)
    if (san != nil && san.length >= 4)
      #this is the only way we can get place data
      place_name = san[0].strip
      #need to fix the dodge
      place_name.gsub!(/[,].*/i,"")
      place_name.gsub!(/[(].*[)]/i,"")
      place_name = place_name.strip
      address = san[2].strip
      suburb = san[3].strip
      suburb.gsub!(/,*\s*Western\s*Australia/i,"")
      suburb = suburb.strip
      
      
      #fetch lat/long
      gmap = doc.css("div#map")
      img = gmap.xpath(".//img")
      img_src = CGI::unescape(img.attr("src").to_s)
      lat_data = img_src.scan(/markers=.*(-3\d+[.]\d+),([-]?\d+[.]\d+)/)
      lat = nil
      long = nil
      if (lat_data != nil)
        lat = lat_data[0][0].to_f
        long = lat_data[0][1].to_f
      end
      
      existing_place = Place.where(:title => place_name, :suburb => suburb).first
      
      if (existing_place == nil)
        existing_place = Place.new
        existing_place.title = place_name
        existing_place.address = address
        existing_place.suburb = suburb
        
        existing_place.lat = lat
        existing_place.long = long
      end
      
      bin[:stub].tags.each {|tag| existing_place.tags << tag unless existing_place.tags.include?(tag)}
      existing_place.save
      
      puts "Writing #{existing_place.title}"
      
      bin[:stub].place = existing_place if bin[:stub].place == nil
      bin[:stub].save
    end
  end
end