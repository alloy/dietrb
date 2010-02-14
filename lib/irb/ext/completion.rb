require 'ripper'

module IRB
  class Completion
    # Returns an array of possible completion results, with the current
    # IRB::Context.
    #
    # This is meant to be used with Readline which takes a completion proc.
    def self.call(source)
      new(IRB::Context.current, source).results
    end
    
    attr_reader :context, :source
    
    def initialize(context, source)
      @context, @source = context, source
    end
    
    def evaluate(s)
      @context.__evaluate__(s)
    end
    
    def local_variables
      evaluate('local_variables').map(&:to_s)
    end
    
    def constants
      evaluate('self.class.constants').map(&:to_s)
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
      when :var_ref
        type = sub[1][0]
        name = sub[1][1]
        if type == :@ident && local_variables.include?(name)
          return evaluate(name).methods.map(&:to_s)
        elsif type == :@const && constants.include?(name)
          return evaluate(name).methods.map(&:to_s)
        elsif type == :@gvar && global_variables.include?(name.to_sym)
          return eval(name).methods.map(&:to_s)
        end
      when :top_const_ref
        type = sub[1][0]
        name = sub[1][1]
        if type == :@const && Object.constants.include?(name.to_sym)
          return evaluate("::#{name}").methods.map(&:to_s)
        end
      when :regexp_literal then Regexp
      when :array, :words_add, :qwords_add then Array
      when :lambda then Proc
      when :hash then Hash
      when :symbol_literal, :dyna_symbol then Symbol
      when :string_literal then String
      when :dot2, :dot3 then Range
      when :@int then Fixnum
      when :@float then Float
      when :unary
        # [:program, [:stmts_add, [:stmts_new], [:unary, :-@, [x, …]]]]
        #                                                      ^
        case sub[2][0]
        when :@int then Fixnum
        when :@float then Float
        end
      end
      
      klass.instance_methods.map(&:to_s) if klass
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