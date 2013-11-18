require_relative 'exceptions'
require 'redis'
require 'securerandom'

class DataTable
  class << self
    attr_accessor :configuration
  end

  attr_reader :rows, :headers

  def self.config
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def initialize (headers=[], rows=[])
    @headers = headers
    @rows = rows
    @config = DataTable.configuration
    setup_redis if @config.redis
    add_headers headers unless headers.empty?
    add_rows rows unless rows.empty?
  end

  def add_rows (rows)
    detect_array_exception_for! rows
    @rows = rows
  end

  def add_row (row=[])
    detect_headers_not_set_and_raise!
    raise DataTableException::InvalidRow, "Your row doesn't match Your headers row:#{row.count} headers:#{@headers.count}" unless @headers.count == row.count
    @rows.push row
    @redis["#{@redis_id_hash}:rows"] = @rows
  end

  def add_headers (headers)
    detect_array_exception_for! headers
    @headers = headers
    @redis["#{@redis_id_hash}:headers"] = @headers
  end

  def by_rows
    detect_headers_not_set_and_raise!
    rows = []
    @rows.each do |row|
      rows.push @headers.map { |h| row[h] }
    end
    rows
  end

  def by_cols
    detect_headers_not_set_and_raise!
    cols = []
    @headers.each do |h|
      cols.push @rows.map { |row| row[h] }
    end
    cols
  end

private

  def create_empty_row
    detect_headers_not_set_and_raise!
    Hash[@headers.zip]
  end

  def setup_redis
    @redis = Redis.new(:port => @config.redis_port)
    @redis_id_hash = SecureRandom.uuid
  end

  def detect_headers_not_set_and_raise!
    raise DataTableException::HeadersNotSet, "You must set headers before you can add a row" if @headers.empty?
  end

  def detect_array_exception_for! var
    raise DataTableException::NotAnArray, "#{var} is not an array" unless var.is_a? Array
  end
  
end

class Configuration
  attr_accessor :redis_port, :redis

  def initialize
    @redis = false
    @redis_port = 6379
  end

  def flushall
    redis = Redis.new(:port => @redis_port)
    redis.flushall
    redis = nil
  end
end