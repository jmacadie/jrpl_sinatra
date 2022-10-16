class App < Sinatra::Application
  get '/fixtures' do
    require_signed_in_user
    session[:criteria] = set_criteria_to_all_matches()
    @matches = load_matches()
    @stage_names = tournament_stage_names()
    @match_ids = @matches.map { |m| m[:match_id] }
    erb :fixtures
  end

  post '/fixtures' do
    require_signed_in_user
    @stage_names = tournament_stage_names()
    session[:criteria] = extract_search_criteria(params)
    @matches = load_matches()
    @match_ids = @matches.map { |m| m[:match_id] }
    if @matches.empty?
      session[:message] = 'No matches meet your criteria, please try again!'
    end
    erb :fixtures
  end
end
