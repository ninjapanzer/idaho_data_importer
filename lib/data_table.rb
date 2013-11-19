require_relative 'type_conversion_support'
require 'redis'
require 'securerandom'

class DataTable
  attr_reader :redis_id_hash, :row_count

  class << self
    attr_accessor :configuration
  end

  class Configuration
    attr_accessor :redis_port, :redis, :redis_host, :redis_db, :redis_password

    def initialize
      @redis = false
      @redis_host = 'localhost'
      @redis_port = 6379
      @redis_db = 0
      @redis_password = nil
    end

    def build_from_redis_hash hash
      @redis = true
      @redis_host = hash[:host]
      @redis_port = hash[:port]
      @redis_db = hash[:db]
      @redis_password = hash[:password]
    end

    # you should likely never use this because it will purge the whole redis cache
    def flushall
      redis = Redis.new(:port => @redis_port)
      redis.flushall
      redis = nil
    end
  end

  def self.config
    self.configuration ||= DataTable::Configuration.new
    yield(configuration) if block_given?
  end

  def self.build_with_config config, assumed_key_hash=nil
    inst = DataTable.new [], [], assumed_key_hash
    inst.set_config_with config
    inst
  end

  def initialize (headers=[], rows=[], assumed_key_hash=nil)
    @headers = headers
    @rows = rows
    @row_count = 0
    @redis_id_hash = assumed_key_hash
    set_config_with DataTable.configuration
    add_headers headers unless headers.empty?
    add_rows row unless rows.empty?
  end

  def refresh
    @row_count = @redis.get "#{@redis_id_hash}:rows:count"
  end

  def set_config_with config
    config ||= DataTable::Configuration.new
    @config = config
    setup_redis if @config.redis
  end

  #DONT USE
  def add_rows (rows)
    raise Exception, "Don't Use Me"
    detect_array_exception_for! rows
    @rows = rows
  end

  def add_row (row=[])
    detect_headers_not_set_and_raise!
    raise DataTableException::InvalidRow, "Your row doesn't match Your headers row:#{row.count} headers:#{@headers.count}" unless @headers.count == row.count
    @rows.push row unless @redis
    if @redis
      index = @row_count
      row.each do |r|
        @redis.hset "#{@redis_id_hash}:rows:#{index}", r.first, r.last
      end
      @row_count = @redis.incr "#{@redis_id_hash}:rows:count"
    end
      
  end

  def add_headers (headers)
    detect_array_exception_for! headers
    @headers = headers unless @redis
    headers.each {|h| @redis.rpush "#{@redis_id_hash}:headers", h } if @redis
  end

  def rows (start=0,stop=-1)
    return @rows unless @redis
    stop = (@redis.get "#{@redis_id_hash}:rows:count").to_i if stop == -1
    l_headers = headers
    l_rows = []
    (start...stop).each do |index|
      l_row = @redis.hgetall("#{@redis_id_hash}:rows:#{index}")
      l_row.map { |k,v| l_row[k] = TypeConversionSupport::Utility.convert_numeric(l_row[k]) }
      l_rows.push l_row
    end
    l_rows
  end

  def headers
    return @headers unless @redis
    @redis.lrange "#{@redis_id_hash}:headers", 0, -1
  end

  def by_rows
    by_data headers, rows
    
  end

  def by_cols
    by_data rows, headers
  end

  def table_id
    @redis_id_hash
  end

  def expire! sec=120
    keys = ["#{@redis_id_hash}:headers", "#{@redis_id_hash}:count"]
    start = 0
    stop = (@redis.get "#{@redis_id_hash}:rows:count").to_i
    (start...stop).map{|index| @redis.expire "#{@redis_id_hash}:rows:#{index}", sec}
    keys.map{ |k| @redis.expire k, sec }
  end

private

  def by_data c, r
    rs = []
    r.each do |row|
      rs.push c.map { |h| r[h] }
    end
    rows
  end

  def create_empty_row
    detect_headers_not_set_and_raise!
    Hash[@headers.zip]
  end

  def setup_redis
    @redis = Redis.new(
      :port => @config.redis_port,
      :host => @config.redis_host,
      :db => @config.redis_db,
      :password => @config.redis_password)
    refresh if @redis_id_hash
    @redis_id_hash = SecureRandom.uuid unless @redis_id_hash
  end

  def detect_headers_not_set_and_raise!
    raise DataTableException::HeadersNotSet, "You must set headers before you can add a row" if @headers.empty?
  end

  def detect_array_exception_for! var
    raise DataTableException::NotAnArray, "#{var} is not an array" unless var.is_a? Array
  end
  
end

module DataTableException
  class NotAnArray < Exception
  end

  class HeadersNotSet < Exception
  end

  class InvalidRow < Exception
  end
end