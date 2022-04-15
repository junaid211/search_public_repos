require "rails_helper"

RSpec.describe ::GithubApi::Repository, type: :service do
  describe '#call with positive response' do
    before do
      response = {
        "total_count":  2,
        "items": [
          {
             "name": "junaid2/photo-app",
             "full_name": "junaid2/photo-app",
             "private": false,
             "owner": {
                "login": "junaid2",
                 "id": 26313925345612,
                 "node_id": "12345"
                },
             "html_url": "https://github.com/junaid2/photo-app",
             "description": "A test app",
          },
          {
             "name": "junaid2/photo-app2",
             "full_name": "junaid2/photo-app2",
             "private": false,
             "owner": {
                "login": "junaid2",
                 "id": 263139253456122,
                 "node_id": "123453"
                },
             "html_url": "https://github.com/junaid2/photo-app2",
             "description": "A test app",
          }
        ],
        "incomplete_results": false
      }
      stub_request(:any, "https://api.github.com/search/repositories?page=1&per_page=100&q=search&sort=stars").
      to_return(status: 200, body: response.to_json)
    end

    it 'validates the results for search' do
      result = described_class.new('search', page: 1).public_repos

      expect(result[:repos]).to be_kind_of(Array)
      expect(result[:repos].count).to eq(2)
      expect(result[:repos].first.keys).to eq(['full_name', 'html_url', 'description'])
      expect(result[:pages]).to be_kind_of(Integer)
      expect(result[:pages]).to eq(1)
      expect(result[:error_message]).to be_nil
    end
  end

  describe '#call with 404' do
    before do
      response = { message: 'Not Found' }
      stub_request(:get, "https://api.github.com/search/repositories?page=1&per_page=100&q=search&sort=stars").
      to_return(status: 404, body: response.to_json)
    end

    it 'returns empty repos on 404' do
      result = described_class.new('search', page: 1).public_repos

      expect(result[:repos]).to eq([])
      expect(result[:pages]).to be_kind_of(Integer)
      expect(result[:pages]).to eq(0)
      expect(result[:error_message]).to eq('Not Found')
    end
  end
end
