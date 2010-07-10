module IRB
  class << self
    attr_accessor :driver_class
    
    def driver=(driver)
      Thread.current[:irb_driver] = driver
    end
    
    def driver
      current_thread = Thread.current
      current_thread[:irb_driver] ||= begin
        driver = nil
        if group = current_thread.group
          group.list.each do |thread|
            break if driver = thread[:irb_driver]
          end
        end
        driver || driver_class.new
      end
    end
  end
  
  module Driver
    class OutputRedirector
      # The output object for the current thread.
      def self.target=(output)
        Thread.current[:irb_stdout_target] = output
      end
      
      # TODO cache, or not to cache?
      def self.target
        current_thread = Thread.current
        if target = current_thread[:irb_stdout_target]
        elsif group = current_thread.group
          group.list.each do |thread|
            break if target = thread[:irb_stdout_target]
          end
        end
        target || $stderr
      end
      
      # A standard output object has only one mandatory method: write.
      # It returns the number of characters written
      def write(object)
        string = object.respond_to?(:to_str) ? object : object.to_s
        send_to_target :write, string
        string.length
      end
      
      # if puts is not there, Ruby will automatically use the write
      # method when calling Kernel#puts, but defining it has 2 advantages:
      # - if puts is not defined, you cannot of course use $stdout.puts directly
      # - (objc) when Ruby emulates puts, it calls write twice
      #   (once for the string and once for the carriage return)
      #   but here we send the calls to another thread so it's nice
      #   to be able to save up one (slow) interthread call
      def puts(*args)
        send_to_target :puts, *args
        nil
      end
      
      # Override this if for your situation you need to dispatch from a thread
      # in a special manner.
      #
      # TODO: for macruby send to main thread
      def send_to_target(method, *args)
        self.class.target.__send__(method, *args)
      end
    end
    
    class TTY
      attr_accessor :current_context
      
      def initialize(input = $stdin, output = $stdout)
        @input  = input
        @output = output
        OutputRedirector.target = output
        
        @thread_group = ThreadGroup.new
        @thread_group.add(Thread.current)
      end
      
      def readline(context)
        @output.print(context.prompt)
        @input.gets
      end
      
      # TODO make it take the current context instead of storing it
      def consume(context)
        readline(context)
      rescue Interrupt
        context.clear_buffer
        ""
      end
      
      def puts(*args)
        @output.puts(*args)
      end
      
      def print(*args)
        @output.print(*args)
        @output.flush
      end
      
      def run(context)
        ensure_output_redirector do
          context.driver = self
          while line = consume(context)
            continue = context.process_line(line)
            break unless continue
          end
        end
      end
      
      # Ensure that the standard output object is a OutputRedirector. If it's
      # already a OutputRedirector, do nothing.
      def ensure_output_redirector
        before = assign_output_redirector! unless $stdout.is_a?(IRB::Driver::OutputRedirector)
        yield
      ensure
        $stdout = before if before
      end
      
      def assign_output_redirector!
        before  = IRB::Driver::OutputRedirector.target = $stdout
        $stdout = IRB::Driver::OutputRedirector.new
        before
      end
    end
  end
end

IRB.driver_class = IRB::Driver::TTY

module Kernel
  # Creates a new IRB::Context with the given +object+ and runs it.
  def irb(object, binding = nil)
    # IRB.driver.run(IRB::Context.new(IRB.driver, object, binding))
    IRB.driver.run(IRB::Context.new(object, binding))
  end
  
  private :irb
end