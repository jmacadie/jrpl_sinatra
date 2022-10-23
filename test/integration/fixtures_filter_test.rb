require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_filter_matches_all
    post '/fixtures',
         { :match_status => 'all', :prediction_status => 'all',
           "Group Stages" => "tournament_stage", "Round of 16" => "tournament_stage", "Quarter Finals" => "tournament_stage", "Semi Finals" => "tournament_stage", "Third Fourth Place Play-off" => "tournament_stage", "Final" => "tournament_stage" },
         non_admin_session

    assert_equal 200, last_response.status

    inc_matches = all_match_ids
    exc_matches = []
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_locked_down
    post '/fixtures',
         { :match_status => 'locked_down', :prediction_status => 'all',
           "Group Stages" => "tournament_stage", "Round of 16" => "tournament_stage", "Quarter Finals" => "tournament_stage", "Semi Finals" => "tournament_stage", "Third Fourth Place Play-off" => "tournament_stage", "Final" => "tournament_stage" },
         non_admin_session

    assert_equal 200, last_response.status

    inc_matches = (1..8).to_a
    exc_matches = all_match_ids - inc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_not_locked_down
    post '/fixtures',
         { :match_status => 'not_locked_down', :prediction_status => 'all',
           "Group Stages" => "tournament_stage", "Round of 16" => "tournament_stage", "Quarter Finals" => "tournament_stage", "Semi Finals" => "tournament_stage", "Third Fourth Place Play-off" => "tournament_stage", "Final" => "tournament_stage" },
         non_admin_session

    assert_equal 200, last_response.status

    exc_matches = (1..8).to_a
    inc_matches = all_match_ids - exc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_predicted
    post '/fixtures',
         { :match_status => 'all', :prediction_status => 'predicted',
           "Group Stages" => "tournament_stage", "Round of 16" => "tournament_stage", "Quarter Finals" => "tournament_stage", "Semi Finals" => "tournament_stage", "Third Fourth Place Play-off" => "tournament_stage", "Final" => "tournament_stage" },
         non_admin_session

    assert_equal 200, last_response.status

    inc_matches = [6, 7, 8, 11]
    exc_matches = all_match_ids - inc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_not_predicted
    post '/fixtures',
         { :match_status => 'all', :prediction_status => 'not_predicted',
           "Group Stages" => "tournament_stage", "Round of 16" => "tournament_stage", "Quarter Finals" => "tournament_stage", "Semi Finals" => "tournament_stage", "Third Fourth Place Play-off" => "tournament_stage", "Final" => "tournament_stage" },
         non_admin_session

    assert_equal 200, last_response.status

    exc_matches = [6, 7, 8, 11]
    inc_matches = all_match_ids - exc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_group_stages
    post '/fixtures',
         { :match_status => 'all', :prediction_status => 'all',
           "Group Stages" => "tournament_stage" },
         non_admin_session

    assert_equal 200, last_response.status

    inc_matches = (1..48).to_a
    exc_matches = all_match_ids - inc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_round_of_16
    post '/fixtures',
         { :match_status => 'all', :prediction_status => 'all',
           "Round of 16" => "tournament_stage" },
         non_admin_session

    assert_equal 200, last_response.status

    inc_matches = (49..56).to_a
    exc_matches = all_match_ids - inc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_quarter_finals
    post '/fixtures',
         { :match_status => 'all', :prediction_status => 'all',
           "Quarter Finals" => "tournament_stage" },
         non_admin_session

    assert_equal 200, last_response.status

    inc_matches = (57..60).to_a
    exc_matches = all_match_ids - inc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_semi_finals
    post '/fixtures',
         { :match_status => 'all', :prediction_status => 'all',
           "Semi Finals" => "tournament_stage" },
         non_admin_session

    assert_equal 200, last_response.status

    inc_matches = [61, 62]
    exc_matches = all_match_ids - inc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_3_4_place
    post '/fixtures',
         { :match_status => 'all', :prediction_status => 'all',
           "Third Fourth Place Play-off" => "tournament_stage" },
         non_admin_session

    assert_equal 200, last_response.status

    inc_matches = [63]
    exc_matches = all_match_ids - inc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_final
    post '/fixtures',
         { :match_status => 'all', :prediction_status => 'all',
           "Final" => "tournament_stage" },
         non_admin_session

    assert_equal 200, last_response.status

    inc_matches = [64]
    exc_matches = all_match_ids - inc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_group_stages_and_final
    post '/fixtures',
         { :match_status => 'all', :prediction_status => 'all',
           "Group Stages" => "tournament_stage", "Final" => "tournament_stage" },
         non_admin_session

    assert_equal 200, last_response.status

    inc_matches = (1..48).to_a + [64]
    exc_matches = all_match_ids - inc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_not_locked_down_predicted_group_stages
    post '/fixtures',
         { :match_status => 'not_locked_down', :prediction_status => 'predicted',
           "Group Stages" => "tournament_stage" },
         non_admin_session

    assert_equal 200, last_response.status

    inc_matches = [11]
    exc_matches = all_match_ids - inc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_locked_down_predicted_group_stages
    post '/fixtures',
         { :match_status => 'locked_down', :prediction_status => 'predicted',
           "Group Stages" => "tournament_stage" },
         non_admin_session

    assert_equal 200, last_response.status

    inc_matches = [6, 7, 8]
    exc_matches = all_match_ids - inc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_search_criteria_retained
    post '/fixtures',
         { :match_status => 'locked_down', :prediction_status => 'predicted',
           "Group Stages" => "tournament_stage" },
         non_admin_session

    assert_includes body_html, 'value="locked_down" checked'
    assert_includes body_html, 'value="predicted" checked'
    assert_includes body_html, 'name="Group Stages" value="tournament_stage" checked'
    refute_includes body_html, 'name="Final" value="tournament_stage" checked'
  end

  def test_filter_matches_no_matches_returned
    post '/fixtures',
         { :match_status => 'locked_down', :prediction_status => 'all',
           "Final" => "tournament_stage" },
         non_admin_session

    assert_includes body_text, 'No matches meet your criteria, please try again!'
    refute_includes body_text, 'Matches List'
  end

  private

  def fixtures_page_parts(includes_list, excludes_list)
    html = body_html
    includes_list.each do |match_id|
      assert_includes html, match_link(match_id)
    end
    excludes_list.each do |match_id|
      refute_includes html, match_link(match_id)
    end
  end

  def match_link(match_id)
    "<a href=\"/match/#{match_id}?ring="
  end

  def all_match_ids
    (1..64).to_a
  end
end
