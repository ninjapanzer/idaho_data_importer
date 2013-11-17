module ImporterException
  
  class NoFiles < Exception
  end

  class NoPKeys < Exception
  end
  
end

module DataTableException
  class NotAnArray < Exception
  end

  class HeadersNotSet < Exception
  end

  class InvalidRow < Exception
  end
end