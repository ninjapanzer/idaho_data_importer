require_relative 'encoding_support'
require_relative 'file_encoding_support'
require "csv"

class StrictCSV
  include EncodingSupport

  def self.parse(file)
    data = CSV.read( file, :headers     => true,
                           :quote_char  => '"',
                           :converters  => :all,
                           :encoding    => FileEncodingSupport.new(file).encoding_string
                          )
    binding.pry
  end

end