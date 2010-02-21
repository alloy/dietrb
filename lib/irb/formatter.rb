module IRB
  def self.formatter
    @formatter ||= Formatter.new
  end
  
  class Formatter
    DEFAULT_PROMPT = "irb(%s):%03d:%d> "
    SIMPLE_PROMPT  = ">> "
    NO_PROMPT      = ""
    SYNTAX_ERROR   = "SyntaxError: compile error\n(irb):%d: %s"
    SOURCE_ROOT    = /^#{File.expand_path('../../../', __FILE__)}/
    
    attr_writer :prompt
    attr_reader :filter_from_backtrace
    
    def initialize
      @prompt = :default
      @filter_from_backtrace = [SOURCE_ROOT]
    end
    
    def prompt(context)
      case @prompt
      when :default then DEFAULT_PROMPT % [context.object.inspect, context.line, context.source.level]
      when :simple  then SIMPLE_PROMPT
      else
        NO_PROMPT
      end
    end
    
    def result(object)
      "=> #{object.inspect}"
    end
    
    def syntax_error(line, message)
      SYNTAX_ERROR % [line, message]
    end
    
    def exception(exception)
      backtrace = $DEBUG ? exception.backtrace : filter_backtrace(exception.backtrace)
      "#{exception.class.name}: #{exception.message}\n\t#{backtrace.join("\n\t")}"
    end
    
    def filter_backtrace(backtrace)
      backtrace.reject do |line|
        @filter_from_backtrace.any? { |pattern| pattern.match(line) }
      end
    end
  end
end