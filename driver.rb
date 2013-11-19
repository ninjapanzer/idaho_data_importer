require 'rubygems'
require_relative 'lib/exceptions'
require_relative 'joiner'
require_relative 'reader'
require_relative 'lib/file_encoding_support'
require 'redis'
require 'pry'

spawn 'redis-server', 'redis.conf' #spin up some redis on 6381
sleep 2  #wait for redis to start

DataTable.config do |c|
  c.redis = true
  c.redis_port = 6381
  c.flushall
end

redis = Redis.new(:port => 6381) #get on that redis

files = Dir.glob('data/*.*').map do |file|
  FileEncodingSupport.new(file).file_with_encoding
end

reader = Reader.new(files).read_all
data = reader.data
binding.pry
joiner = Joiner.new([:student_code, :school_code], data)
done = joiner.done_strategies
binding.pry
morejoining = Joiner.new([:student_code], done)
actuallydone = joiner.done_strategies

actually_to_do = actuallydone.map{ |d| d.last.table_id}

to_do = done.map{ |d| d.last.table_id}
puts to_do
puts "Actuall Done #{actuallydone}"

to_do.map{ |t| puts DataTable.new([],[], t).row_count }
actually_to_do.map{ |t| puts DataTable.new([],[], t).row_count }

at_exit{
  files.map{|f| f.close}
  redis.shutdown
}