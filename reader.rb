require_relative 'lib/strict_tsv'
require_relative 'lib/strict_csv'
require_relative 'lib/encoding_support'
require_relative 'lib/data_file_identifier'
require 'json'

class Reader
  attr_reader :files, :data

  def initialize(files, expand=false, mode=nil, pattern=/.+\..*/)
    raise ImporterException::NoFiles, 'Source files undefined' unless files
    @processing_mode = mode
    files = [files] unless files.is_a? Array

    @files = files
    @data ||= {}

  end

  def read_all
    @data ||= {}
    @files.each do |file|
      puts "Reading #{file.path}"
      oracle = DataFileIdentifier.new(file)
      file_processing_mode = @processing_mode
      file_processing_mode = oracle.format if file_processing_mode.nil?
      data = ''
      case file_processing_mode != DataFileIdentifier::UNKNOWN_FILE
      when file_processing_mode == DataFileIdentifier::TSV_FILE
        data = StrictTSV.parse(file).to_json
        puts data
      when file_processing_mode == DataFileIdentifier::CSV_FILE
        data = StrictCSV.parse(file).to_json
        puts data
      else
        next
      end
      @data[file.path] = data
    end
    IO.write("data.pnz", @data)
  end
end