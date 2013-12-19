require_relative 'encoding_support'
require_relative 'file_encoding_support'
require_relative 'data_table'
require "csv"

module ArbitraryDataImporter
  class StrictCSV
    include EncodingSupport

    def self.parse(file)
      data = CSV.read( file, :headers     => true,
                             :quote_char  => '"',
                             :converters  => :all,
                             :encoding    => FileEncodingSupport.new(file).encoding_string
                            )
      table ||= DataTable.new (data.headers)

      data.each do |row|
        table.add_row row.to_hash
      end
      table
    end

  end
end