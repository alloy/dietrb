require 'ripper'

module IRB
  class Source
    class Reflector < Ripper::SexpBuilder
      attr_reader :level
      
      def initialize(source)
        super
        @level = 0
        @valid = !parse.nil?
      end
      
      def valid?
        @valid
      end
      
      def on_kw(token)
        case token
        when "class", "def"
          @level += 1
        when "end"
          @level -= 1
        end
        super
      end
    end
    
    attr_reader :buffer
    
    def initialize(buffer = [])
      @buffer = buffer
    end
    
    # Adds a source line to the buffer and flushes the cached reflection.
    def <<(source)
      @reflection = nil
      @buffer << source.chomp
    end
    
    def source
      @buffer.join("\n")
    end
    
    def level
      reflect.level
    end
    
    # This does not take syntax errors in account, but only whether or not the
    # accumulated source up till now is a valid code block.
    #
    # For example, this is not a valid full code block:
    #
    #   def foo; p :ok
    #
    # This however is:
    #
    #   def foo; p :ok; end
    def valid?
      reflect.valid?
    end
    
    def reflect
      @reflection ||= Reflector.new(source)
    end
  end
end