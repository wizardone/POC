require 'elasticsearch/persistence'

class Document #:nodoc:
  attr_reader :id, :values

  def initialize(id, values)
    @id = id
    @values = values
  end

  def to_hash
    { id: id, values: values }
  end
end
