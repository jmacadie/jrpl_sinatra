class App < Sinatra::Application
  get '/users/edit_credentials' do
    require_signed_in_user
    render_edit_user_page
  end

  post '/users/edit_credentials' do
    require_signed_in_user
    result = settings.edit_user_service.call(
      user_id: session[:user_id],
      current_password: params[:current_pword],
      details: {
        user_name: params[:user_name],
        email: params[:email],
        password: params[:pword],
        password_confirmation: params[:reenter_pword]
      }
    )
    return apply_edit_user_result(result) if result.success?

    session[:message] = result.message
    session[:message_level] = 'danger'
    status 422
    render_edit_user_page
  end

  get '/users/signin' do
    require_signed_out_user
    erb :signin
  end

  post '/users/signin' do
    require_signed_out_user
    session[:intended_route] ||= params['intended_route'] || '/'
    result = settings.sign_in_service.call(
      login: params[:login],
      password: params[:pword]
    )
    return apply_sign_in_result(result) if result.success?

    session[:message] = 'Invalid credentials.'
    session[:message_level] = 'danger'
    status 422
    erb :signin
  end

  post '/users/signout' do
    require_signed_in_user
    clear_cookies()
    session.clear
    session[:message] = 'You have been signed out.'
    session[:message_level] = 'info'
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
    result = settings.sign_up_service.call(
      details: {
        user_name: params[:user_name],
        email: params[:email],
        password: params[:pword],
        password_confirmation: params[:reenter_pword],
        bot_check: params[:bot_check]
      }
    )
    return apply_sign_up_result(result) if result.success?

    session[:message] = result.message
    session[:message_level] = 'danger'
    status 422
    erb :signup
  end

  # Admin functions

  post '/users/reset_pword' do
    require_signed_in_as_admin
    result = settings.reset_user_password_service.call(
      user_name: params[:user_name]
    )
    session[:message] = result.message
    session[:message_level] = 'info'
    if env['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest'
      '/'
    else
      redirect '/'
    end
  end

  post '/users/toggle_admin' do
    require_signed_in_as_admin
    settings.toggle_user_admin_service.call(
      user_id: params[:user_id],
      action: params[:button]
    )
    if env['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest'
      '/admin'
    else
      redirect '/admin'
    end
  end

  post '/users/delete' do
    require_signed_in_as_admin
    result = settings.delete_user_service.call(
      user_id: params[:user_id],
      current_user_id: session[:user_id]
    )
    session[:message] = result.message
    session[:message_level] = result.message_level
    redirect('/admin')
  end

  private

  def apply_sign_up_result(result)
    assign_signed_in_session(result)
    implement_cookies() if params.key?('remember_me')
    session[:message] = result.message
    redirect_user_input
  end

  def apply_sign_in_result(result)
    assign_signed_in_session(result)
    implement_cookies() if params.key?('remember_me')
    session[:message] = 'Welcome!'
    session[:message_level] = 'success'
    redirect_user_input
  end

  def assign_signed_in_session(result)
    session[:user_id] = result.user_id
    session[:user_name] = result.user_name
    session[:user_email] = result.email
    session[:user_roles] = result.roles
  end

  def apply_edit_user_result(result)
    session[:user_name] = result.user_name
    session[:user_email] = result.email
    session[:message] = result.message
    session[:message_level] = 'info'
    redirect '/'
  end

  def render_edit_user_page
    page = settings.edit_user_page_service.call(
      user_id: session[:user_id]
    )
    erb :edit_credentials, locals: { user: page.user }
  end

  def redirect_user_input
    route = session.delete(:intended_route)
    route = '/' unless route&.start_with?('/') && !route.start_with?('//')
    redirect route
  end
end
