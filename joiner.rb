class Joiner

  def initialize(join_keys, data)
    raise ImportExcetion::NoPKeys, 'Primary Keys undefined' unless join_keys
    @join_keys = join_keys
    @join_strategies = organize_files_to_join
  end

  def organize_files_to_join
    the_magic = {}
    data.each do |d|
      orig_keys = d.last.keys
      intersect_keys = d.last.keys & (join_keys.map(&:to_s))
      intersect_keys.map { |s| the_magic[s] ||= []; the_magic[s] << d.first }
      binding.pry
    end
    the_magic
  end
end