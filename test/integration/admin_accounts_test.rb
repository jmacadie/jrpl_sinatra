require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_view_administer_accounts
    get '/admin', {}, admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Clare Mac'
    assert_includes body_text, 'Administer Users'
    assert_includes body_html,
                    '<button class="btn btn-sm btn-outline-success" ' \
                    'type="submit">Grant</button>'
    assert_includes body_html,
                    '<button class="btn btn-sm btn-outline-warning" ' \
                    'type="submit">Revoke</button>'
    assert_includes body_html,
                    '<button class="btn btn-sm btn-outline-secondary" ' \
                    'type="submit">Reset</button>'
  end

  def test_view_administer_accounts_not_admin
    get '/admin', {}, non_admin_session

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'You must be an administrator to do that.', session[:message]
  end

  # rubocop: disable Metrics/AbcSize
  def test_reset_pword_admin
    get '/admin', {}, admin_session
    post '/users/reset_pword',
         { user_name: 'Clare Mac', authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal "The password has been reset to 'jrpl' for Clare Mac.",
                 session[:message]
    get '/'
    post '/users/signout', { authenticity_token: csrf_token }

    get '/users/signin', {}, signed_out_session
    post '/users/signin',
         { login: 'Clare Mac', pword: 'jrpl', authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'Clare Mac', session[:user_name]
  end

  def test_reset_pword_not_admin
    get '/', {}, non_admin_session
    token = csrf_token
    post '/users/reset_pword',
         { user_name: 'Maccas', authenticity_token: token }

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'You must be an administrator to do that.', session[:message]
    refute_includes body_text,
                    "The password has been reset to 'jrpl' for Clare Mac."

    get '/'
    post '/users/signout', { authenticity_token: csrf_token }

    get '/users/signin', {}, signed_out_session
    post '/users/signin',
         { login: 'Clare Mac', pword: 'jrpl', authenticity_token: csrf_token }

    assert_equal 422, last_response.status
    assert_includes body_text, 'Invalid credentials'
  end

  def test_reset_pword_signed_out
    get '/users/signin', {}, signed_out_session
    token = csrf_token
    get '/admin'
    post '/users/reset_pword',
         { user_name: 'Maccas', authenticity_token: token }

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'You must be an administrator to do that.', session[:message]
    refute_includes body_text,
                    "The password has been reset to 'jrpl' for Clare MacAdie."

    get '/users/signin'
    post '/users/signin',
         { login: 'Clare Mac', pword: 'jrpl', authenticity_token: csrf_token }

    assert_equal 422, last_response.status
    assert_includes body_text, 'Invalid credentials'
  end

  # rubocop: disable Metrics/MethodLength
  def test_make_user_admin_then_not_admin
    get '/admin', {}, admin_session
    post '/users/toggle_admin',
         { user_id: '11',
           button: 'grant_admin',
           authenticity_token: csrf_token }

    get '/'
    post '/users/signout', { authenticity_token: csrf_token }

    get '/users/signin', {}, signed_out_session
    post '/users/signin',
         { login: 'Clare Mac', pword: 'a', authenticity_token: csrf_token }
    assert_includes session[:user_roles], 'Admin'

    get '/'
    post '/users/signout', { authenticity_token: csrf_token }

    get '/admin', {}, admin_session
    post '/users/toggle_admin',
         { user_id: '11',
           button: 'revoke_admin',
           authenticity_token: csrf_token }

    get '/'
    post '/users/signout', { authenticity_token: csrf_token }

    get '/users/signin', {}, signed_out_session
    post '/users/signin',
         { login: 'Clare Mac', pword: 'a', authenticity_token: csrf_token }
    assert_nil session[:user_roles]
  end
  # rubocop: enable Metrics/MethodLength, Metrics/AbcSize

  def test_make_user_admin_already_admin
    get '/admin', {}, admin_session
    post '/users/toggle_admin',
         { user_id: '11',
           button: 'grant_admin',
           authenticity_token: csrf_token }
    get '/admin'
    post '/users/toggle_admin',
         { user_id: '11',
           button: 'grant_admin',
           authenticity_token: csrf_token }

    get '/'
    post '/users/signout', { authenticity_token: csrf_token }

    get '/users/signin', {}, signed_out_session
    post '/users/signin',
         { login: 'Clare Mac', pword: 'a', authenticity_token: csrf_token }
    assert_includes session[:user_roles], 'Admin'
  end

  def test_make_user_not_admin_already_not_admin
    get '/admin', {}, admin_session
    post '/users/toggle_admin',
         { user_id: '11',
           button: 'revoke_admin',
           authenticity_token: csrf_token }

    get '/'
    post '/users/signout', { authenticity_token: csrf_token }

    get '/users/signin', {}, signed_out_session
    post '/users/signin',
         { login: 'Clare Mac', pword: 'a', authenticity_token: csrf_token }
    assert_nil session[:user_roles]
  end

  def test_role_deleted_at_signout
    get '/users/signin', {}, signed_out_session
    post '/users/signin',
         { login: 'Maccas', pword: 'a', authenticity_token: csrf_token }
    assert_equal 'Admin', session[:user_roles]

    get '/'
    post '/users/signout', { authenticity_token: csrf_token }

    get '/users/signin', {}, signed_out_session
    post '/users/signin',
         { login: 'Clare Mac', pword: 'a', authenticity_token: csrf_token }
    refute_equal 'Admin', session[:user_roles]
  end
end
