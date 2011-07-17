class Pipeline
  @@instance = nil
  attr_accessor :processors
  
  def initialize
    @processors = {}
  end
  
  def process(types, pass_ins = {})
    #build what pipelines have to be called
    types = [types] if types.class != Array
    norm_types = []
    types.each {|type| norm_types << type.to_sym if processors[type.to_sym] != nil}
    types = norm_types
    
    #standardise the passin params
    pass_ins = pass_ins.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    
    #sort what pipeliness need to run first
    types.sort! do |first,second|
      processors[first][:priority] <=> processors[second][:priority]
    end
    
    previous_results = {}
    
    #call each block
    types.each do |sym|
      begin
        puts "+Starting #{sym.to_s}"
        inst = BlockWrapper.new
        inst.bin = Hash.new.merge(pass_ins)
        inst.bin[:previous] = previous_results
        inst.instance_eval(&@processors[sym][:block])
        previous_results[sym] = inst.result
      rescue Exception => e  
        puts "Failing executing #{sym.to_s} pipeline. #{e.message}"
      end
    end
  end
  
  ##Static 'easy' methods
  
  def Pipeline.instance
    @@instance
  end
  
  #Dirty access
  def Pipeline.p
    @@instance = Pipeline.new if Pipeline.instance == nil
    Pipeline.instance
  end
  
  #Mirror function
  def Pipeline.process(types, pass_ins = {})
    Pipeline.p.process(types, pass_ins)
  end
end

class BlockWrapper
  attr_accessor :bin
  attr_accessor :result
end

#Exposure method for building pipelines from files
def pipeline(name, priority, &block)
  Pipeline.p.processors[name.to_sym] = {:priority => priority, :block => block}
end