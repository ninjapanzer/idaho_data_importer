require_relative 'lib/strict_tsv'
require 'json'

class Reader
  attr_reader :files, :data

  def initialize(files, expand=false, extension='txt', pattern=/.+\..*/, order=[])
    raise ImporterException::NoFiles, 'Source files undefined' unless files
    @files = files
    @data ||= {}

  end


  def read_all
    StrictTSV.parse(@files.first).to_json
    @files.each do |file|
      
    end
  end
end