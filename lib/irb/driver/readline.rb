require 'readline'
require 'irb/driver/tty'
require 'irb/ext/history'
require 'irb/ext/completion'

module IRB
  module Driver
    class Readline < TTY
      def initialize(input = $stdin, output = $stdout)
        super
        ::Readline.input  = @input
        ::Readline.output = @output
      end
      
      def readline
        ::Readline.readline(context.prompt, true)
      end
    end
  end
end

IRB.driver = IRB::Driver::Readline.new