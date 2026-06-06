require_relative '../repositories/users'
require_relative '../repositories/login'

module Loginable
  include DBUsers
  include DBLogin

  def email_list
    load_user_credentials.values.each_with_object([]) do |hash, arr|
      arr << hash[:email].downcase
    end
  end

  def extract_user_details(params)
    bot_check = params[:bot_check] || ''
    {
      user_name: params[:user_name].strip,
      email: params[:email].strip.downcase,
      pword: params[:pword].strip,
      reenter_pword: params[:reenter_pword].strip,
      bot_check: bot_check.strip
    }
  end

  def extract_user_name(login)
    user_name_from_email(login) || login
  end

  def input_email_error(email)
    if email == ''
      'Email cannot be blank! Please enter an email.'
    elsif email !~ URI::MailTo::EMAIL_REGEXP
      'That is not a valid email address.'
    elsif email_list.include?(email.downcase) &&
          session[:user_email] != email.downcase
      'That email address already exists.'
    end
  end

  def input_username_error(user_name)
    if load_user_credentials.keys.include?(user_name) &&
       session[:user_name] != user_name
      'That username already exists. Please choose a different username.'
    elsif user_name == ''
      'Username cannot be blank! Please enter a username.'
    end
  end

  def input_botcheck_error(bot_check)
    return if bot_check.downcase == 'jrpl'
    'You did not enter the magic four letters correctly. ' \
      'Either you are a bot, ' \
      'or your intelligence level is not sufficient to play here. ' \
      'Goodbye'
  end

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
    user_details = load_user_details(user_id)
    session[:user_id] = user_id
    session[:user_name] = user_details[:user_name]
    session[:user_email] = user_details[:email].downcase
    session[:user_roles] = user_details[:roles]
  end

  def signup_input_error(user_details)
    error = []
    error << input_username_error(user_details[:user_name])
    error << signup_pword_error(user_details)
    error << input_email_error(user_details[:email])
    error << input_botcheck_error(user_details[:bot_check])
    error.delete(nil)
    error.empty? ? '' : error.join(' ')
  end

  def signup_pword_error(user_details)
    if user_details[:pword] != user_details[:reenter_pword] &&
       user_details[:pword] != ''
      'The passwords do not match.'
    elsif user_details[:pword] == ''
      'Password cannot be blank! Please enter a password.'
    end
  end

  def user_is_admin?
    # &. Safe navigation - checks object exists before invoking the method
    session[:user_roles]&.include?('Admin')
  end

  def user_signed_in?
    session.key?(:user_name) || signin_with_cookie()
  end

  def valid_credentials?(user_name, pword)
    credentials = load_user_credentials
    if credentials.key?(user_name)
      bcrypt_pword = BCrypt::Password.new(credentials[user_name][:pword])
      bcrypt_pword == pword
    else
      false
    end
  end
end
