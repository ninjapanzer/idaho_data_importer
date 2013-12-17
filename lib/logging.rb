require 'singleton'
require 'logger'

class LogWriter
  include Singleton
  def initialize
    @log = Logger.new('log/processing.log')
  end
 
  def self.log
    instance.log
  end

  def log
    @log
  end
end