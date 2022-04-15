require 'rails_helper'

RSpec.describe ::GithubApi::Repository, type: :service do
  context '#call with positive response' do
    before do
      stub_request(:any, 'https://api.github.com/search/repositories?page=1&per_page=100&q=search&sort=stars').
        to_return(status: 200, body: request_data.to_json)
    end

    it 'validates the results for search' do
      result = described_class.new('search', page: 1).call

      expect(result[:repos]).to be_kind_of(Array)
      expect(result[:repos].count).to eq(2)
      first_repo = result[:repos].first
      expect(first_repo).to have_key(:full_name)
      expect(first_repo).to have_key(:html_url)
      expect(first_repo).to have_key(:description)
      expect(first_repo).not_to have_key(:name)
      expect(result[:pages]).to be_kind_of(Integer)
      expect(result[:pages]).to eq(1)
      expect(result[:error_message]).to be_nil
      expect(result[:success]).to be_truthy
    end

    it 'checks pages to be less than 10' do
      stub_request(:get, 'https://api.github.com/search/repositories?page=1&per_page=100&q=search&sort=stars').
        to_return(status: 200, body: hash_to_check_pages_count.to_json)
      result = described_class.new('search', page: 1).call

      expect(result[:pages]).to eq(10)
      expect(result[:success]).to be_truthy
    end
  end

  context '#call with 404' do
    before do
      response = { message: 'Not Found' }
      stub_request(:get, 'https://api.github.com/search/repositories?page=1&per_page=100&q=search&sort=stars').
        to_return(status: 404, body: request_data.to_json)
    end

    it 'returns empty repos on 404' do
      result = described_class.new('search', page: 1).call

      expect(result[:repos]).to be_nil
      expect(result[:pages]).to be_nil
      expect(result[:success]).to be_falsy
    end
  end

  def request_data
    {
      "total_count": 2,
      "items": [
        {
          "name": 'junaid2/photo-app',
          "full_name": 'junaid2/photo-app',
          "private": false,
          "owner": {
            "login": 'junaid2',
            "id": 26313925345612,
            "node_id": '12345'
          },
          "html_url": 'https://github.com/junaid2/photo-app',
          "description": 'A test app'
        },
        {
          "name": 'junaid2/photo-app2',
          "full_name": 'junaid2/photo-app2',
          "private": false,
          "owner": {
            "login": 'junaid2',
            "id": 263139253456122,
            "node_id": '123453'
          },
          "html_url": 'https://github.com/junaid2/photo-app2',
          "description": 'A test app'
        }
      ],
      "incomplete_results": false
    }
  end

  def hash_to_check_pages_count
    {
      "total_count": 100000000000,
      "items": [
        {
          "name": 'junaid2/photo-app',
          "full_name": 'junaid2/photo-app',
          "html_url": 'https://github.com/junaid2/photo-app',
          "description": 'A test app'
        },
        {
          "name": 'junaid2/photo-app2',
          "full_name": 'junaid2/photo-app2',
          "html_url": 'https://github.com/junaid2/photo-app2',
          "description": 'A test app'
        }
      ],
      "incomplete_results": false
    }
  end
end