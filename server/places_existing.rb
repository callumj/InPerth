#Grab places from exisiting stubs

load "#{File.dirname(__FILE__)}/init.rb"
Bundler.require(:default)

stop_words = get_stop_words("#{File.dirname(__FILE__)}/data/stopwords.txt")

all_stubs = Stub.all

all_stubs.each do |stub|
  puts "Handling #{stub.title}"
  Pipeline.process(stub.provider.pipelines, :stub => stub, :stopwords => stop_words)
end