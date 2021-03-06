load "#{File.dirname(__FILE__)}/init.rb"
Bundler.require(:default)

all_providers = Provider.where(:active => true, :type => "rss").all
stop_words = get_stop_words("#{File.dirname(__FILE__)}/data/stopwords.txt")

all_providers.each do |provider|  
  puts "Crawling #{provider.title}"
  
  feed = FeedNormalizer::FeedNormalizer.parse open(provider.uri)
  
  if (feed != nil)
    entries = feed.entries
    recent_date = provider.most_recent_date
  
    entries.each do |entry|
    
      existing_entry = Stub.where(:title => entry.title).first
    
      if existing_entry == nil && entry.date_published.to_i > recent_date.to_i
        #remove HTML
        doc = Nokogiri::HTML(entry.content)
        body = doc.xpath("//text()").remove.inner_text
      
        body = entry.content if (body.to_s.strip.length == 0)
      
        #extract keywords
        all_words = []
        body.split(/\s+/).each do |word| 
          if word.strip.match(/^\w/) != nil
            word_clean = word.gsub(/\W/, "").downcase
            all_words << word_clean unless stop_words.include?(word_clean)
          end
        end
        high_score = 0
        data = {}
        all_words.each do |word|
          count = body.scan(/\s+#{word}\s+/).size
          high_score = count if count > high_score
          if data.key?(count)
            data[count] = data[count] << word unless data[count].include?(word)
          else
            data[count] = [word]
          end
        end
        keyword_ary =  keyword_array(data, high_score, 4)
        keyword_ary = keyword_ary[0, 5] if keyword_ary.size > 5
    
        #model insert
        stub = Stub.new
        stub.provider = provider
        stub.classifiers = provider.classifiers
        stub.title = entry.title.strip
        stub.tags = keyword_ary
        stub.uri = entry.url
        stub.created_at = entry.date_published.in_time_zone
        if body.size > 200
          stub.description = body[0,200].strip
        else
          stub.description = body.strip
        end
    
        stub.save
        #puts stub.to_json
        
        #run pipelines
        Pipeline.process(provider.pipelines, :stub => stub, :rss_item => entry)
      end
    end
  end
end

puts "#{Time.now.to_s}: Processed providers."