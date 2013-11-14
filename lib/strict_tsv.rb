# modified from gist https://gist.github.com/hqmq/5460684
# The main parse method is mostly borrowed from a tweet by @JEG2
class StrictTSV
  attr_reader :filepath
  def initialize(filepath)
    @filepath = filepath
  end
 
  def parse
    open(filepath) do |f|
      headers = f.gets.encode('UTF-8','binary', :invalid => :replace, :undef => :replace, :replace => '').strip.split("\t")
      f.each do |line|
        fields = Hash[headers.zip(line.split("\t"))]
        yield fields
      end
    end
  end

  def self.parse(file)
    headers = file.gets.encode('UTF-8','binary', :invalid => :replace, :undef => :replace, :replace => '').strip.split("\t")
    fields = []
    file.each do |line|
      fields.push (line.encode('UTF-8','binary', :invalid => :replace, :undef => :replace, :replace => '').strip.split("\t"))
    end
    table = {headers => fields}
    binding.pry
    table
  end
end