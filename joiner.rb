class Joiner

  def initialize(join_keys)
    raise ImportExcetion::NoPKeys, 'Primary Keys undefined' unless join_keys
    @join_keys = join_keys
  end
end