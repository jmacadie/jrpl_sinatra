module Loginable
  def require_signed_in_as_admin
    return if user_signed_in? && user_is_admin?
    session[:message] = 'You must be an administrator to do that.'
    session[:message_level] = 'danger'
    if !user_signed_in?
      session[:intended_route] = request.path_info
      redirect '/users/signin'
    end
    redirect '/'
  end

  def require_signed_in_user
    return if user_signed_in?
    session[:intended_route] = request.path_info
    session[:message] = 'You must be signed in to do that.'
    session[:message_level] = 'danger'
    redirect '/users/signin'
  end

  def require_signed_out_user
    return unless user_signed_in?
    session[:message] = 'You must be signed out to do that.'
    session[:message_level] = 'warning'
    redirect '/'
  end

  def setup_user_session_data(user_id)
    user_details = settings.user_repository.load_user_details(user_id)
    session[:user_id] = user_id
    session[:user_name] = user_details[:user_name]
    session[:user_email] = user_details[:email].downcase
    session[:user_roles] = user_details[:roles]
  end

  def user_is_admin?
    # &. Safe navigation - checks object exists before invoking the method
    session[:user_roles]&.include?('Admin')
  end

  def user_signed_in?
    return true if session[:user_name]

    signin_with_cookie?
  end
end
