# MacRuby implementation of IRB.
#
# This file is covered by the Ruby license. See COPYING for more details.
# 
# Copyright (C) 2009-2010, Eloy Duran <eloy.de.enige@gmail.com>

require 'irb/formatter'

module IRB
  class Context
    class << self
      def processors
        @processors ||= []
      end
    end
    
    attr_reader :object, :binding, :line, :source, :processors
    attr_accessor :driver, :formatter
    
    def initialize(object, explicit_binding = nil)
      @object  = object
      @binding = explicit_binding || object.instance_eval { binding }
      @line    = 1
      clear_buffer
      
      @underscore_assigner = __evaluate__("_ = nil; proc { |val| _ = val }")
      @processors = self.class.processors.map { |processor| processor.new(self) }
    end
    
    def __evaluate__(source, file = __FILE__, line = __LINE__)
      eval(source, @binding, file, line)
    end
    
    def evaluate(source)
      result = __evaluate__(source.to_s, '(irb)', @line - @source.buffer.size + 1)
      store_result(result)
      output.puts(formatter.result(result))
      result
    rescue Exception => e
      store_exception(e)
      output.puts(formatter.exception(e))
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
      # TODO spec
      @processors.each { |processor| line = processor.input(line) }
      
      @source << line
      return false if @source.terminate?
      
      if @source.syntax_error?
        output.puts(formatter.syntax_error(@line, @source.syntax_error))
        @source.pop
      elsif @source.code_block?
        evaluate(@source)
        clear_buffer
      end
      @line += 1
      
      true
    end
    
    def prompt
      formatter.prompt(self)
    end
    
    def input_line(line)
      output.puts(formatter.prompt(self) + line)
      process_line(line)
    end
    
    def output
      @driver || $stdout
    end
    
    def formatter
      @formatter ||= IRB.formatter
    end
    
    def clear_buffer
      @source = Source.new
    end
    
    def store_result(result)
      @underscore_assigner.call(result)
    end
    
    def store_exception(exception)
      $e = $EXCEPTION = exception
    end
  end
end