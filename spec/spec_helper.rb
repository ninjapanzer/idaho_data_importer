require 'require_all'
require_all 'lib/arbitrary-data-importer'
require 'rspec/autorun'
require 'rspec/expectations'
require 'pry'
require 'yarjuf'

RSpec.configure do |config|
  # Use color in STDOUT
  config.color_enabled = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate

  config.before :suite do
    spawn 'redis-server', 'spec/fixtures/redis.conf' #spin up some redis on 6381
    sleep 2  #wait for redis to start
    SUPER_REDIS = Redis.new(:port => 6381) #get on that redis
  end

  config.after :suite do 
    SUPER_REDIS.shutdown
  end
end
