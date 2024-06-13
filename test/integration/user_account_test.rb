require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_view_administer_account_form_signed_out
    get '/users/edit_credentials'
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
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'joe',
           email: 'clare@macadie.co.uk',
           pword: '',
           reenter_pword: '' },
         non_admin_session

    assert_equal 302, last_response.status
    assert_equal 'joe', session[:user_name]
    assert_equal 'The following have been updated: username.', session[:message]

    get '/'
    assert_includes body_text, 'Signed in as joe'
  end

  def test_change_username_strip_input
    post '/users/edit_credentials',
         { current_pword: '   a ',
           user_name: '   joe ',
           email: 'clare@macadie.co.uk',
           pword: '',
           reenter_pword: '' },
         non_admin_session

    assert_equal 302, last_response.status
    assert_equal 'joe', session[:user_name]
    assert_equal 'The following have been updated: username.', session[:message]

    get '/'
    assert_includes body_text, 'Signed in as joe'
  end

  def test_change_username_to_blank
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: '',
           email: 'clare@macadie.co.uk',
           pword: '',
           reenter_pword: '' },
         non_admin_session

    assert_equal 422, last_response.status
    assert_equal 'Clare Mac', session[:user_name]
    assert_includes body_text,
                    'Username cannot be blank! Please enter a username.'
  end

  def test_change_username_to_existing_username
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'Maccas',
           email: 'clare@macadie.co.uk',
           pword: '',
           reenter_pword: '' },
         non_admin_session

    assert_equal 422, last_response.status
    assert_equal 'Clare Mac', session[:user_name]
    assert_includes body_text,
                    'That username already exists. Please choose a different username.'
  end

  def test_change_pword
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'Clare Mac',
           email: 'clare@macadie.co.uk',
           pword: 'Qwerty90',
           reenter_pword: 'Qwerty90' },
         non_admin_session

    assert_equal 302, last_response.status
    assert_equal 'Clare Mac', session[:user_name]
    assert_equal 'The following have been updated: password.', session[:message]

    post '/users/signout'
    post '/users/signin', { login: 'Clare Mac', pword: 'Qwerty90' }, {}

    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'Clare Mac', session[:user_name]
  end

  def test_change_pword_strip_input
    post '/users/edit_credentials',
         { current_pword: ' a   ',
           user_name: 'Clare Mac',
           email: 'clare@macadie.co.uk',
           pword: ' Qwerty90 ',
           reenter_pword: '   Qwerty90 ' },
         non_admin_session

    assert_equal 302, last_response.status
    assert_equal 'Clare Mac', session[:user_name]
    assert_equal 'The following have been updated: password.', session[:message]

    post '/users/signout'
    post '/users/signin', { login: 'Clare Mac', pword: 'Qwerty90' }, {}

    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'Clare Mac', session[:user_name]
  end

  def test_change_pword_mismatched
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'Clare Mac',
           email: 'clare@macadie.co.uk',
           pword: 'b',
           reenter_pword: 'c' },
         non_admin_session

    assert_equal 422, last_response.status
    assert_equal 'Clare Mac', session[:user_name]
    assert_includes body_text, 'The passwords do not match.'
  end

  def test_change_username_and_pword
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'joe',
           email: 'clare@macadie.co.uk',
           pword: 'Qwerty90',
           reenter_pword: 'Qwerty90' },
         non_admin_session

    assert_equal 302, last_response.status
    assert_equal 'joe', session[:user_name]
    assert_equal 'The following have been updated: username, password.',
                 session[:message]

    post '/users/signout'
    post '/users/signin', { login: 'joe', pword: 'Qwerty90' }, {}

    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'joe', session[:user_name]
  end

  def test_change_username_and_pword_strip
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: '   joe   ',
           email: 'clare@macadie.co.uk',
           pword: ' Qwerty90',
           reenter_pword: '   Qwerty90 ' },
         non_admin_session

    assert_equal 302, last_response.status
    assert_equal 'joe', session[:user_name]
    assert_equal 'The following have been updated: username, password.',
                 session[:message]

    post '/users/signout'
    post '/users/signin', { login: 'joe', pword: 'Qwerty90' }, {}

    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'joe', session[:user_name]
  end

  def test_change_username_and_pword_empty
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: '   joe   ',
           email: 'clare@macadie.co.uk',
           pword: '   ',
           reenter_pword: '   ' },
         non_admin_session

    assert_equal 302, last_response.status
    assert_equal 'joe', session[:user_name]
    assert_equal 'The following have been updated: username.', session[:message]

    post '/users/signout'
    post '/users/signin', { login: 'joe', pword: 'a' }, {}

    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'joe', session[:user_name]
  end

  def test_change_user_credentials_pword_mismatched
    post '/users/edit_credentials',
         { current_pword: 'wrong_pword',
           user_name: 'joe',
           email: 'clare@macadie.co.uk',
           pword: 'b',
           reenter_pword: 'b' },
         non_admin_session

    assert_equal 422, last_response.status
    assert_equal 'Clare Mac', session[:user_name]
    assert_includes body_text,
                    'That is not the correct current password. Try again!'
  end

  def test_change_user_credentials_nothing_changed
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'Clare Mac',
           email: 'clare@macadie.co.uk',
           pword: '',
           reenter_pword: '' },
         non_admin_session

    assert_equal 422, last_response.status
    assert_equal 'Clare Mac', session[:user_name]
    assert_includes body_text, 'You have not changed any of your details.'
  end

  def test_change_admin_pword
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'Maccas',
           email: 'james.macadie@telerealtrillium.com',
           pword: 'b',
           reenter_pword: 'b' },
         admin_session

    assert_equal 302, last_response.status
    assert_equal 'Maccas', session[:user_name]
    assert_equal 'The following have been updated: password.', session[:message]

    post '/users/signout'
    post '/users/signin', { login: 'Maccas', pword: 'b' }, {}

    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'Maccas', session[:user_name]
  end

  def test_change_email
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'Clare Mac',
           email: 'new@email.com',
           pword: '',
           reenter_pword: '' },
         non_admin_session

    assert_equal 302, last_response.status
    assert_equal 'Clare Mac', session[:user_name]
    assert_equal 'new@email.com', session[:user_email]
    assert_equal 'The following have been updated: email.', session[:message]

    get '/'
    assert_includes body_text, 'Signed in as Clare Mac'
  end

  def test_change_invalid_email
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'Clare Mac',
           email: 'joe',
           pword: '',
           reenter_pword: '' },
         non_admin_session

    assert_equal 422, last_response.status
    assert_includes body_text, 'That is not a valid email address.'
  end

  def test_change_blank_email
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'Clare Mac',
           email: '',
           pword: '',
           reenter_pword: '' },
         non_admin_session

    assert_equal 422, last_response.status
    assert_includes body_text, 'Email cannot be blank! Please enter an email.'
  end

  def test_change_duplicate_email
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'Clare Mac',
           email: 'mrmean@julianrimet.com',
           pword: '',
           reenter_pword: '' },
         non_admin_session

    assert_equal 422, last_response.status
    assert_includes body_text, 'That email address already exists.'
  end

  def test_change_username_and_email
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'joe',
           email: 'new@email.com',
           pword: '',
           reenter_pword: '' },
         non_admin_session

    assert_equal 302, last_response.status
    assert_equal 'joe', session[:user_name]
    assert_equal 'new@email.com', session[:user_email]
    assert_equal 'The following have been updated: username, email.',
                 session[:message]

    get '/'
    assert_includes body_text, 'Signed in as joe'
  end

  def test_change_username_pword_and_email
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'joe',
           email: 'new@email.com',
           pword: 'Qwerty90',
           reenter_pword: 'Qwerty90' },
         non_admin_session

    assert_equal 302, last_response.status
    assert_equal 'joe', session[:user_name]
    assert_equal 'new@email.com', session[:user_email]
    assert_equal 'The following have been updated: username, password, email.',
                 session[:message]

    post '/users/signout'
    post '/users/signin', { login: 'joe', pword: 'Qwerty90' }, {}

    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'joe', session[:user_name]
  end

  def test_change_username_pword_and_email_strip
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: '   joe ',
           email: '  new@email.com ',
           pword: 'Qwerty90  ',
           reenter_pword: ' Qwerty90 ' },
         non_admin_session

    assert_equal 302, last_response.status
    assert_equal 'joe', session[:user_name]
    assert_equal 'new@email.com', session[:user_email]
    assert_equal 'The following have been updated: username, password, email.',
                 session[:message]

    post '/users/signout'
    post '/users/signin', { login: 'joe', pword: 'Qwerty90' }, {}

    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'joe', session[:user_name]
  end

  def test_change_email_capitalised
    post '/users/edit_credentials',
         { current_pword: 'a',
           user_name: 'Clare Mac',
           email: 'nEw@eMail.coM',
           pword: '',
           reenter_pword: '' },
         non_admin_session

    post '/users/signout'
    post '/users/signin', { login: 'new@email.com', pword: 'a' }, {}
    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'Clare Mac', session[:user_name]
    get last_response['Location']
    assert_includes body_text, 'Signed in as Clare Mac'
  end

end
