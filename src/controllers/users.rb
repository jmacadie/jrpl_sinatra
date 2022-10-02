class App < Sinatra::Application
  get '/users/administer_accounts' do
    require_signed_in_as_admin
    @users = @storage.load_all_users_details
    erb :administer_accounts
  end

  get '/users/edit_credentials' do
    require_signed_in_user
    erb :edit_credentials
  end

  post '/users/edit_credentials' do
    require_signed_in_user
    current_pword = params[:current_pword].strip
    new_user_details = extract_user_details(params)
    session[:message] = edit_login_error(new_user_details, current_pword)
    if session[:message].empty?
      update_user_credentials(new_user_details)
      redirect '/'
    else
      status 422
      erb :edit_credentials
    end
  end

  post '/users/reset_pword' do
    require_signed_in_as_admin
    user_name = params[:user_name]
    @storage.reset_pword(user_name)
    session[:message] =
      "The password has been reset to 'jrpl' for #{user_name}."
    if env['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest'
      '/'
    else
      redirect '/'
    end
  end

  get '/users/signin' do
    require_signed_out_user
    erb :signin
  end

  post '/users/signin' do
    require_signed_out_user
    session[:intended_route] ||= params['intended_route'] || '/'
    user_name = extract_user_name(params[:login].strip)
    pword = params[:pword].strip
    if valid_credentials?(user_name, pword)
      user_id = @storage.user_id(user_name)
      setup_user_session_data(user_id)
      if params.keys.include?('remember_me')
        implement_cookies()
      end
      session[:message] = 'Welcome!'
      redirect(session[:intended_route])
    else
      session[:message] = 'Invalid credentials.'
      status 422
      erb :signin
    end
  end

  post '/users/signout' do
    require_signed_in_user
    clear_cookies()
    session.clear
    session[:message] = 'You have been signed out.'
    if env['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest'
      '/'
    else
      redirect '/'
    end
  end

  get '/users/signup' do
    require_signed_out_user
    erb :signup
  end

  post '/users/signup' do
    require_signed_out_user
    session[:intended_route] ||= params['intended_route'] || '/'
    new_user_details = extract_user_details(params)
    session[:message] = signup_input_error(new_user_details)
    if session[:message].empty?
      @storage.upload_new_user_credentials(new_user_details)
      user_id = @storage.user_id(new_user_details[:user_name])
      setup_user_session_data(user_id)
      if params.keys.include?('remember_me')
        implement_cookies()
      end
      session[:message] = 'Your account has been created.'
      redirect(session[:intended_route])
    else
      status 422
      erb :signup
    end
  end

  post '/users/toggle_admin' do
    require_signed_in_as_admin
    user_id = params[:user_id].to_i
    button = params[:button]
    if button == 'grant_admin' && !@storage.user_admin?(user_id)
      @storage.assign_admin(user_id)
    elsif button == 'revoke_admin' && @storage.user_admin?(user_id)
      @storage.unassign_admin(user_id)
    end
    if env['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest'
      '/users/administer_accounts'
    else
      redirect '/users/administer_accounts'
    end
  end
end
