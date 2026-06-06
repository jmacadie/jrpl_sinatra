require_relative '../repositories/login'
require_relative '../repositories/users'

class App < Sinatra::Application
  include DBLogin
  include DBUsers

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
    user_name = extract_user_name(params[:login].strip)
    pword = params[:pword].strip
    if valid_credentials?(user_name, pword)
      user_id = user_id(user_name)
      setup_user_session_data(user_id)
      if params.keys.include?('remember_me')
        implement_cookies()
      end
      session[:message] = 'Welcome!'
      session[:message_level] = 'success'
      redirect_user_input()
    else
      session[:message] = 'Invalid credentials.'
      session[:message_level] = 'danger'
      status 422
      erb :signin
    end
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
    new_user_details = extract_user_details(params)
    session[:message] = signup_input_error(new_user_details)
    if session[:message].empty?
      upload_new_user_credentials(new_user_details)
      user_id = user_id(new_user_details[:user_name])
      setup_user_session_data(user_id)
      if params.keys.include?('remember_me')
        implement_cookies()
      end
      session[:message] = 'Your account has been created.'
      redirect_user_input()
    else
      session[:message_level] = 'danger'
      status 422
      erb :signup
    end
  end

  # Admin functions

  post '/users/reset_pword' do
    require_signed_in_as_admin
    user_name = params[:user_name]
    reset_pword(user_name)
    session[:message] =
      "The password has been reset to 'jrpl' for #{user_name}."
    session[:message_level] = 'info'
    if env['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest'
      '/'
    else
      redirect '/'
    end
  end

  post '/users/toggle_admin' do
    require_signed_in_as_admin
    user_id = params[:user_id].to_i
    button = params[:button]
    if button == 'grant_admin' && !user_admin?(user_id)
      assign_admin(user_id)
    elsif button == 'revoke_admin' && user_admin?(user_id)
      unassign_admin(user_id)
    end
    if env['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest'
      '/admin'
    else
      redirect '/admin'
    end
  end

  post '/users/delete' do
    require_signed_in_as_admin
    user_id = params[:user_id].to_i
    if user_id == session[:user_id]
      session[:message] = "You can't delete yourself, you lemon 🍋"
      session[:message_level] = 'danger'
      redirect('/admin')
    end

    user_name = user_name(user_id)
    if user_name
      delete_user(user_id)
      session[:message] = "#{user_name} is no longer with us 🕳️"
      session[:message_level] = 'warn'
    else
      session[:message] = "#{params[:user_id]} is not a valid user_id"
      session[:message_level] = 'danger'
    end

    redirect('/admin')
  end

  private

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
    @user = page.user
    erb :edit_credentials
  end

  def redirect_user_input
    route = session.delete(:intended_route)
    route = '/' unless route&.start_with?('/') && !route.start_with?('//')
    redirect route
  end
end
