class RepositoriesController < ApplicationController
  def index
    search_term = params.dig(:repos, :search)
    if search_term.present?
      params_page = params.dig(:page)
      page = params_page.present? ? params_page : 1
      result = GithubApi::Repository.new(search_term, page: page).public_repos
      @repositories = result[:repos]
      @pages = result[:pages]
      @error = result[:error_message]
    end
  end
end
