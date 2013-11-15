class Joiner

  def initialize(join_keys, data)
    raise ImportExcetion::NoPKeys, 'Primary Keys undefined' unless join_keys
    @join_keys = join_keys
    @data = data
    @join_strategies = organize_files_to_join
    build_rows
    binding.pry
  end

private

  def organize_files_to_join
    the_magic = {}
    @data.each do |d|
      orig_keys = d.last.keys
      intersect_keys = d.last.keys & (@join_keys.map(&:to_s))
      intersect_keys.map { |s| the_magic[s] ||= []; the_magic[s] << d.first }
    end
    the_magic
  end

  def build_rows
    @join_strategies.each do |strat|
      key_field = strat.first
      files = strat.last
      keyed_files = []
      global_keys = []
      files.each do |f|
        by_key ||= {}
        @data[f][key_field].map{ |key| by_key[key] = [] }
        local_keys = @data[f].keys - [key_field]
        global_keys.push local_keys
        row = []
        (0..by_key.count).each do |row|
          
          local_keys.each do |lk|
            row.push @data[f][lk][row]
          end
        end
        

        keyed_files.push by_key
        
        @data[f].keys.each do |k|
          binding.pry
          vals.keys
        end
      end

    end
  end
end