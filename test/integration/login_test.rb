require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_signin_form
    get '/users/signin'
    assert_equal 200, last_response.status
    assert_includes body_html, '<input type="text" class="form-control" id="login" name="login"'
    assert_includes body_html, '<input type="password" class="form-control" id="pword" name="pword"'
    assert_includes body_html, '<button class="btn btn-lg btn-primary btn-block" type="submit" id="logInBtn">Log in</button>'
  end

  def test_signin_form_already_signed_in
    get '/users/signin', {}, non_admin_session
    assert_equal 302, last_response.status
    assert_equal 'You must be signed out to do that.', session[:message]
  end

  def test_signin
    post '/users/signin', { login: 'Maccas', pword: 'a' }, {}
    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'Maccas', session[:user_name]

    get last_response['Location']
    assert_includes body_text, 'Signed in as Maccas'
  end

  def test_signin_already_signed_in
    post '/users/signin', { login: 'Maccas', pword: 'a' }, non_admin_session
    assert_equal 302, last_response.status
    assert_equal 'You must be signed out to do that.', session[:message]
  end

  def test_signin_strip_input
    post '/users/signin', { login: '   Maccas  ', pword: ' a ' }, {}
    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'Maccas', session[:user_name]

    get last_response['Location']
    assert_includes body_text, 'Signed in as Maccas'
  end

  def test_signin_with_bad_credentials
    post '/users/signin', { login: 'guest', pword: 'shhhh' }, {}
    assert_equal 422, last_response.status
    assert_nil session[:user_name]
    assert_includes body_text, 'Invalid credentials.'
  end

  def test_signout
    get '/', {}, admin_session
    assert_equal 'Admin', session[:user_roles]

    post '/users/signout'
    assert_equal 'You have been signed out.', session[:message]

    get last_response['Location']
    assert_nil session[:user_name]
    assert_includes body_text, 'Sign In'
  end

  def test_signout_already_signed_out
    post '/users/signout'
    assert_equal 302, last_response.status
    assert_equal 'You must be signed in to do that.', session[:message]
  end

  def test_view_signup_form_signed_out
    get '/users/signup'
    assert_equal 200, last_response.status
    assert_includes body_html, 'Re-enter Password'
  end

  def test_view_signup_form_signed_in
    get '/users/signup', {}, admin_session
    assert_equal 302, last_response.status
    assert_equal 'You must be signed out to do that.', session[:message]
  end

  def test_signup_signed_out
    post '/users/signup',
         { user_name: 'joe', email: 'joe@joe.com', pword: 'Dfghiewo34334',
           reenter_pword: 'Dfghiewo34334' }
    assert_equal 302, last_response.status
    assert_equal 'Your account has been created.', session[:message]

    get '/'
    assert_includes body_text, 'Signed in as joe'
  end

  def test_signup_signed_out_strip_input
    post '/users/signup',
         { user_name: '   joe  ', email: 'joe@joe.com',
           pword: ' Dfghiewo34334    ', reenter_pword: '  Dfghiewo34334 ' }
    assert_equal 302, last_response.status
    assert_equal 'Your account has been created.', session[:message]

    get '/'
    assert_includes body_text, 'Signed in as joe'
  end

  def test_signup_signed_in
    post '/users/signup',
         { user_name: 'joe', email: 'joe@joe.com', pword: 'dfghiewo34334', reenter_pword: 'dfghiewo34334' }, admin_session
    assert_equal 302, last_response.status
    assert_equal 'You must be signed out to do that.', session[:message]
  end

  def test_signup_existing_username
    post '/users/signup',
         { user_name: 'Clare Mac', email: 'joe@joe.com',
           pword: 'dfghiewo34334', reenter_pword: 'dfghiewo34334' }
    assert_equal 422, last_response.status
    assert_includes body_text, 'That username already exists.'
  end

  def test_signup_blank_username
    post '/users/signup',
         { user_name: '', email: 'joe@joe.com', pword: 'dfghiewo34334',
           reenter_pword: 'dfghiewo34334' }
    assert_equal 422, last_response.status
    assert_includes body_text,
                    'Username cannot be blank! Please enter a username.'
  end

  def test_signup_blank_pword
    post '/users/signup',
         { user_name: 'joanna', email: 'joe@joe.com', pword: '',
           reenter_pword: '' }
    assert_equal 422, last_response.status
    assert_includes body_text,
                    'Password cannot be blank! Please enter a password.'
  end

  def test_signup_blank_username_and_pword
    post '/users/signup',
         { user_name: '', email: 'joe@joe.com', pword: '',
           reenter_pword: '' }
    assert_equal 422, last_response.status
    assert_includes body_text,
                    'Username cannot be blank! Please enter a username. Password cannot be blank! Please enter a password.'
  end

  def test_signup_mismatched_pwords
    post '/users/signup',
         { user_name: 'joanna', email: 'joe@joe.com',
           pword: 'dfghiewo34334', reenter_pword: 'mismatched' }
    assert_equal 422, last_response.status
    assert_includes body_text, 'The passwords do not match.'
  end

  def test_signup_invalid_email
    post '/users/signup',
         { user_name: 'joanna', email: 'joe', pword: 'dfghiewo34334',
           reenter_pword: 'dfghiewo34334' }
    assert_equal 422, last_response.status
    assert_includes body_text, 'That is not a valid email address.'
  end

  def test_signup_blank_email
    post '/users/signup',
         { user_name: 'joanna', email: '', pword: 'dfghiewo34334',
           reenter_pword: 'dfghiewo34334' }
    assert_equal 422, last_response.status
    assert_includes body_text,
                    'Email cannot be blank! Please enter an email.'
  end

  def test_signup_duplicate_email
    post '/users/signup',
         { user_name: 'joanna', email: 'clare@macadie.co.uk',
           pword: 'dfghiewo34334', reenter_pword: 'dfghiewo34334' }
    assert_equal 422, last_response.status
    assert_includes body_text, 'That email address already exists.'
  end
end
