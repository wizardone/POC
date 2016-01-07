class Customer
  attr_reader :id, :params

  def initialize(params)
    @params = params
  end

  def to_hash
    # if params is passed as a hash it will not work
    # TODO: see why it is failing
    params
  end
end
