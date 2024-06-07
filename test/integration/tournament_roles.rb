require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_view_tournament_roles
    get '/admin', {}, admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Tournament Roles'
    assert_includes body_text, 'Round of 16'
    assert_includes body_html, '<form class="form-inline form-tournament-role" method="post" action="/tournament_role">'
    assert_includes body_html, '<option value="0" selected>Not yet selected</option>'
    assert_includes body_html, '<input type="hidden" name="role" value="25">'
    assert_includes body_html, '<button type="submit" class="btn btn-warning">Update</button>'
  end

  def test_view_tournament_roles_not_admin
    get '/admin', {}, non_admin_session

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'You must be an administrator to do that.', session[:message]
  end

  def test_post_tournament_roles_not_admin
    post '/tournament_role', { role: '25', team: '4' }, non_admin_session

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'You must be an administrator to do that.', session[:message]

    get '/fixtures'
    post '/fixtures', { st_r16: 'on' }
    assert_includes body_text, 'Winner Group A'
    refute_includes body_text, 'Switzerland vs. Winner Group E'
  end

  def test_post_tournament_roles_admin
    get '/fixtures', {}, admin_session
    post '/fixtures', { st_r16: 'on' }
    assert_includes body_text, 'Winner Group A'
    refute_includes body_text, 'Switzerland vs. Winner Group E'

    get '/admin', {}, admin_session
    post '/tournament_role', { role: '25', team: '4' }, admin_session
    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']

    get '/fixtures'
    post '/fixtures', { st_r16: 'on' }
    refute_includes body_text, 'Winner Group A'
    assert_includes body_text, 'Switzerland vs. Winner Group E'
  end

  def test_set_and_unset_tournament_roles
    get '/admin', {}, admin_session
    post '/tournament_role', { role: '25', team: '4' }, admin_session
    post '/tournament_role', { role: '25', team: '0' }, admin_session

    get '/fixtures'
    post '/fixtures', { st_r16: 'on' }
    assert_includes body_text, 'Winner Group A'
    refute_includes body_text, 'Switzerland vs. Winner Group E'
  end

  def test_post_tournament_roles_role_too_low
    post '/tournament_role', { role: '24', team: '4' }, admin_session

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'Invalid role number: 24', session[:message]
  end

  def test_post_tournament_roles_role_too_high
    post '/tournament_role', { role: '55', team: '4' }, admin_session

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'Invalid role number: 55', session[:message]
  end

  def test_post_tournament_roles_team_too_low
    post '/tournament_role', { role: '25', team: '-1' }, admin_session

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'Invalid team number: -1', session[:message]

    get '/fixtures', {}, admin_session
    post '/fixtures', { st_r16: 'on' }
    assert_includes body_text, 'Winner Group A'
  end

  def test_post_tournament_roles_team_too_high
    post '/tournament_role', { role: '25', team: '25' }, admin_session

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'Invalid team number: 25', session[:message]

    get '/fixtures', {}, admin_session
    post '/fixtures', { st_r16: 'on' }
    assert_includes body_text, 'Winner Group A'
  end
end

