require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_view_administer_accounts
    get '/admin', {}, admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Clare Mac'
    assert_includes body_text, 'Administer Users'
    assert_includes body_html, '<button type="submit">Grant</button>'
    assert_includes body_html, '<button type="submit">Revoke</button>'
    assert_includes body_html, '<button type="submit">Reset</button>'
  end

  def test_view_administer_accounts_not_admin
    get '/admin', {}, non_admin_session

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'You must be an administrator to do that.', session[:message]
  end

  def test_reset_pword_admin
    post '/users/reset_pword', { user_name: 'Clare Mac' }, admin_session

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal "The password has been reset to 'jrpl' for Clare Mac.",
                 session[:message]
    post '/users/signout'

    post '/users/signin', { login: 'Clare Mac', pword: 'jrpl' }, {}

    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message]
    assert_equal 'Clare Mac', session[:user_name]
  end

  def test_reset_pword_not_admin
    post '/users/reset_pword', { user_name: 'Maccas' }, non_admin_session

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'You must be an administrator to do that.', session[:message]
    refute_includes body_text,
                    "The password has been reset to 'jrpl' for Clare Mac."
    post '/users/signout'

    post '/users/signin', { login: 'Clare Mac', pword: 'jrpl' }, {}

    assert_equal 422, last_response.status
    assert_includes body_text, 'Invalid credentials'
  end

  def test_reset_pword_signed_out
    post '/users/reset_pword', { user_name: 'Maccas' }

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'You must be an administrator to do that.', session[:message]
    refute_includes body_text,
                    "The password has been reset to 'jrpl' for Clare MacAdie."
    post '/users/signout'

    post '/users/signin', { login: 'Clare Mac', pword: 'jrpl' }, {}

    assert_equal 422, last_response.status
    assert_includes body_text, 'Invalid credentials'
  end

  def test_make_user_admin_then_not_admin
    post '/users/toggle_admin', { user_id: '11', button: 'grant_admin' },
         admin_session
    post '/users/signout'
    post '/users/signin', { login: 'Clare Mac', pword: 'a' }, {}

    assert_includes session[:user_roles], 'Admin'

    post '/users/toggle_admin', { user_id: '11', button: 'revoke_admin' },
         admin_session
    post '/users/signout'
    post '/users/signin', { login: 'Clare Mac', pword: 'a' }, {}

    assert_nil session[:user_roles]
  end

  def test_make_user_admin_already_admin
    post '/users/toggle_admin', { user_id: '11', button: 'grant_admin' },
         admin_session
    post '/users/toggle_admin', { user_id: '11', button: 'grant_admin' },
         admin_session
    post '/users/signout'
    post '/users/signin', { login: 'Clare Mac', pword: 'a' }, {}

    assert_includes session[:user_roles], 'Admin'
  end

  def test_make_user_not_admin_already_not_admin
    post '/users/toggle_admin', { user_id: '11', button: 'revoke_admin' },
         admin_session
    post '/users/signout'
    post '/users/signin', { login: 'Clare Mac', pword: 'a' }, {}

    assert_nil session[:user_roles]
  end

  def test_role_deleted_at_signout
    post '/users/signin', { login: 'Maccas', pword: 'a' }, {}
    assert_equal 'Admin', session[:user_roles]
    post '/users/signout'
    post '/users/signin', { login: 'Clare Mac', pword: 'a' }, {}

    refute_equal 'Admin', session[:user_roles]
  end
end
