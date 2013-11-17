class Joiner

  def initialize(join_keys, data)
    raise ImportExcetion::NoPKeys, 'Primary Keys undefined' unless join_keys
    @join_keys = join_keys
    @data = data
    @join_strategies = organize_files_to_join
    join
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
    @join_strategies.each do |strat|
      insertions = {}
      strat.last.each do |file|
        l_data = @data[file]
        rows = l_data.rows.sort_by{|r| r[strat.first]}
        rows.each do |r|
          insertions[r[strat.first]] ||= {}
          insertions[r[strat.first]].merge! r
        end
        binding.pry
        #insertions[rows[strat.first]] = rows
      end
      binding.pry
    end
  end
end