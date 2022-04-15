# frozen_string_literal: true

module GithubApi
  # A class to fetch the public Github repos through name, description and sorted by stars
  class Repository
    include HTTParty
    attr_reader :search_term, :page

    base_uri 'https://api.github.com'
    DEFAULT_PER_PAGE = 100
    def initialize(search_term, page: 1)
      @search_term = search_term
      @page = page
    end

    # TODO: Add retries in future if API responds slow or null
    def call
      response = fetch_repositories

      return { success: false, error_message: response['message'] } unless response.code == 200

      parse_response(response.body)
    end

    private

    def fetch_repositories
      query = { query: { q: search_term, per_page: DEFAULT_PER_PAGE, page: page, sort: 'stars' } }
      self.class.get('/search/repositories', query)
    end

    def parse_response(body)
      response = JSON.parse(body).with_indifferent_access
      pages = total_pages(response[:total_count])
      items = repositories(response[:items], pages)

      error_message = I18n.t('errors.no_result') if items.blank?
      { repos: items, pages: pages, success: true, error_message: error_message }
    end

    def repositories(items, pages)
      return [] if pages.zero?

      items.map { |r| r.slice(:full_name, :html_url, :description) }
    end

    def total_pages(items_count)
      return 0 if items_count.to_i.zero?

      (items_count.to_f / DEFAULT_PER_PAGE).ceil
    end
  end
end