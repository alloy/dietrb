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
      source = @source
      filter = nil
      
      # if ends with period, remove it to remove the syntax error it causes
      call = (source[-1,1] == '.')
      receiver = source = source[0..-2] if call
      
      if sexp = Ripper::SexpBuilder.new(source).parse
        # [:program, [:stmts_add, [:stmts_new], [x, …]]]
        #                                        ^
        sexp = sexp[1][2]
        
        # [:call, [:hash, nil], :".", [:@ident, x, …]]
        if sexp[0] == :call
          call     = true
          filter   = sexp[3][1]
          receiver = source[0..-(filter.length + 2)]
          sexp     = sexp[1]
        end
        
        if call
          methods = methods_of_object(sexp)
          format(receiver, methods, filter)
        end
      end
    end
    
    def format(receiver, methods, filter)
      (filter ? methods.grep(/^#{filter}/) : methods).map { |m| "#{receiver}.#{m}" }
    end
    
    def methods_of_object(sexp)
      result = case sexp[0]
      # [:unary, :-@, [x, …]]
      #               ^
      when :unary                          then return methods_of_object(sexp[2]) # TODO: do we really need this?
      when :var_ref, :top_const_ref        then return methods_of_object_in_variable(sexp)
      when :array, :words_add, :qwords_add then Array
      when :@int                           then Fixnum
      when :@float                         then Float
      when :hash                           then Hash
      when :lambda                         then Proc
      when :dot2, :dot3                    then Range
      when :regexp_literal                 then Regexp
      when :string_literal                 then String
      when :symbol_literal, :dyna_symbol   then Symbol
      end.instance_methods
    end
    
    def methods_of_object_in_variable(sexp)
      type, name = sexp[1][0..1]
      
      if sexp[0] == :top_const_ref
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