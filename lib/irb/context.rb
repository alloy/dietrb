require 'readline'

module IRB
  class Context
    attr_reader :object, :binding, :line, :source
    
    def initialize(object)
      @object  = object
      @binding = object.instance_eval { binding }
      @line    = 1
      clear_buffer
    end
    
    def evaluate(source)
      eval(source.to_s, @binding)
    end
    
    def readline
      Readline.readline(prompt, true)
    end
    
    def run
      while line = readline
        @source << line
        if @source.valid?
          evaluate(@source)
          clear_buffer
        end
      end
    end
    
    PROMPT = "irb(%s):%03d:%d> "
    
    def prompt
      PROMPT % [@object.inspect, @line, @source.level]
    end
    
    private
    
    def clear_buffer
      @source = Source.new
    end
  end
end