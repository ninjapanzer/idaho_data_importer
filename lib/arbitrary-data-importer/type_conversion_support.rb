module ArbitraryDataImporter
  module TypeConversionSupport

    module ClassMethods
      def numeric? thing
        thing.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true unless thing.nil?
      end

      def convert_numeric thing
        if numeric? thing
          num = Float(thing)
          num = num.to_i if num % 1 == 0
          return num
        end
        thing
      end
    end

    class Utility
      extend ClassMethods
    end

    def self.included(base)
      base.extend ClassMethods
    end

  end
end