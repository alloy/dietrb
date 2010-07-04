# for now use Readline by default
require 'irb/io/readline'

module IRB
  class << self
    attr_writer :io
    
    def io
      @io ||= IRB::IO::Readline.new
    end
  end
end