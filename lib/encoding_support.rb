module EncodingSupport
  
  module ClassMethods
    DATA_ENCODING = 'utf-8'
    KEY_ENCODING = 'ascii'

    def normalize_encoding str
      str.encode(DATA_ENCODING)
    end

    def key_encoding key
      key.encode(KEY_ENCODING, undef: :replace, invalid: :replace, replace: '')
    end
  end

  class Utility
    extend ClassMethods
  end

  def self.included(base)
    base.extend ClassMethods
  end

end
