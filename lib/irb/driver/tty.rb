module IRB
  class Context
    class << self
      # attr_accessor :current
      def current
        Thread.current[:context]
      end
      
      def current=(context)
        Thread.current[:context] = context
      end
      
      # TODO move into driver
      def make_current(context)
        before, self.current = self.current, context
        yield
      ensure
        self.current = before
      end
    end
  end
  
  class << self
    # attr_accessor :driver
    # def driver
    #   @driver ||= Driver::TTY.new
    # end
    
    def driver=(driver)
      Thread.current[:driver] = driver
    end
    
    def driver
      Thread.current[:driver]
    end
  end
  
  module Driver
    class TTY
      def initialize(input = $stdin, output = $stdout)
        @input  = input
        @output = output
        @running = false
      end
      
      def context
        Context.current
      end
      
      def readline
        @output.print(context.prompt)
        @input.gets
      end
      
      def consume
        readline
      rescue Interrupt
        context.clear_buffer
        ""
      end
      
      def run(context)
        with_io do
          Context.make_current(context) do
            while line = consume
              continue = context.process_line(line)
              break unless continue
            end
          end
        end
      end
      
      def puts(*args)
        @output.puts(*args)
      end
      
      def print(*args)
        @output.print(*args)
        @output.flush
      end
      
      def with_io
        if @input_before.nil?
          @input_before, @output_before = $stdin, $stdout
          $stdin, $stdout = @input, @output
        end
        yield
      ensure
        $stdin, $stdout = @input_before, @output_before
      end
    end
  end
end

IRB.driver = IRB::Driver::TTY.new

module Kernel
  # Creates a new IRB::Context with the given +object+ and runs it.
  def irb(object, binding = nil)
    IRB.driver.run(IRB::Context.new(IRB.driver, object, binding))
  end
  
  private :irb
end