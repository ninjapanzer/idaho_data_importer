# modified from gist https://gist.github.com/hqmq/5460684
# The main parse method is mostly borrowed from a tweet by @JEG2
class StrictTSV

  DATA_ENCODING = 'utf-8'
  KEY_ENCODING = 'ascii'

  def self.normalize_encoding str
    str.encode(DATA_ENCODING)
  end

  def self.key_encoding key
    key.encode(KEY_ENCODING)
  end

  def self.parse(file)
    headers = key_encoding(normalize_encoding(file.gets)).strip.split("\t")
    table ||= {}
    headers.each do |h|
      table[h] = []
    end
    file.each do |line|
      fields = Hash[headers.zip(normalize_encoding(line).strip.split("\t"))]
      table.keys.each do |k|
        table[k].push fields[k]
      end
    end
    table
  end

end