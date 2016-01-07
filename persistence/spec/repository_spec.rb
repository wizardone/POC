require 'rspec'
require 'securerandom'
require 'elasticsearch/persistence'

require_relative '../repository.rb'
require_relative '../customer.rb'
require_relative '../appointment.rb'
require_relative '../location.rb'

RSpec.describe 'Elasticsearch Repository class POC' do

  let(:repository) do
    Elasticsearch::Persistence::Repository.new do
      client Elasticsearch::Client.new url: 'http://localhost:9200', log: true
      index SecureRandom.uuid
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
    end
  end

  before do
    repository.create_index! force: true
  end

  context 'saving multiple objects with the same structure in ES' do
    it 'saves object customer' do
      customer = Customer.new({ id: '1', name: 'john', age: '20', status: 'single' })
      response = repository.save(customer)

      expect(response).to be_kind_of(Hash)
      expect(response).to include('created' => true)
    end

    it 'saves object appointment' do

    end

    it 'saves object location' do

    end

    it 'saves multiple objects' do

    end
  end

  context 'updating multiple objects in ES' do

  end

  context 'searching multiple objects in ES' do

  end

end
