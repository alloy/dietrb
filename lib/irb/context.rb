require 'irb/formatter'
require 'readline'

module IRB
  class Context
    class << self
      attr_accessor :current
      
      def make_current(context)
        before, @current = @current, context
        yield
      ensure
        @current = before
      end
    end
    
    attr_reader :object, :binding, :line, :source
    
    def initialize(object, explicit_binding = nil)
      @object  = object
      @binding = explicit_binding || object.instance_eval { binding }
      @line    = 1
      clear_buffer
    end
    
    def __evaluate__(source)
      eval(source, @binding)
    end
    
    def evaluate(source)
      result = __evaluate__("_ = (#{source})")
      puts formatter.result(result)
      result
    rescue Exception => e
      puts formatter.exception(e)
    end
    
    def readline
      Readline.readline(formatter.prompt(self), true)
    end
    
    def run
      self.class.make_current(self) do
        while line = readline
          continue = process_line(line)
          break unless continue
        end
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
      
      if @source.syntax_error?
        puts formatter.syntax_error(@line, @source.syntax_error)
        @source.pop
      elsif @source.code_block?
        evaluate(@source)
        clear_buffer
      end
      @line += 1
      
      true
    end
    
    private
    
    def formatter
      IRB.formatter
    end
    
    def clear_buffer
      @source = Source.new
    end
  end
end