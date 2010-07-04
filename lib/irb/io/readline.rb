require 'readline'

module IRB
  module IO
    class Readline
      def initialize(input = $stdin, output = $stdout)
        ::Readline.input  = @input  = input
        ::Readline.output = @output = output
      end
      
      def readline(prompt)
        ::Readline.readline(prompt, true)
      end
      
      def puts(*args)
        @output.puts(*args)
      end
    end
  end
end