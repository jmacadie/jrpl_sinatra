get '/matches/all' do
  require_signed_in_user
  session[:criteria] = set_criteria_to_all_matches()
  @matches = load_matches()
  @stage_names = @storage.tournament_stage_names()
  erb :matches_list do
    erb :match_filter_form
  end
end

get '/matches/filter_form' do
  require_signed_in_user
  erb :match_filter_form
end

post '/matches/filter' do
  require_signed_in_user
  @stage_names = @storage.tournament_stage_names()
  session[:criteria] = extract_search_criteria(params)
  @matches = load_matches()
  if @matches.empty?
    session[:message] = 'No matches meet your criteria, please try again!'
  end
  erb :matches_list do
    erb :match_filter_form
  end
end