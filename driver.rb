require 'rubygems'
require_relative 'exceptions'
require_relative 'joiner'
require_relative 'reader'
require 'redis'
require 'pry'

spawn 'redis-server', 'redis.conf' #spin up some redis on 6381
sleep 2  #wait for redis to start


redis = Redis.new(:port => 6381) #get on that redis

def get_encoding filename
  encoding = Encoding.find(`file -I #{filename}`.match(/(charset)=(\S*)$?/i)[2])
  { encoding: encoding,
    mode: encoding.ascii_compatible? ? 'r' : 'rb'
}
end

files = Dir.glob('data/*.*').map do |file|
  encoding_hash = get_encoding(file)
  File.new(File.join(File.expand_path File.dirname(__FILE__), file), mode: encoding_hash[:mode], encoding: encoding_hash[:encoding])
end

reader = Reader.new files
reader.read_all
joiner = reader.files

at_exit{
  redis.shutdown
}