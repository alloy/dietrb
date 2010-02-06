#!/usr/bin/env macruby

require 'readline'
require 'ripper'

module IRB
  class << self
    def start
      Context.new.run
    end
  end
  
  class Context
    def initialize
      @line = 1
      @source = ""
    end
    
    def run
      while @source << gets
        exit if @source == "quit\n"
        if valid_code_block?
          eval
          @source = ""
        end
      end
    end
    
    def gets
      result = "#{Readline.readline(prompt, true)}\n"
      @line += 1
      result
    end
    
    def eval
      print_result(super(@source, TOPLEVEL_BINDING))
    rescue Object => e
      print_exception(e)
    end
    
    # we need to print the level, which means we need to do actual parsing
    #
    # eg:
    #
    #   irb(main):001:0> class A
    #   irb(main):002:1> def foo
    #   irb(main):003:2> p :ok
    #   irb(main):004:2> end
    #   irb(main):005:1> end
    def prompt
      "irb(main):00#{@line}:0> "
    end
    
    def print_result(output)
      puts "=> #{output.inspect}"
    end
    
    def print_exception(e)
      puts "#{e.class.name}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
    end
    
    def valid_code_block?
      !!Ripper::SexpBuilder.new(@source).parse
    end
  end
end

IRB.start