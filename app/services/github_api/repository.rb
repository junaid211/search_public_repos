module GithubApi
  class Repository
    include HTTParty
    base_uri 'https://api.github.com'
    DEFAULT_PER_PAGE = 100
    def initialize(search_term, page: 1)
      @search_term = search_term
      @page = page
    end

    def public_repos
      query = { query: { q: @search_term, per_page: DEFAULT_PER_PAGE, page: @page, sort: 'stars' } }
      response = self.class.get('/search/repositories', query)

      if response.code == 200
        parsed_response = JSON.parse(response.body)
        pages = total_pages(parsed_response['total_count'])
        items = repositories(parsed_response['items'], pages)
        error_message = nil
        return { repos: [], pages: 0, error_message: errors } if @page.to_i > pages

        { repos: items, pages: pages, error_message: error_message }
      else
        { repos: [], pages: 0, error_message: JSON.parse(response)['message'] }
      end
    end

    private

    def repositories(items, pages)
      return [] if pages.zero?

      items.map { |r| r.slice('full_name', 'html_url', 'description') }
    end

    def total_pages(items_count)
      return 0 if items_count.to_i.zero?

      (items_count.to_f / DEFAULT_PER_PAGE).ceil
    end
  end
end