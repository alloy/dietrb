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
    
    # TODO: test and or fix the fact that we need to get constants from the
    # singleton class.
    def constants
      evaluate('self.class.constants + (class << self; constants; end)').map(&:to_s)
    end
    
    def results
      src = @source
      
      # if ends with period, remove it to remove the syntax error it causes
      call = (src[-1,1] == '.')
      src = src[0..-2] if call
      
      # p src, call
      tree = Ripper::SexpBuilder.new(src).parse
      # p @source, tree
      
      # [:program, [:stmts_add, [:stmts_new], [x, …]]]
      #                                        ^
      process_any(tree[1][2])
    end
    
    def process_any(tree)
      result = case tree[0]
      # [:program, [:stmts_add, [:stmts_new], [:unary, :-@, [x, …]]]]
      #                                                     ^
      when :unary                          then process_any(tree[2])
      when :var_ref, :top_const_ref        then process_variable(tree)
      when :array, :words_add, :qwords_add then Array
      when :@int                           then Fixnum
      when :@float                         then Float
      when :hash                           then Hash
      when :lambda                         then Proc
      when :dot2, :dot3                    then Range
      when :regexp_literal                 then Regexp
      when :string_literal                 then String
      when :symbol_literal, :dyna_symbol   then Symbol
      end
      
      if result
        result = result.instance_methods if result.is_a?(Class)
        result.map(&:to_s)
      end
    end
    
    def process_variable(tree)
      type, name = tree[1][0..1]
      
      if tree[0] == :top_const_ref
        if type == :@const && Object.constants.include?(name.to_sym)
          evaluate("::#{name}").methods
        end
      else
        case type
        when :@ident
          evaluate(name).methods if local_variables.include?(name)
        when :@gvar
          eval(name).methods if global_variables.include?(name.to_sym)
        when :@const
          evaluate(name).methods if constants.include?(name)
        end
      end
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