require 'pg'
require 'sequel'
require 'sqlite3'
require_relative 'file_naming_support'

class DatabaseLoader

  class InvalidEngineException < Exception; end

  class << self
    attr_accessor :configuration
  end

  class Configuration
    attr_accessor :dbengine, :connection_hash

    ENGINES = [
      SQLITE = 'sqlite',
      POSTGRES = 'postgres'
    ]

    def initialize
      @connection_hash ||= {
                           host: 'localhost',
                           port: '',
                           user: '',
                           password: ''
                         }

      @dbengine ||= :sqlite
    end

    def engine= engine = :sqlite
      if ENGINES.include? engine.to_s
        @dbengine = engine.to_sym
      else
        raise DatabaseLoader::InvalidEngineException, "Provided #{engine} is not currently supported or your spelling sucks (mancedit)?"
      end
    end

    def connection_hash= config
      @connection_hash = config
    end

  end

  def self.config
    self.configuration ||= DatabaseLoader::Configuration.new
    yield(configuration) if block_given?
    self.configuration
  end

  def startup_engine
    spinup_postgres if @config.dbengine == :postgres
    spinup_sqlite if @config.dbengine == :sqlite
  end

  def spinup_postgres
    @connection = Sequel.postgres @config.connection_hash
  end

  def spinup_sqlite
    @connection = Sequel.sqlite()
  end

  def connection
    @connection
  end

  def close
    @connection.close
  end

  def initialize datatables = []
    @config = DatabaseLoader.config
    startup_engine
    accumulate_tables datatables
  end

  def table_name name
    FileNamingSupport::Utility.filename_from name
  end

  def accumulate_tables data_tables
    data_tables.each do |n,d|
      filename_title = table_name n
      create_table filename_title, d
      populate_data filename_title, d
    end
  end

  def create_table table_name, data_table
    @connection.create_table table_name.to_sym do
      primary_key :id
      data_table.header_types.each do |n,t|
        send t.name.to_sym, n
      end
    end
  end

  def populate_data table_name, data_table
    rows = @connection[table_name.to_sym]
    data_table.rows.each do |r|
      rows.insert Hash[r.map{|(k,v)| [k.to_sym,v]}] 
    end
  end

end