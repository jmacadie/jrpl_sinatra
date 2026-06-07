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
    apply_fixtures_message(page)
    erb :fixtures,
        locals: {
          matches: page.matches,
          match_ids: page.match_ids,
          criteria: page.criteria
        }
  end

  def apply_fixtures_message(page)
    return if page.message.nil?

    session[:message] = page.message
    session[:message_level] = page.message_level
  end
end
