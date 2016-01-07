require 'elasticsearch/persistence'

class Repository
  include Elasticsearch::Persistence::Repository

  def initialize(options = {})

  end

  settings number_of_shards: 1 do

  end

  def serialize

  end
end
