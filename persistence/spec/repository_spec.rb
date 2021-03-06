require 'rspec'
require 'securerandom'
require 'elasticsearch/persistence'
require 'byebug'

require_relative '../repository.rb'
require_relative '../customer.rb'
require_relative '../appointment.rb'
require_relative '../location.rb'

RSpec.describe 'Elasticsearch Repository class POC' do

  let(:repository) do
    Repository.new
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
    before do
      save_customer
      save_appointment
      save_location
      repository.refresh_index!
    end

    it 'finds any kind of document by id' do
      expect(repository.find(345)).to eq('ha?')
    end

    it 'updates object customer with new values' do
      expect(repository.update(id: '123', values: ['New John', 'married']))
        .to include('_version' => 2)
    end

    it 'updates object appointment with new values' do
      expect(repository.update(id: '345', values: ['cancelled']))
        .to include('_version' => 2)
    end

    it 'updates object location with new values' do
      expect(repository.update(id: '567', values: ['Sofia']))
        .to include('_version' => 2)
    end
  end

  context 'searching multiple objects in ES' do
    before do
      save_customer
      save_appointment
      save_location
      repository.refresh_index!
    end

    it 'searches for value john' do
      expect(
        parsed_result(repository.search(query: { match: { values: 'john' } }).response))
        .to eq(['123', '345'])
    end

    it 'searches for value munich' do
      expect(
        parsed_result(repository.search(query: { match: { values: 'munich' } }).response))
        .to eq(['567'])
    end
  end

  private

  def parsed_result(response)
    response['hits']['hits'].map { |hit| hit['_id'] }
  end

  def save_customer
    repository.save(
      #Customer.new(id: '123', values: ['John', 'single', '34'])
      { id: '123', values: ['John', 'single', '34'] }
    )
  end

  def save_appointment
    repository.save(
      #Appointment.new(id: '345', values: ['reserved', 'center', 'for john'])
      { id: '345', values: ['reserved', 'center', 'for john'] }
    )
  end

  def save_location
    repository.save(
      #Location.new(id: '567', values: ['Munich'])
      { id: '567', values: ['Munich'] }
    )
  end
end
