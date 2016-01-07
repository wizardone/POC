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
    it 'saves object customer with array of values' do
      response = save_customer

      expect(response).to include('created' => true)
    end

    it 'saves object appointment with array of values' do
      response = save_appointment

      expect(response).to include('created' => true)
    end

    it 'saves object location with array of values' do
      response = save_location

      expect(response).to include('created' => true)
    end

    it 'saves multiple objects with array of values' do

    end
  end

  context 'updating multiple objects in ES' do
    it 'updates object customer with new values' do
      save_customer

      expect(repository.update(id: '123', values: ['New John', 'married']))
        .to include('_version' => 2)
    end

    it 'updates object appointment with new values' do
      save_appointment

      expect(repository.update(id: '345', values: ['cancelled']))
        .to include('_version' => 2)
    end

    it 'updates object location with new values' do
      save_location

      expect(repository.update(id: '567', values: ['Sofia']))
        .to include('_version' => 2)
    end

  end

  context 'searching multiple objects in ES' do

  end

  private

  def save_customer
    repository.save(
      Customer.new(id: '123', values: ['John', 'single', '34'])
    )
  end

  def save_appointment
    repository.save(
      Appointment.new(id: '345', values: ['reserved', 'center'])
    )
  end

  def save_location
    repository.save(
      Location.new(id: '567', values: ['Munich'])
    )
  end
end
