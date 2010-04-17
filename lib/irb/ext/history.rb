module IRB
  module History
    class << self
      attr_accessor :file
      
      def init
        unless @initialized
          @initialized = true
          to_a.each do |source|
            Readline::HISTORY.push(source)
          end
        end
      end
      
      def input(source)
        File.open(@file, "a") { |f| f.puts(source) }
      end
      
      def to_a
        File.read(@file).split("\n")
      end
    end
  end
end

IRB::History.file = File.expand_path("~/.irb_history")