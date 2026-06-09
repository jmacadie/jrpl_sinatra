module LoginCookies
  def implement_cookies
    set_series_id_cookie()
    set_token_cookie()
    settings.cookie_repository.save_new_cookie(
      session[:user_id],
      cookies[:series_id],
      cookies[:token]
    )
  end

  def clear_cookies
    settings.cookie_repository.delete_cookie_data(cookies[:series_id])
    delete_login_cookies
  end

  def signin_with_cookie?
    result = settings.remember_me_login_service.call(
      series_id: cookies[:series_id],
      token: cookies[:token]
    )
    delete_login_cookies if result.invalid_token?
    return false unless result.success?

    setup_user_session_data(result.user_id)
    set_token_cookie(token: result.new_token)
    true
  end

  private

  def delete_login_cookies
    cookies.delete(:series_id)
    cookies.delete(:token)
  end

  def set_series_id_cookie
    series_id_value = unique_random_string()
    response.set_cookie(
      'series_id',
      { value: series_id_value,
        path: '/',
        expires: Time.now + (30 * 24 * 60 * 60) } # one month from now
    )
  end

  def set_token_cookie(token: nil)
    token_value = token or SecureRandom.hex(32)
    response.set_cookie(
      'token',
      { value: token_value,
        path: '/',
        expires: Time.now + (30 * 24 * 60 * 60) } # one month from now
    )
  end

  def unique_random_string
    random_string = SecureRandom.hex(32)
    current_series = settings.cookie_repository.series_id_list
    while current_series.include?(random_string)
      random_string = SecureRandom.hex(32)
    end
    random_string
  end
end
