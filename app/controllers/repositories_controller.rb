class RepositoriesController < ApplicationController
	def search
		search_term = search_params&.dig(:search)

		if search_term.blank?
			@error = t('errors.no_search_term')

			return
		end

		result = GithubApi::Repository.new(search_term, page: search_params[:page]).call

		@error = result[:error_message]
		return unless result[:success]

		@repositories = result[:repos]
		@pages = result[:pages]
	end

	private

	def search_params
		params.require(:repos).permit(:search).merge(page: sanitize_page)
	end

	def sanitize_page
		current_page = params[:page].to_i
		return 1 if current_page < 1

		current_page
	end
end
