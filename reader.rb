require_relative 'lib/strict_tsv'
require 'json'

class Reader
  attr_reader :files, :data

  def initialize(files, expand=false, extension='txt', pattern=/.+\..*/, order=[])
    raise ImporterException::NoFiles, 'Source files undefined' unless files

    files = [files] unless files.is_a? Array

    @files = files
    @data ||= {}

  end


  def read_all
    @data ||= {}
    @files.each do |file|
      data = StrictTSV.parse(file).to_json
      @data[file.path] = data
    end
    IO.write("tsvdata.pnz", @data)
  end
end