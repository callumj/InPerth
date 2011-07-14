#Grab places from exisiting stubs

load "#{File.dirname(__FILE__)}/init.rb"
Bundler.require(:default)

all_stubs = Stub.all

all_stubs.each do |stub|
  Pipeline.process(stub.provider.pipelines, :stub => stub)
end