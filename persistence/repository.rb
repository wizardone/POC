require 'elasticsearch/persistence'
require 'byebug'

class Repository
  include Elasticsearch::Persistence::Repository

  def initialize(options = {})
    client Elasticsearch::Client.new url: 'http://localhost:9200', log: true
    index SecureRandom.uuid
  end

  type 'search_service'
  klass Repository

  settings index: {
    analysis: {
      filter: {
        substring: {
          type: 'edge_ngram',
          min_gram: 1,
          max_gram: 10
        }
      },
      analyzer: {
        autocomplete: {
          type: 'custom',
          tokenizer: 'standard',
          filter: %w(lowercase substring)
        }
      }
    }
  } do
    mappings do
      indexes :values, analyzer: 'autocomplete'
    end
  end

  # By default serialize is called with
  # document.to_hash
  def serialize(document)
    document
  end

end
