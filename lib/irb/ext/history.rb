module IRB
  module History
    class << self
      attr_accessor :file, :max_entries_in_overview
      
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
      
      def history(number_of_entries = max_entries_in_overview)
        history_size = Readline::HISTORY.size
        start_index = 0
        
        if history_size <= number_of_entries
          end_index = history_size - 1
        else
          end_index = history_size - 1
          start_index = history_size - number_of_entries
        end
        
        start_index.upto(end_index) { |i| print_line(i) }
        nil
      end
      
      private
      
      def print_line(line_number, show_line_numbers = true)
        print "#{line_number}: " if show_line_numbers
        puts Readline::HISTORY[line_number]
      end
    end
  end
end

module Kernel
  def history(number_of_entries = IRB::History.max_entries_in_overview)
    IRB::History.history(number_of_entries)
  end
  
  alias_method :h, :history
end

IRB::Context.processors << IRB::History
IRB::History.file = File.expand_path("~/.irb_history")
IRB::History.max_entries_in_overview = 50