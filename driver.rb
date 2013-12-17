require 'rubygems'
require_relative 'lib/exceptions'
require_relative 'lib/joiner'
require_relative 'lib/reader'
require_relative 'lib/database_loader'
require_relative 'lib/file_encoding_support'
require 'redis'
require 'pry'
require 'csv'

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

db_loader = DatabaseLoader.new data

joiner = Joiner.build_with_data([:school_code, :staff_code, :student_code], data)
joiner.run_with_sql db_loader.connection

db_loader.connection.disconnect

done = joiner.done_strategies

db_loader = DatabaseLoader.new done

morejoining = Joiner.build_with_data([:student_code], done)
morejoining.run_with_sql db_loader.connection

db_loader.connection.disconnect

actuallydone = morejoining.done_strategies

actually_to_do = actuallydone.map{ |d| d.last.table_id}

to_do = done.map{ |d| d.last.table_id}
puts to_do
puts "Actually Done #{actuallydone}"

to_do.each do |d|
  csv_string = CSV.generate do |csv|
    data = DataTable.new([],[], d)
    csv << data.headers
    data.rows.each do |r|
      csv << r.values
    end
  end
  IO.write('out/'+d+'.csv', csv_string)
end

to_do.map{ |t| puts DataTable.new([],[], t).row_count }
actually_to_do.map{ |t| puts DataTable.new([],[], t).row_count }

actually_to_do.each do |d|
  csv_string = CSV.generate do |csv|
    data = DataTable.new([],[], d)
    csv << data.headers
    data.rows.each do |r|
      csv << r.values
    end
  end
  IO.write('out/'+d+'revision.csv', csv_string)
end


at_exit{
  files.map{|f| f.close}
  redis.shutdown
}