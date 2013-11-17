# modified from gist https://gist.github.com/hqmq/5460684
# The main parse method is mostly borrowed from a tweet by @JEG2
require_relative 'encoding_support'
require_relative 'file_encoding_support'
require_relative 'conversion_support'
class StrictTSV
  include EncodingSupport
  include ConversionSupport

  def self.parse(file)
    file = file.is_a?(File) ? file : FileEncodingSupport.new(file).file_with_encoding
    headers = key_encoding(normalize_encoding(file.gets)).strip.split("\t")
    
    table ||= DataTable.new(headers)

    file.each do |line|
      table.add_row Hash[headers.zip(normalize_encoding(line).strip.split("\t"))]
    end
    table
  end

end