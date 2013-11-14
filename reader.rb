require_relative 'lib/strict_tsv'
require_relative 'lib/encoding_support'
require 'json'

DATA_FILE_TYPES = [
  CSV_FILE      = 'csv',
  TSV_FILE      = 'tsv',
  UNKNOWN_FILE  = 'unknown'
]

DATA_IDENTIFICATION_DELIMITERS = [
  CSV_FILE_DELIMITER = ',',
  TSV_FILE_DELIMITER = "\t"
]

class Reader
  attr_reader :files, :data

  def initialize(files, expand=false, mode=nil, pattern=/.+\..*/)
    raise ImporterException::NoFiles, 'Source files undefined' unless files
    @processing_mode = mode
    files = [files] unless files.is_a? Array

    @files = files
    @data ||= {}

  end

  def resolve_mode_for delim
    case
    when delim == CSV_FILE_DELIMITER
      return CSV_FILE
    when delim == TSV_FILE_DELIMITER
      return TSV_FILE
    else
      return UNKNOWN_FILE
    end
  end

  def identify_reader_method_of file
    puts "Identifying format of #{file.path}"
    throw_away_headers = file.gets
    utf_8_first_line = EncodingSupport::Utility.normalize_encoding(file.gets).strip
    utf_8_second_line = EncodingSupport::Utility.normalize_encoding(file.gets).strip
    file.rewind

    first_row = utf_8_first_line.encode('ascii', undef: :replace, replace: '')
    second_row = utf_8_second_line.encode('ascii', undef: :replace, replace: '')

    expected_mode = UNKNOWN_FILE

    DATA_IDENTIFICATION_DELIMITERS.each do |delim|
      first_row_count = first_row.split(delim).count
      second_row_count = second_row.split(delim).count
      count_sum = first_row_count + second_row_count
      expected_mode = resolve_mode_for delim if count_sum != 2 && first_row_count == second_row_count
    end
    puts "expected mode is #{expected_mode}"
    expected_mode
  end

  def read_all
    @data ||= {}
    @files.each do |file|
      puts "Reading #{file.path}"
      file_processing_mode = identify_reader_method_of(file) if @processing_mode.nil?
      data = ''
      case file_processing_mode != UNKNOWN_FILE
      when file_processing_mode == TSV_FILE
        data = StrictTSV.parse(file).to_json
        puts data
      when file_processing_mode == CSV_FILE
        #data = CSVSTUB.parse
        puts 'csv data would be here'
      else
        next
      end
      @data[file.path] = data
    end
    IO.write("tsvdata.pnz", @data)
  end
end