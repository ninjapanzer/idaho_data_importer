require_relative 'strict_tsv'
require_relative 'strict_csv'
require_relative 'encoding_support'
require_relative 'data_file_identifier'
require_relative 'logging'
require 'json'

module ArbitraryDataImporter
  class Reader
    attr_reader :files, :data

    def initialize(files, options={})
      raise ImporterException::NoFiles, 'Source files undefined' unless files
      @processing_mode = options[:mode]
      @expand = options[:expand] ||= false
      @pattern = options[:pattern] ||= /.+\..*/
      files = [files] unless files.is_a? Array

      @files = files
      @data ||= {}

    end

    def read file 
      LogWriter.log.info "Reading #{file.path}"
      oracle = DataFileIdentifier.new(file)
      file_processing_mode = @processing_mode
      file_processing_mode = oracle.format if file_processing_mode.nil?
      data = ''
      case file_processing_mode != DataFileIdentifier::UNKNOWN_FILE
      when file_processing_mode == DataFileIdentifier::TSV_FILE
        data = StrictTSV.parse(file)
        LogWriter.log.debug data.inspect
      when file_processing_mode == DataFileIdentifier::CSV_FILE
        data = StrictCSV.parse(file)
        LogWriter.log.debug data.inspect
      else
        return
      end
      data
    end

    def read_all
      @data ||= {}
      LogWriter.log.debug 'Reading Started'
      @files.each do |file|
        @data[file.path] = read file
      end
      LogWriter.log.debug 'Reading Complete'
      self
    end
  end
end