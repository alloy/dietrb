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
      result = eval("_ = (#{source})", @binding)
      puts format_result(result)
      result
    rescue Exception => e
      puts format_exception(e)
    end
    
    def readline
      Readline.readline(prompt, true)
    end
    
    def run
      while line = readline
        continue = process_line(line)
        break unless continue
      end
    end
    
    # Returns whether or not the user wants to continue the current runloop.
    # This can only be done at a code block indentation level of 0.
    #
    # For instance, this will continue:
    #
    #   process_line("def foo") # => true
    #   process_line("quit") # => true
    #   process_line("end") # => true
    #
    # But at code block indentation level 0, `quit' means exit the runloop:
    #
    #   process_line("quit") # => false
    def process_line(line)
      @source << line
      return false if @source.to_s == "quit"
      
      if @source.valid?
        evaluate(@source)
        clear_buffer
      end
      @line += 1
      
      true
    end
    
    PROMPT = "irb(%s):%03d:%d> "
    
    def prompt
      PROMPT % [@object.inspect, @line, @source.level]
    end
    
    def format_result(result)
      "=> #{result.inspect}"
    end
    
    def format_exception(e)
      "#{e.class.name}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
    end
    
    private
    
    def clear_buffer
      @source = Source.new
    end
  end
end