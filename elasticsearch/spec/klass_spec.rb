require 'rspec'
require 'elasticsearch/persistence'
require 'byebug'
require 'securerandom'

require_relative '../klass.rb'

RSpec.describe 'CLass POC' do

  let(:repository) do
    Elasticsearch::Persistence::Repository.new do
      #client Elasticsearch::Client.new url: 'http://localhost:9200', log: true
      index SecureRandom.uuid
      type 'document'
      klass Document

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

  context 'Array type documents' do
    before do
      repository.create_index! force: true
      repository.save(Document.new('123', ['one', 'two', 'three']))
      repository.refresh_index!
    end

    it 'returns the full matched query string' do
      ids = parsed_ids(repository.search(query: { match: { values: 'two' } }).response)
      expect(ids).to eq(['123'])
    end

    it 'returns the partial (left-right) match' do
      ids = parsed_ids(repository.search(query: { match: { values: 'tw' } }).response)

      expect(ids).to eq(['123'])
    end

    it 'returns the partial (right-left) match' do
      ids = parsed_ids(repository.search(query: { match: { values: 'ow' } }).response)

      expect(ids).to eq(['123'])
    end
  end

  context 'String type documents' do
    before do
      repository.create_index! force: true
      repository.save(Document.new('123', 'two'))
      repository.refresh_index!
    end

    it 'returns the full matched query string' do
      ids = parsed_ids(repository.search(query: { match: { values: 'two' } }).response)

      expect(ids).to eq(['123'])
    end

    it 'returns the partial (left-right) match' do
      ids = parsed_ids(repository.search(query: { match: { values: 'tw' } }).response)

      expect(ids).to eq(['123'])
    end

    it 'returns the partial (right-left) match' do
      ids = parsed_ids(repository.search(query: { match: { values: 'wo' } }).response)
      byebug
      expect(ids).to eq(['123'])
    end
  end

  context 'Mixed type documents' do
    before do
      repository.create_index! force: true
      repository.save(Document.new('123', 'two'))
      repository.save(Document.new('456', ['one', 'two', 'three']))

      repository.refresh_index!
    end

    it 'returns the full matched query string' do
      ids = parsed_ids(repository.search(query: { match: { values: 'two' } }).response)

      expect(ids).to match_array(['123', '456'])
    end

    it 'returns the partial (left-right) match' do
      ids = parsed_ids(repository.search(query: { match: { values: 'tw' } }).response)

      expect(ids).to match_array(['123', '456'])
    end

    it 'returns the partial (right-left) match' do
      ids = parsed_ids(repository.search(query: { match: { values: 'ow' } }).response)

      expect(ids).to match_array(['123', '456'])
    end
  end

  private

  def parsed_ids(response)
    response['hits']['hits'].map { |hit| hit['_id'] }
  end
end
