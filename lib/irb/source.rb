require 'ripper'

module IRB
  class Source
    attr_reader :buffer
    
    def initialize(buffer = [])
      @buffer = buffer
    end
    
    # Adds a source line to the buffer and flushes the cached reflection.
    def <<(source)
      @reflection = nil
      @buffer << source.chomp
    end
    
    # Returns the accumulated source as a string, joined by newlines.
    def source
      @buffer.join("\n")
    end
    
    # Reflects on the accumulated source and returns the current code block
    # indentation level.
    def level
      reflect.level
    end
    
    # Reflects on the accumulated source to see if it's a valid code block.
    def valid?
      reflect.valid?
    end
    
    # Returns a Reflector for the accumulated source and caches it.
    def reflect
      @reflection ||= Reflector.new(source)
    end
    
    class Reflector < Ripper::SexpBuilder
      def initialize(source)
        super
        @level = 0
        @valid = !parse.nil?
      end
      
      # Returns the code block indentation level.
      #
      #   Reflector.new("").level # => 0
      #   Reflector.new("class Foo").level # => 1
      #   Reflector.new("class Foo; def foo").level # => 2
      #   Reflector.new("class Foo; def foo; end").level # => 1
      #   Reflector.new("class Foo; def foo; end; end").level # => 0
      attr_reader :level
      
      # Returns whether or not the source is a valid code block, but does not
      # take syntax errors into account.
      #
      # For example, this is not a valid full code block:
      #
      #   def foo; p :ok
      #
      # This however is:
      #
      #   def foo; p :ok; end
      def valid?
        @valid
      end
      
      def on_kw(token) #:nodoc:
        case token
        when "class", "def"
          @level += 1
        when "end"
          @level -= 1
        end
        super
      end
    end
  end
end