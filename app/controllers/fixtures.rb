class App < Sinatra::Application
  get '/fixtures' do
    require_signed_in_user
    render_fixtures(criteria: session[:criteria])
  end

  post '/fixtures' do
    require_signed_in_user
    render_fixtures(submitted_params: params)
  end

  private

  def render_fixtures(criteria: nil, submitted_params: nil)
    page = settings.fixtures_page_service.call(
      user_id: session[:user_id],
      criteria:,
      submitted_params:
    )
    session[:criteria] = page.criteria
    assign_fixtures_page(page)
    apply_fixtures_message(page)
    erb :fixtures
  end

  def assign_fixtures_page(page)
    @matches = page.matches
    @stage_names = page.stage_names
    @match_ids = page.match_ids
  end

  def apply_fixtures_message(page)
    return if page.message.nil?

    session[:message] = page.message
    session[:message_level] = page.message_level
  end
end
