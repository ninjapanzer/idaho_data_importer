class FileEncodingSupport
  def initialize(file, mode='r')
    @file = file.is_a?(File) ? file.path : file
    @encoding = get_file_encoding
    @mode = @encoding.ascii_compatible? ? mode : "#{mode}b"
  end

  def file_with_encoding
    file = File.new(@file, mode: @mode, encoding: encoding_string)
    file.set_encoding encoding_string
    file
  end

  def get_file_encoding
    Encoding.find(`file -I #{@file}`.match(/(charset)=(\S*)$?/i)[2])
  end

  def encoding_string
    "#{bom_string}#{@encoding}"
  end

private

  def has_bom?
    true if @encoding.name.downcase.include?('utf')
  end

  def bom_string
    'bom|' if has_bom?
  end
end