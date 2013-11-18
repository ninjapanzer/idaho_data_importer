require_relative 'lib/data_table'
require_relative 'lib/exceptions'
require 'set'

class Joiner

  def initialize(join_keys, data)
    throw ImportExcetion::NoPKeys, 'Primary Keys undefined' unless join_keys
    @join_keys = join_keys
    @data = data 
    @join_strategies = organize_files_to_join
    @done_strategies = join
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

  def join
    done_strategies = {}
    @join_strategies.each do |strat|
      insertions = {}
      headers = Set.new
      strat.last.each do |file|
        l_data = @data[file]
        rows = l_data.rows.sort_by{|r| r[strat.first]}
        rows.each do |r|
          insertions[r[strat.first]] ||= {}
          insertions[r[strat.first]].merge! r
          headers.merge insertions[r[strat.first]].keys
        end
      end

      data_t = DataTable.new headers.to_a
      insertions.each do |i|
        row = i.last
        begin
          data_t.add_row row.values
        rescue DataTableException::InvalidRow => e
          row = Hash[headers.zip].merge row
          data_t.add_row row
        end
      end
      done_strategies[strat.first] = data_t
      @data[strat.first] = data_t
    end
    done_strategies
  end

end