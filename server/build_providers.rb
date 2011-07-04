load "#{File.dirname(__FILE__)}/init.rb"
Bundler.require(:crawl)

file = "#{File.dirname(__FILE__)}/data/blogs.txt"

File.readlines(file).each do |line|
  feed = FeedNormalizer::FeedNormalizer.parse open(line)
  
  new_provider = Provider.new
  new_provider.title = feed.title
  new_provider.uri = line.strip
  new_provider.type = "rss"
  new_provider.classifiers = ["food"]
  new_provider.pipelines = ["urbanspoon", "googlemaps"]
  new_provider.save
end