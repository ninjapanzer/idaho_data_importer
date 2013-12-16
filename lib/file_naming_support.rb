module FileNamingSupport
  
  module ClassMethods
    
    def filename_from path
      if path.scan(/[^\/]+[.+\.].*$/).empty?
        filename_title = path
      else
        filename_title = path.match(/[^\/]+[.+\.].*$/).to_s
      end
      filename_title
    end
  
  end

  class Utility
    extend ClassMethods
  end

  def self.included(base)
    base.extend ClassMethods
  end

end
