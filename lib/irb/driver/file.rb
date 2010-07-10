require 'irb/driver/tty'

module IRB
  module Driver
    class File
      def initialize(path)
        @path = path
      end
      
      def run(context)
        ::File.open(@path, 'r') do |file|
          file.each_line { |line| context.input_line(line) }
        end
      end
    end
  end
end