require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  # rubocop: disable Metrics/AbcSize
  def test_view_administer_account_form_signed_out
    get '/users/edit_credentials', {}, signed_out_session
    assert_equal 302, last_response.status
    assert_includes session[:message], 'You must be signed in to do that.'
  end

  def test_view_administer_account_form_signed_in
    get '/users/edit_credentials', {}, admin_session

    assert_equal 200, last_response.status
    assert_includes body_text, 'Change username / e-mail:'
    assert_includes body_text, 'Change password: Leave blank to keep current'
    assert_includes body_text, 'Current password required for any changes:'
  end

  def test_change_username
    get '/users/edit_credentials', {}, non_admin_session
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'joe',
           email: 'clare@macadie.co.uk',
           pword: '',
           reenter_pword: '',
           authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'joe', session[:user_name]
    assert_equal 'The following have been updated: username.', session[:message]

    get '/'
    assert_includes body_text, 'Signed in as joe'
  end

  def test_change_username_strip_input
    get '/users/edit_credentials', {}, non_admin_session
    post '/users/edit_credentials',
         { current_pword: '   a ',
           user_name: '   joe ',
           email: 'clare@macadie.co.uk',
           pword: '',
           reenter_pword: '',
           authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'joe', session[:user_name]
    assert_equal 'The following have been updated: username.', session[:message]

    get '/'
    assert_includes body_text, 'Signed in as joe'
  end

  def test_change_username_to_blank
    get '/users/edit_credentials', {}, non_admin_session
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: '',
           email: 'clare@macadie.co.uk',
           pword: '',
           reenter_pword: '',
           authenticity_token: csrf_token }

    assert_equal 422, last_response.status
    assert_equal 'Clare Mac', session[:user_name]
    assert_includes body_text,
                    'Username cannot be blank! Please enter a username.'
  end

  def test_change_username_to_existing_username
    get '/users/edit_credentials', {}, non_admin_session
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'Maccas',
           email: 'clare@macadie.co.uk',
           pword: '',
           reenter_pword: '',
           authenticity_token: csrf_token }

    assert_equal 422, last_response.status
    assert_equal 'Clare Mac', session[:user_name]
    assert_includes body_text,
                    'That username already exists. ' \
                    'Please choose a different username.'
  end

  def test_change_pword_mismatched
    get '/users/edit_credentials', {}, non_admin_session
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'Clare Mac',
           email: 'clare@macadie.co.uk',
           pword: 'b',
           reenter_pword: 'c',
           authenticity_token: csrf_token }

    assert_equal 422, last_response.status
    assert_equal 'Clare Mac', session[:user_name]
    assert_includes body_text, 'The passwords do not match.'
  end

  # rubocop: disable Metrics/MethodLength
  def test_change_pword
    get '/users/edit_credentials', {}, non_admin_session
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'Clare Mac',
           email: 'clare@macadie.co.uk',
           pword: 'Qwerty90',
           reenter_pword: 'Qwerty90',
           authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'Clare Mac', session[:user_name]
    assert_equal 'The following have been updated: password.', session[:message]

    get '/'
    post '/users/signout', { authenticity_token: csrf_token }

    get '/users/signin'
    post '/users/signin',
         { login: 'Clare Mac',
           pword: 'Qwerty90',
           authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'Clare Mac', session[:user_name]
  end

  def test_change_pword_strip_input
    get '/users/edit_credentials', {}, non_admin_session
    post '/users/edit_credentials',
         { current_pword: ' a   ',
           user_name: 'Clare Mac',
           email: 'clare@macadie.co.uk',
           pword: ' Qwerty90 ',
           reenter_pword: '   Qwerty90 ',
           authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'Clare Mac', session[:user_name]
    assert_equal 'The following have been updated: password.', session[:message]

    get '/'
    post '/users/signout', { authenticity_token: csrf_token }

    get '/users/signin'
    post '/users/signin',
         { login: 'Clare Mac',
           pword: 'Qwerty90',
           authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'Clare Mac', session[:user_name]
  end
  # rubocop: enable Metrics/MethodLength

  def test_change_username_and_pword
    get '/users/edit_credentials', {}, non_admin_session
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'joe',
           email: 'clare@macadie.co.uk',
           pword: 'Qwerty90',
           reenter_pword: 'Qwerty90',
           authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'joe', session[:user_name]
    assert_equal 'The following have been updated: username, password.',
                 session[:message]

    get '/'
    post '/users/signout', { authenticity_token: csrf_token }

    get '/users/signin'
    post '/users/signin',
         { login: 'joe', pword: 'Qwerty90', authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'joe', session[:user_name]
  end

  def test_change_username_and_pword_strip
    get '/users/edit_credentials', {}, non_admin_session
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: '   joe   ',
           email: 'clare@macadie.co.uk',
           pword: ' Qwerty90',
           reenter_pword: '   Qwerty90 ',
           authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'joe', session[:user_name]
    assert_equal 'The following have been updated: username, password.',
                 session[:message]

    get '/'
    post '/users/signout', { authenticity_token: csrf_token }

    get '/users/signin'
    post '/users/signin',
         { login: 'joe', pword: 'Qwerty90', authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'joe', session[:user_name]
  end

  def test_change_username_and_pword_empty
    get '/users/edit_credentials', {}, non_admin_session
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: '   joe   ',
           email: 'clare@macadie.co.uk',
           pword: '   ',
           reenter_pword: '   ',
           authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'joe', session[:user_name]
    assert_equal 'The following have been updated: username.', session[:message]

    get '/'
    post '/users/signout', { authenticity_token: csrf_token }

    get '/users/signin'
    post '/users/signin',
         { login: 'joe', pword: 'a', authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'joe', session[:user_name]
  end

  def test_change_admin_pword
    get '/users/edit_credentials', {}, admin_session
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'Maccas',
           email: 'james.macadie@telerealtrillium.com',
           pword: 'b',
           reenter_pword: 'b',
           authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'Maccas', session[:user_name]
    assert_equal 'The following have been updated: password.', session[:message]

    get '/'
    post '/users/signout', { authenticity_token: csrf_token }

    get '/users/signin'
    post '/users/signin',
         { login: 'Maccas', pword: 'b', authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'Maccas', session[:user_name]
  end

  def test_change_user_credentials_pword_mismatched
    get '/users/edit_credentials', {}, non_admin_session
    post '/users/edit_credentials',
         { current_pword: 'wrong_pword',
           user_name: 'joe',
           email: 'clare@macadie.co.uk',
           pword: 'b',
           reenter_pword: 'b',
           authenticity_token: csrf_token }

    assert_equal 422, last_response.status
    assert_equal 'Clare Mac', session[:user_name]
    assert_includes body_text,
                    'That is not the correct current password. Try again!'
  end

  def test_change_user_credentials_nothing_changed
    get '/users/edit_credentials', {}, non_admin_session
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'Clare Mac',
           email: 'clare@macadie.co.uk',
           pword: '',
           reenter_pword: '',
           authenticity_token: csrf_token }

    assert_equal 422, last_response.status
    assert_equal 'Clare Mac', session[:user_name]
    assert_includes body_text, 'You have not changed any of your details.'
  end

  def test_change_email
    get '/users/edit_credentials', {}, non_admin_session
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'Clare Mac',
           email: 'new@email.com',
           pword: '',
           reenter_pword: '',
           authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'Clare Mac', session[:user_name]
    assert_equal 'new@email.com', session[:user_email]
    assert_equal 'The following have been updated: email.', session[:message]

    get '/'
    assert_includes body_text, 'Signed in as Clare Mac'
  end

  def test_change_invalid_email
    get '/users/edit_credentials', {}, non_admin_session
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'Clare Mac',
           email: 'joe',
           pword: '',
           reenter_pword: '',
           authenticity_token: csrf_token }

    assert_equal 422, last_response.status
    assert_includes body_text, 'That is not a valid email address.'
  end

  def test_change_blank_email
    get '/users/edit_credentials', {}, non_admin_session
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'Clare Mac',
           email: '',
           pword: '',
           reenter_pword: '',
           authenticity_token: csrf_token }

    assert_equal 422, last_response.status
    assert_includes body_text, 'Email cannot be blank! Please enter an email.'
  end

  def test_change_duplicate_email
    get '/users/edit_credentials', {}, non_admin_session
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'Clare Mac',
           email: 'mrmean@julianrimet.com',
           pword: '',
           reenter_pword: '',
           authenticity_token: csrf_token }

    assert_equal 422, last_response.status
    assert_includes body_text, 'That email address already exists.'
  end

  def test_change_username_and_email
    get '/users/edit_credentials', {}, non_admin_session
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'joe',
           email: 'new@email.com',
           pword: '',
           reenter_pword: '',
           authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'joe', session[:user_name]
    assert_equal 'new@email.com', session[:user_email]
    assert_equal 'The following have been updated: username, email.',
                 session[:message]

    get '/'
    assert_includes body_text, 'Signed in as joe'
  end

  # rubocop: disable Metrics/MethodLength
  def test_change_username_pword_and_email
    get '/users/edit_credentials', {}, non_admin_session
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'joe',
           email: 'new@email.com',
           pword: 'Qwerty90',
           reenter_pword: 'Qwerty90',
           authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'joe', session[:user_name]
    assert_equal 'new@email.com', session[:user_email]
    assert_equal 'The following have been updated: username, password, email.',
                 session[:message]

    get '/'
    post '/users/signout', { authenticity_token: csrf_token }

    get '/users/signin'
    post '/users/signin',
         { login: 'joe', pword: 'Qwerty90', authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'joe', session[:user_name]
  end

  def test_change_username_pword_and_email_strip
    get '/users/edit_credentials', {}, non_admin_session
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: '   joe ',
           email: '  new@email.com ',
           pword: 'Qwerty90  ',
           reenter_pword: ' Qwerty90 ',
           authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'joe', session[:user_name]
    assert_equal 'new@email.com', session[:user_email]
    assert_equal 'The following have been updated: username, password, email.',
                 session[:message]

    get '/'
    post '/users/signout', { authenticity_token: csrf_token }

    get '/users/signin'
    post '/users/signin',
         { login: 'joe', pword: 'Qwerty90', authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'joe', session[:user_name]
  end
  # rubocop: enable Metrics/MethodLength

  def test_change_email_capitalised
    get '/users/edit_credentials', {}, non_admin_session
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'Clare Mac',
           email: 'nEw@eMail.coM',
           pword: '',
           reenter_pword: '',
           authenticity_token: csrf_token }

    get '/'
    post '/users/signout', { authenticity_token: csrf_token }

    get '/users/signin'
    post '/users/signin',
         { login: 'new@email.com', pword: 'a', authenticity_token: csrf_token }
    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'Clare Mac', session[:user_name]
    get last_response['Location']
    assert_includes body_text, 'Signed in as Clare Mac'
  end
  # rubocop: enable Metrics/AbcSize
end
