class Customer
  attr_reader :id, :params

  def initialize(params = {})
    #@id = id
    @params = params
  end

  def to_hash
    # Passing a raw hash like {values: params} is not working
    params
  end
end
