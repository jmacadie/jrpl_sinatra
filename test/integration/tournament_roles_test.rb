require 'json'
require_relative '../helpers/test_helpers'

class TournamentRolesIntegrationTest < Minitest::Test
  include TestIntegrationMethods

  # rubocop: disable Metrics/AbcSize
  def test_view_tournament_roles
    get '/admin', {}, admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Tournament Roles'
    assert_includes body_text, 'Round of 16'
    assert_includes body_html,
                    '<form class="form-tournament-role" ' \
                    'method="post" action="/tournament_role">'
    assert_includes body_html, 'tournament-role-select'
    assert_includes body_html,
                    '<option value="0" class="fst-italic fw-light ' \
                    'text-body-tertiary" selected>Not yet selected</option>'
    assert_includes body_html, '<input type="hidden" name="role" value="25">'
  end
  # rubocop: enable Metrics/AbcSize

  def test_view_tournament_roles_not_admin
    get '/admin', {}, non_admin_session

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'You must be an administrator to do that.', session[:message]
  end

  # rubocop: disable Metrics/AbcSize
  def test_post_tournament_roles_not_admin
    get '/', {}, non_admin_session
    token = csrf_token
    get '/admin'
    post '/tournament_role',
         { role: '25', team: '4', authenticity_token: token }

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'You must be an administrator to do that.', session[:message]

    get '/fixtures'
    post '/fixtures', { st_r16: 'on', authenticity_token: token }
    assert_includes body_text, 'Winner Group A'
    refute_includes body_text, 'Switzerland vs. Winner Group E'
  end

  # rubocop: disable Metrics/MethodLength
  def test_post_tournament_roles_admin
    get '/fixtures', {}, admin_session
    post '/fixtures', { st_r16: 'on', authenticity_token: csrf_token }
    assert_includes body_text, 'Winner Group A'
    refute_includes body_text, 'Switzerland vs. Winner Group E'

    get '/admin'
    post '/tournament_role',
         { role: '25', team: '4', authenticity_token: csrf_token }
    assert_equal 200, last_response.status
    assert_equal 'application/json', last_response['Content-Type']
    assert_equal(
      {
        'message' => 'Winner Group A set to Switzerland',
        'status' => 'success',
        'reset' => false
      },
      JSON.parse(last_response.body)
    )

    get '/fixtures'
    post '/fixtures', { st_r16: 'on', authenticity_token: csrf_token }
    refute_includes body_text, 'Winner Group A'
    assert_includes body_text, 'Switzerland vs. Winner Group E'
  end
  # rubocop: enable Metrics/AbcSize, Metrics/MethodLength

  def test_set_and_unset_tournament_roles
    get '/admin', {}, admin_session
    post '/tournament_role',
         { role: '25', team: '4', authenticity_token: csrf_token }
    get '/admin'
    post '/tournament_role',
         { role: '25', team: '0', authenticity_token: csrf_token }

    get '/fixtures'
    post '/fixtures', { st_r16: 'on', authenticity_token: csrf_token }
    assert_includes body_text, 'Winner Group A'
    refute_includes body_text, 'Switzerland vs. Winner Group E'
  end

  # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
  def test_post_tournament_roles_duplicate_team_in_stage
    get '/admin', {}, admin_session
    post '/tournament_role',
         { role: '25', team: '4', authenticity_token: csrf_token }
    get '/admin', {}, admin_session
    post '/tournament_role',
         { role: '26', team: '4', authenticity_token: csrf_token }

    assert_equal 422, last_response.status
    assert_equal 'application/json', last_response['Content-Type']
    assert_equal(
      {
        'status' => 'danger',
        'message' => 'Switzerland is already selected for this stage'
      },
      JSON.parse(last_response.body)
    )

    assert_equal 4,
                 run_query(
                   'SELECT team_id FROM tournament_role ' \
                   'WHERE tournament_role_id = $1::int;',
                   25
                 ).first['team_id'].to_i
    assert_equal 0,
                 run_query(
                   'SELECT team_id FROM tournament_role ' \
                   'WHERE tournament_role_id = $1::int;',
                   26
                 ).first['team_id'].to_i
  end
  # rubocop: enable Metrics/MethodLength, Metrics/AbcSize

  def test_post_tournament_roles_role_too_low
    get '/admin', {}, admin_session
    post '/tournament_role',
         { role: '24', team: '4', authenticity_token: csrf_token }

    assert_equal 422, last_response.status
    assert_equal 'application/json', last_response['Content-Type']
    assert_equal(
      {
        'status' => 'danger',
        'message' => 'Invalid role number: 24'
      },
      JSON.parse(last_response.body)
    )
  end

  def test_post_tournament_roles_role_too_high
    get '/admin', {}, admin_session
    post '/tournament_role',
         { role: '55', team: '4', authenticity_token: csrf_token }

    assert_equal 422, last_response.status
    assert_equal 'application/json', last_response['Content-Type']
    assert_equal(
      {
        'status' => 'danger',
        'message' => 'Invalid role number: 55'
      },
      JSON.parse(last_response.body)
    )
  end

  # rubocop: disable Metrics/AbcSize
  def test_post_tournament_roles_team_too_low
    get '/admin', {}, admin_session
    post '/tournament_role',
         { role: '25', team: '-1', authenticity_token: csrf_token }

    assert_equal 422, last_response.status
    assert_equal 'application/json', last_response['Content-Type']
    assert_equal(
      {
        'status' => 'danger',
        'message' => 'Invalid team number: -1'
      },
      JSON.parse(last_response.body)
    )

    get '/fixtures'
    post '/fixtures', { st_r16: 'on', authenticity_token: csrf_token }
    assert_includes body_text, 'Winner Group A'
  end

  def test_post_tournament_roles_team_too_high
    get '/admin', {}, admin_session
    post '/tournament_role',
         { role: '25', team: '25', authenticity_token: csrf_token }

    assert_equal 422, last_response.status
    assert_equal 'application/json', last_response['Content-Type']
    assert_equal(
      {
        'status' => 'danger',
        'message' => 'Invalid team number: 25'
      },
      JSON.parse(last_response.body)
    )

    get '/fixtures'
    post '/fixtures', { st_r16: 'on', authenticity_token: csrf_token }
    assert_includes body_text, 'Winner Group A'
  end
  # rubocop: enable Metrics/AbcSize
end
