require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_delete_user
    get '/tables'
    assert_includes body_text, 'DTM'

    get '/admin', {}, admin_session
    post '/users/delete', { user_id: '6' }

    assert_equal 302, last_response.status
    assert_equal 'DTM is no longer with us 🕳️', session[:message]

    get '/' # to clear the message that will have DTM in it first
    get '/tables'
    refute_includes body_text, 'DTM'
  end

  def test_delete_user_non_admin
    get '/tables'
    assert_includes body_text, 'DTM'

    get '/admin', {}, non_admin_session
    post '/users/delete', { user_id: '6' }

    assert_equal 302, last_response.status
    assert_equal 'You must be an administrator to do that.', session[:message]

    get '/'
    refute_includes body_text, 'DTM is no longer with us 🕳️'

    get '/tables'
    assert_includes body_text, 'DTM'
  end

  def test_delete_youself
    get '/tables'
    assert_includes body_text, 'Maccas'

    get '/admin', {}, admin_session
    post '/users/delete', { user_id: '4' }

    assert_equal 302, last_response.status
    assert_equal "You can't delete yourself, you lemon 🍋", session[:message]

    get '/' # to clear any message
    get '/tables'
    assert_includes body_text, 'Maccas'
  end

  def test_delete_bad_user_ids
    get '/admin', {}, admin_session

    post '/users/delete', { user_id: 'a' }
    assert_equal 302, last_response.status
    assert_equal 'a is not a valid user_id', session[:message]

    post '/users/delete', { user_id: '0' }
    assert_equal 302, last_response.status
    assert_equal '0 is not a valid user_id', session[:message]

    post '/users/delete', { user_id: '-1' }
    assert_equal 302, last_response.status
    assert_equal '-1 is not a valid user_id', session[:message]

    post '/users/delete', { user_id: '100' }
    assert_equal 302, last_response.status
    assert_equal '100 is not a valid user_id', session[:message]
  end
end
