class Location
  attr_reader :id, :params

  def initialize(id, params)
    @id = id
    @params = params
  end

  def to_hash
    @params
  end
end

