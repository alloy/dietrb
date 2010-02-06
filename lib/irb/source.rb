require 'ripper'

module IRB
  class Source
    class Reflector < Ripper::SexpBuilder
      def initialize(source)
        super
        @level = 0
      end
      
      def level
        parse
        @level
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
    
    def <<(source)
      @buffer << source.chomp
    end
    
    def source
      @buffer.join("\n")
    end
    
    def level
      Reflector.new(source).level
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
      !!Reflector.new(source).parse
    end
  end
end