require 'ripper'

module IRB
  class Completion
    def self.call(source)
      new(source).results
    end
    
    attr_reader :source
    
    def initialize(source)
      @source = source
    end
    
    def results
      src = @source
      
      # if ends with period, remove it to remove the syntax error it causes
      call = (src[-1,1] == '.')
      src = src[0..-2] if call
      
      # p src, call
      results = Ripper::SexpBuilder.new(src).parse
      # p @source, results
      
      # [:program, [:stmts_add, [:stmts_new], [x, …]]]
      #                                        ^
      sub = results[1][2]
      klass = case sub[0]
      when :regexp_literal then Regexp
      when :array, :words_add, :qwords_add then Array
      when :lambda then Proc
      when :hash then Hash
      when :symbol_literal, :dyna_symbol then Symbol
      when :string_literal then String
      when :dot2, :dot3 then Range
      when :@int then Fixnum
      when :@float then Float
      when :unary then
        # [:program, [:stmts_add, [:stmts_new], [:unary, :-@, [x, …]]]]
        #                                                      ^
        case sub[2][0]
        when :@int then Fixnum
        when :@float then Float
        end
      end
      
      klass.instance_methods.map(&:to_s)
    end
  end
end

if defined?(Readline)
  if Readline.respond_to?("basic_word_break_characters=")
    # IRB adds a few breaking chars. that would break literals for us:
    # * String: " and '
    # * Hash: = and >
    Readline.basic_word_break_characters= " \t\n`<;|&("
  end
  Readline.completion_proc = IRB::Completion
end