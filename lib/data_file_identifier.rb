require_relative 'logging'

class DataFileIdentifier
  attr_reader :format

  DATA_FILE_TYPES = [
    CSV_FILE      = 'csv',
    TSV_FILE      = 'tsv',
    UNKNOWN_FILE  = 'unknown'
  ]

  DATA_IDENTIFICATION_DELIMITERS = [
    CSV_FILE_DELIMITER = ',',
    TSV_FILE_DELIMITER = "\t"
  ]

  def initialize(file)
    @file = file
    @format = identify_data_format
  end

private

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

  def identify_data_format

    LogWriter.log.info "Identifying format of #{@file.path}"
    throw_away_headers = @file.gets
    utf_8_first_line = EncodingSupport::Utility.normalize_encoding(@file.gets).strip
    utf_8_second_line = EncodingSupport::Utility.normalize_encoding(@file.gets).strip
    @file.rewind

    first_row = utf_8_first_line.encode('ascii', undef: :replace, replace: '')
    second_row = utf_8_second_line.encode('ascii', undef: :replace, replace: '')

    expected_mode = UNKNOWN_FILE

    DATA_IDENTIFICATION_DELIMITERS.each do |delim|
      first_row_count = first_row.split(delim).count
      second_row_count = second_row.split(delim).count
      count_sum = first_row_count + second_row_count
      expected_mode = resolve_mode_for delim if count_sum != 2 && first_row_count == second_row_count
    end
    LogWriter.log.info "expected mode is #{expected_mode}"
    expected_mode
  end

end