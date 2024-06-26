require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_view_match_not_lockdown_no_pred_not_admin
    get '/match/50', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text,
                    'Winner Quarter-Final 3 Show Origin vs. Winner Quarter-Final 4 Show Origin'
    refute_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_score" name="home_score" value='
    refute_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_score" name="away_score" value='
    refute_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_res">Submit</button>'
    refute_includes body_text,
                    'Match locked down. No more updates to predictions possible'
    refute_includes body_html,
                    '<form class="hidden-xs" id="prediction" role="form" action="/match/add_prediction" method="post"> <fieldset disabled>'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_team_prediction" name="home_team_prediction" value="no prediction">'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_team_prediction" name="away_team_prediction" value="no prediction">'
    assert_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_pred"> Submit </button>'
  end

  def test_view_match_not_lockdown_no_pred_admin
    get '/match/51', {}, admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text,
                    'Winner Semi-Final 1 Show Origin vs. Winner Semi-Final 2 Show Origin'
    refute_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_score" name="home_score" value='
    refute_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_score" name="away_score" value='
    refute_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_res">Submit</button>'
    refute_includes body_text,
                    'Match locked down. No more updates to predictions possible'
    refute_includes body_html,
                    '<form class="hidden-xs" id="prediction" role="form" action="/match/add_prediction" method="post"> <fieldset disabled>'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_team_prediction" name="home_team_prediction" value="no prediction">'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_team_prediction" name="away_team_prediction" value="no prediction">'
    assert_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_pred"> Submit </button>'
  end

  def test_view_match_not_lockdown_prediction_not_admin
    get '/match/11', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Turkey vs. Georgia'
    refute_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_score" name="home_score" value='
    refute_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_score" name="away_score" value='
    refute_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_res">Submit</button>'
    refute_includes body_text,
                    'Match locked down. No more updates to predictions possible'
    refute_includes body_html,
                    '<form class="hidden-xs" id="prediction" role="form" action="/match/add_prediction" method="post"> <fieldset disabled>'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_team_prediction" name="home_team_prediction" value="77">'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_team_prediction" name="away_team_prediction" value="78">'
    assert_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_pred"> Submit </button>'
  end

  def test_view_match_not_lockdown_prediction_admin
    get '/match/12', {}, admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Portugal vs. Czech Republic'
    refute_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_score" name="home_score" value='
    refute_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_score" name="away_score" value='
    refute_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_res">Submit</button>'
    refute_includes body_text,
                    'Match locked down. No more updates to predictions possible'
    refute_includes body_html,
                    '<form class="hidden-xs" id="prediction" role="form" action="/match/add_prediction" method="post"> <fieldset disabled>'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_team_prediction" name="home_team_prediction" value="88">'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_team_prediction" name="away_team_prediction" value="89">'
    assert_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_pred"> Submit </button>'
  end

  def test_view_match_lockdown_no_pred_no_result_not_admin
    get '/match/3', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Spain vs. Croatia'
    refute_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_score" name="home_score" value='
    refute_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_score" name="away_score" value='
    refute_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_res">Submit</button>'
    assert_includes body_text,
                    'Match locked down. No more updates to predictions possible'
    assert_includes body_html,
                    '<form class="hidden-xs" id="prediction" role="form" action="/match/add_prediction" method="post"> <fieldset disabled>'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_team_prediction" name="home_team_prediction" value="no prediction">'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_team_prediction" name="away_team_prediction" value="no prediction">'
    assert_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_pred"> Submit </button>'
  end

  def test_view_match_lockdown_no_pred_no_result_admin
    get '/match/3', {}, admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Spain vs. Croatia'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_score" name="home_score" value="">'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_score" name="away_score" value="">'
    assert_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_res">Submit</button>'
    assert_includes body_text,
                    'Match locked down. No more updates to predictions possible'
    assert_includes body_html,
                    '<form class="hidden-xs" id="prediction" role="form" action="/match/add_prediction" method="post"> <fieldset disabled>'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_team_prediction" name="home_team_prediction" value="no prediction">'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_team_prediction" name="away_team_prediction" value="no prediction">'
    assert_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_pred"> Submit </button>'
  end

  def test_view_match_lockdown_prediction_no_result_not_admin
    get '/match/6', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Slovenia vs. Denmark'
    refute_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_score" name="home_score" value='
    refute_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_score" name="away_score" value='
    refute_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_res">Submit</button>'
    assert_includes body_text,
                    'Match locked down. No more updates to predictions possible'
    assert_includes body_html,
                    '<form class="hidden-xs" id="prediction" role="form" action="/match/add_prediction" method="post"> <fieldset disabled>'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_team_prediction" name="home_team_prediction" value="71">'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_team_prediction" name="away_team_prediction" value="72">'
    assert_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_pred"> Submit </button>'
  end

  def test_view_match_lockdown_prediction_no_result_admin
    get '/match/6', {}, admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Slovenia vs. Denmark'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_score" name="home_score" value="">'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_score" name="away_score" value="">'
    assert_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_res">Submit</button>'
    assert_includes body_text,
                    'Match locked down. No more updates to predictions possible'
    assert_includes body_html,
                    '<form class="hidden-xs" id="prediction" role="form" action="/match/add_prediction" method="post"> <fieldset disabled>'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_team_prediction" name="home_team_prediction" value="81">'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_team_prediction" name="away_team_prediction" value="82">'
    assert_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_pred"> Submit </button>'
  end

  def test_view_match_lockdown_no_pred_result_not_admin
    get '/match/1', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Germany 6 vs. 3 Scotland'
    refute_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_score" name="home_score" value='
    refute_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_score" name="away_score" value='
    refute_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_res">Submit</button>'
    assert_includes body_text,
                    'Match locked down. No more updates to predictions possible'
    assert_includes body_html,
                    '<form class="hidden-xs" id="prediction" role="form" action="/match/add_prediction" method="post"> <fieldset disabled>'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_team_prediction" name="home_team_prediction" value="no prediction">'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_team_prediction" name="away_team_prediction" value="no prediction">'
    assert_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_pred"> Submit </button>'
  end

  def test_view_match_lockdown_no_pred_result_admin
    get '/match/1', {}, admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Germany 6 vs. 3 Scotland'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_score" name="home_score" value="6">'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_score" name="away_score" value="3">'
    assert_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_res">Submit</button>'
    assert_includes body_text,
                    'Match locked down. No more updates to predictions possible'
    assert_includes body_html,
                    '<form class="hidden-xs" id="prediction" role="form" action="/match/add_prediction" method="post"> <fieldset disabled>'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_team_prediction" name="home_team_prediction" value="no prediction">'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_team_prediction" name="away_team_prediction" value="no prediction">'
    assert_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_pred"> Submit </button>'
  end

  def test_view_match_lockdown_prediction_result_not_admin
    get '/match/8', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Romania 63 vs. 64 Ukraine'
    refute_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_score" name="home_score" value='
    refute_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_score" name="away_score" value='
    refute_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_res">Submit</button>'
    assert_includes body_text,
                    'Match locked down. No more updates to predictions possible'
    assert_includes body_html,
                    '<form class="hidden-xs" id="prediction" role="form" action="/match/add_prediction" method="post"> <fieldset disabled>'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_team_prediction" name="home_team_prediction" value="73">'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_team_prediction" name="away_team_prediction" value="74">'
    assert_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_pred"> Submit </button>'
  end

  def test_view_match_lockdown_prediction_result_admin
    get '/match/8', {}, admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Romania 63 vs. 64 Ukraine'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_score" name="home_score" value="63">'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_score" name="away_score" value="64">'
    assert_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_res">Submit</button>'
    assert_includes body_text,
                    'Match locked down. No more updates to predictions possible'
    assert_includes body_html,
                    '<form class="hidden-xs" id="prediction" role="form" action="/match/add_prediction" method="post"> <fieldset disabled>'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="home_team_prediction" name="home_team_prediction" value="83">'
    assert_includes body_html,
                    '<input type="number" min="0" class="form-control" id="away_team_prediction" name="away_team_prediction" value="84">'
    assert_includes body_html,
                    '<button class="btn btn-sm btn-primary" type="submit" id="btn_submit_pred"> Submit </button>'
  end

  def test_view_single_match_signed_in
    get '/match/11', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Group Stages'
    assert_includes body_text, 'Turkey'
    assert_includes body_text, 'Georgia'
  end

  def test_view_single_match_signed_in_tournament_role
    get '/match/51', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Final'
    assert_includes body_text, 'Winner Semi-Final 1'
    assert_includes body_text, 'Winner Semi-Final 2'
  end
end
