require_relative 'data_table'
require_relative 'exceptions'
require_relative 'file_naming_support'
require_relative 'logging'
require 'set'

module ArbitraryDataImporter
  class Joiner
    attr_reader :join_strategies, :done_strategies

    def initialize

    end

    def run
      LogWriter.log.debug 'Joining with Handroll'
      @done_strategies = join
    end

    def setup join_keys, data
      throw ImportExcetion::NoPKeys, 'Primary Keys undefined' unless join_keys
      @join_keys = join_keys
      @data = data 
      @join_strategies = organize_files_to_join
    end

    def self.build_with_data(join_keys, data)
      joiner = Joiner.new
      joiner.setup(join_keys, data)
      LogWriter.log.debug "Creating Joiner"
      joiner
    end

    def run_with_sql connection
      require 'sequel'
      LogWriter.log.debug 'Joining with SQL'
      @connection = connection
      @done_strategies = sql_join
    end


  private

    def organize_files_to_join
      the_magic = {}
      @data.each do |d|
        orig_keys = d.last.headers
        intersect_keys = orig_keys & (@join_keys.map(&:to_s))
        intersect_keys.map { |s| the_magic[s] ||= []; the_magic[s] << d.first }
      end
      the_magic
    end

    def create_data_table_for insertions, headers
      data_t = DataTable.new headers.to_a
      insertions.each do |i|
        row = i
        begin
          data_t.add_row row
        rescue DataTableException::InvalidRow => e
          row = Hash[headers.zip].merge row
          data_t.add_row row
        end
      end
      data_t
    end

    def sort_data data, sort_key
      l_data = data
      rows = nil
      begin
        rows = l_data.rows.sort_by{|r| r[sort_key]}
      rescue ArgumentError => e
        mes = e.message.downcase
        if  (mes.index('fixnum') || 0) > (mes.index('string') || 0)
          rows = l_data.rows.sort_by{|r| r[sort_key].to_i}
        else
          rows = l_data.rows.sort_by{|r| r[sort_key].to_s}
        end
      end
      rows
    end

    def sql_join
      done_strategies = {}
      @join_strategies.each do |strat|
        join_col = strat.first
        tables = strat.last
        first_table = @connection[FileNamingSupport::Utility.filename_from(tables.first).to_sym]
        tables.delete tables.first
        index ||= 0
        current_query = first_table
        tables.each do |t|
          current_query = current_query.from_self(alias: :the_other_table).join FileNamingSupport::Utility.filename_from(t).to_sym, {join_col.to_sym => join_col.to_sym}
        end
        data_t = create_data_table_for current_query.all, current_query.first.keys if current_query.count > 0
        done_strategies[strat.first] = data_t
        @data[strat.first] = data_t
      end
      done_strategies
    end

    def join
      done_strategies = {}
      @join_strategies.each do |strat|
        insertions = {}
        headers = Set.new
        strat.last.each do |file|
          l_data = @data[file]
          
          rows = sort_data l_data, strat.first

          rows.each do |r|
            insertions[r[strat.first]] ||= {}
            insertions[r[strat.first]].merge! r
            headers.merge insertions[r[strat.first]].keys
          end
          @data[file].expire!
        end

        data_t = create_data_table_for insertions.values, headers
        done_strategies[strat.first] = data_t
        @data[strat.first] = data_t
      end
      done_strategies
    end
  end
end