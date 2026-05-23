require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_signin_form
    get '/users/signin'
    assert_equal 200, last_response.status
    assert_includes body_html,
                    '<input type="text" class="form-control" ' \
                    'id="login" name="login"'
    assert_includes body_html,
                    '<input type="password" class="form-control" ' \
                    'id="pword" name="pword"'
    assert_includes body_html,
                    '<button class="btn btn-lg btn-primary w-100" ' \
                    'type="submit" id="logInBtn">Log in</button>'
  end

  def test_signin_form_already_signed_in
    get '/users/signin', {}, non_admin_session
    assert_equal 302, last_response.status
    assert_equal 'You must be signed out to do that.', session[:message]
  end

  def test_signin
    get '/users/signin', {}, signed_out_session
    post '/users/signin',
         { login: 'Maccas',
           pword: 'a',
           authenticity_token: csrf_token }
    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'Maccas', session[:user_name]

    get last_response['Location']
    assert_includes body_text, 'Signed in as Maccas'
  end

  def test_signin_with_email
    get '/users/signin', {}, signed_out_session
    post '/users/signin',
         { login: 'james.macadie@telerealtrillium.com',
           pword: 'a',
           authenticity_token: csrf_token }
    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'Maccas', session[:user_name]

    get last_response['Location']
    assert_includes body_text, 'Signed in as Maccas'
  end

  def test_signin_already_signed_in
    get '/', {}, non_admin_session
    token = csrf_token
    get '/users/signin'
    post '/users/signin',
         { login: 'Maccas',
           pword: 'a',
           authenticity_token: token }
    assert_equal 302, last_response.status
    assert_equal 'You must be signed out to do that.', session[:message]
  end

  def test_signin_strip_input
    get '/users/signin', {}, signed_out_session
    post '/users/signin',
         { login: '   Maccas  ',
           pword: ' a ',
           authenticity_token: csrf_token }
    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'Maccas', session[:user_name]

    get last_response['Location']
    assert_includes body_text, 'Signed in as Maccas'
  end

  def test_signin_with_bad_credentials
    get '/users/signin', {}, signed_out_session
    post '/users/signin',
         { login: 'guest',
           pword: 'shhhh',
           authenticity_token: csrf_token }
    assert_equal 422, last_response.status
    assert_nil session[:user_name]
    assert_includes body_text, 'Invalid credentials.'
  end

  def test_signin_capitalised_email
    get '/users/signin', {}, signed_out_session
    post '/users/signin',
         { login: 'James.MacAdie@TeLeReAlTrIlLIuM.com',
           pword: 'a',
           authenticity_token: csrf_token }
    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'Maccas', session[:user_name]

    get last_response['Location']
    assert_includes body_text, 'Signed in as Maccas'
  end

  def test_signout
    get '/', {}, admin_session
    assert_equal 'Admin', session[:user_roles]

    post '/users/signout', { authenticity_token: csrf_token }
    assert_equal 'You have been signed out.', session[:message]

    get last_response['Location']
    assert_nil session[:user_name]
    assert_includes body_text, 'Sign In'
  end

  def test_signout_already_signed_out
    get '/users/signin'
    post '/users/signout', { authenticity_token: csrf_token }
    assert_equal 302, last_response.status
    assert_equal 'You must be signed in to do that.', session[:message]
  end
end
