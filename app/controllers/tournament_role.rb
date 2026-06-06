class App < Sinatra::Application
  post '/tournament_role' do
    require_signed_in_as_admin
    result = settings.tournament_role_service.call(
      role_id: params[:role].to_i,
      team_id: params[:team].to_i
    )
    content_type :json
    unless result.success?
      status 422
      return { status: result.status, message: result.message }.to_json
    end

    {
      message: result.message,
      status: result.status,
      reset: result.reset
    }.to_json
  end
end
