module IRB
  class << self
    attr_writer :formatter
    
    def formatter
      @formatter ||= Formatter::Default.new
    end
  end
  
  module Formatter
    class Default
      PROMPT = "irb(%s):%03d:%d> "
      
      def prompt(context)
        PROMPT % [context.object.inspect, context.line, context.source.level]
      end
      
      def exception(exception)
        "#{exception.class.name}: #{exception.message}\n\t#{exception.backtrace.join("\n\t")}"
      end
      
      def result(object)
        "=> #{object.inspect}"
      end
      
      SYNTAX_ERROR = "SyntaxError: compile error\n(irb):%d: %s"
      
      def syntax_error(line, message)
        SYNTAX_ERROR % [line, message]
      end
    end
    
    class SimplePrompt < Default
      PROMPT = ">> "
      
      def prompt(_)
        PROMPT
      end
    end
  end
end