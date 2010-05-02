module IRB
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 4
    TINY  = 1
    
    STRING = [MAJOR, MINOR, TINY].join('.')
    DESCRIPTION = "#{STRING} (DietRB)"
  end
end