require 'ripper'

module IRB
  class Source
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
      !!Ripper::SexpBuilder.new(source).parse
    end
  end
end