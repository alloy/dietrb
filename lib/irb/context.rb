module IRB
  class Context
    attr_reader :object, :binding
    
    def initialize(object)
      @object = object
      @binding = object.instance_eval { binding }
    end
    
    def evaluate(source)
      eval(source.to_s, @binding)
    end
  end
end