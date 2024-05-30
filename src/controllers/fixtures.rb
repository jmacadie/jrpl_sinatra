class App < Sinatra::Application
  get '/fixtures' do
    require_signed_in_user
    session[:criteria] ||= default_criteria
    @matches = @storage.get_matches_full(session[:criteria], session[:user_id])
    @stage_names = tournament_stage_names()
    @match_ids = @matches.map { |m| m[:match_id] }
    erb :fixtures
  end

  post '/fixtures' do
    require_signed_in_user
    @stage_names = tournament_stage_names()
    session[:criteria] = process_params()
    @matches = @storage.get_matches_full(session[:criteria], session[:user_id])
    @match_ids = @matches.map { |m| m[:match_id] }
    if @matches.empty?
      session[:message] = 'No matches meet your criteria, please try again!'
      session[:message_level] = 'warning'
    end
    erb :fixtures
  end

  private

  # rubocop:disable Metrics/MethodLength
  def process_params
    {
      exclude_played: param_posted?('exc_play'),
      exclude_predicted: param_posted?('exc_pred'),
      stages: {
        group: param_posted?('st_gr'),
        round16: param_posted?('st_r16'),
        quarter_final: param_posted?('st_qf'),
        semi_final: param_posted?('st_sf'),
        final: param_posted?('st_f')
      },
      groups: {
        A: param_posted?('gr_A'),
        B: param_posted?('gr_B'),
        C: param_posted?('gr_C'),
        D: param_posted?('gr_D'),
        E: param_posted?('gr_E'),
        F: param_posted?('gr_F')
      }
    }
  end
  # rubocop:enable Metrics/MethodLength

  def param_posted?(param_str)
    params[param_str] == 'on'
  end

  # rubocop:disable Metrics/MethodLength
  def default_criteria
    {
      exclude_played: true,
      exclude_predicted: false,
      stages: {
        group: true,
        round16: true,
        quarter_final: true,
        semi_final: true,
        final: true
      },
      groups: {
        A: true,
        B: true,
        C: true,
        D: true,
        E: true,
        F: true
      }
    }
  end
  # rubocop:enable Metrics/MethodLength
end
