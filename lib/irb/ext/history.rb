module IRB
  module History
    class << self
      attr_accessor :file
      
      def new
        to_a.each do |source|
          Readline::HISTORY.push(source)
        end if Readline::HISTORY.to_a.empty?
        self
      end
      
      def input(source)
        File.open(@file, "a") { |f| f.puts(source) }
        source
      end
      
      def to_a
        File.read(@file).split("\n")
      end
    end
  end
end

IRB::Context.processors << IRB::History
IRB::History.file = File.expand_path("~/.irb_history")