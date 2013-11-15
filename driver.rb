require 'rubygems'
require_relative 'exceptions'
require_relative 'joiner'
require_relative 'reader'
require_relative 'lib/file_encoding_support'
require 'redis'
require 'pry'

spawn 'redis-server', 'redis.conf' #spin up some redis on 6381
sleep 2  #wait for redis to start

redis = Redis.new(:port => 6381) #get on that redis

files = Dir.glob('data/*.*').map do |file|
  FileEncodingSupport.new(file).file_with_encoding
end

reader = Reader.new files
reader.read_all
joiner = reader.files

at_exit{
  files.map{|f| f.close}
  redis.shutdown
}