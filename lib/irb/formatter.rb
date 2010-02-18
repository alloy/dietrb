module IRB
  def self.formatter
    @formatter ||= Formatter.new
  end
  
  class Formatter
    DEFAULT_PROMPT = "irb(%s):%03d:%d> "
    SIMPLE_PROMPT  = ">> "
    NO_PROMPT      = ""
    
    SYNTAX_ERROR = "SyntaxError: compile error\n(irb):%d: %s"
    
    attr_writer :prompt
    
    def initialize
      @prompt = :default
    end
    
    def prompt(context)
      case @prompt
      when :default then DEFAULT_PROMPT % [context.object.inspect, context.line, context.source.level]
      when :simple  then SIMPLE_PROMPT
      else
        NO_PROMPT
      end
    end
    
    def exception(exception)
      "#{exception.class.name}: #{exception.message}\n\t#{exception.backtrace.join("\n\t")}"
    end
    
    def result(object)
      "=> #{object.inspect}"
    end
    
    def syntax_error(line, message)
      SYNTAX_ERROR % [line, message]
    end
  end
end