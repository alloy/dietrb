# require 'irb/driver/readline'
require 'irb/driver/tty'
require 'socket'

TOPLEVEL_OBJECT = self

module IRB
  module Driver
    class Socket
      # DEFAULTS = {
      #   :tty_exit_on_eof => false,
      #   :term => "\r\0"
      # }
      
      def initialize(host = '127.0.0.1', port = 7829)
        # @options = DEFAULTS.merge(options)
        @host, @port = host, port
        @server = TCPServer.new(host, port)
      end
      
      def run
        $stderr.puts "[!] Running IRB server on #{@host}:#{@port}"
        loop do
          connection = @server.accept
          # TODO libedit doesn't use the right input and output!!
          # IRB.driver = IRB::Driver::Readline.new(connection, connection)
          IRB.driver = IRB::Driver::TTY.new(connection, connection)
          context = IRB::Context.new(IRB.driver, TOPLEVEL_OBJECT, TOPLEVEL_BINDING.dup)
          IRB.driver.run(context)
          connection.close
        end
      end
    end
  end
end