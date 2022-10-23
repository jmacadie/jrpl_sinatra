require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_filter_matches_all
    get '/fixtures', {}, non_admin_session
    post '/fixtures',
         { st_gr: 'on', st_r16: 'on', st_qf: 'on', st_sf: 'on', st_f: 'on',
           gr_A: 'on', gr_B: 'on', gr_C: 'on', gr_D: 'on', gr_E: 'on', gr_F: 'on', gr_G: 'on', gr_H: 'on' }
         non_admin_session

    assert_equal 200, last_response.status

    inc_matches = all_match_ids
    exc_matches = []
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_not_predicted
    get '/fixtures', {}, non_admin_session
    post '/fixtures',
         { exc_pred: 'on',
           st_gr: 'on', st_r16: 'on', st_qf: 'on', st_sf: 'on', st_f: 'on',
           gr_A: 'on', gr_B: 'on', gr_C: 'on', gr_D: 'on', gr_E: 'on', gr_F: 'on', gr_G: 'on', gr_H: 'on' }
         non_admin_session

    assert_equal 200, last_response.status

    exc_matches = [6, 7, 8, 11, 63, 64]
    inc_matches = all_match_ids - exc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_not_played
    get '/fixtures', {}, non_admin_session
    post '/fixtures',
         { exc_play: 'on',
           st_gr: 'on', st_r16: 'on', st_qf: 'on', st_sf: 'on', st_f: 'on',
           gr_A: 'on', gr_B: 'on', gr_C: 'on', gr_D: 'on', gr_E: 'on', gr_F: 'on', gr_G: 'on', gr_H: 'on' }
         non_admin_session

    assert_equal 200, last_response.status

    exc_matches = [1, 2, 7, 8]
    inc_matches = all_match_ids - exc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_not_played_not_predicted
    get '/fixtures', {}, non_admin_session
    post '/fixtures',
         { exc_pred: 'on', exc_play: 'on',
           st_gr: 'on', st_r16: 'on', st_qf: 'on', st_sf: 'on', st_f: 'on',
           gr_A: 'on', gr_B: 'on', gr_C: 'on', gr_D: 'on', gr_E: 'on', gr_F: 'on', gr_G: 'on', gr_H: 'on' }
         non_admin_session

    assert_equal 200, last_response.status

    exc_matches = [1, 2, 6, 7, 8, 11, 63, 64]
    inc_matches = all_match_ids - exc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_group_stages
    get '/fixtures', {}, non_admin_session
    post '/fixtures',
         { st_gr: 'on',
           gr_A: 'on', gr_B: 'on', gr_C: 'on', gr_D: 'on', gr_E: 'on', gr_F: 'on', gr_G: 'on', gr_H: 'on' }
         non_admin_session

    assert_equal 200, last_response.status

    inc_matches = (1..48).to_a
    exc_matches = all_match_ids - inc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_round_of_16
    get '/fixtures', {}, non_admin_session
    post '/fixtures',
         { st_r16: 'on',
           gr_A: 'on', gr_B: 'on', gr_C: 'on', gr_D: 'on', gr_E: 'on', gr_F: 'on', gr_G: 'on', gr_H: 'on' }
         non_admin_session

    assert_equal 200, last_response.status

    inc_matches = (49..56).to_a
    exc_matches = all_match_ids - inc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_quarter_finals
    get '/fixtures', {}, non_admin_session
    post '/fixtures',
         { st_qf: 'on',
           gr_A: 'on', gr_B: 'on', gr_C: 'on', gr_D: 'on', gr_E: 'on', gr_F: 'on', gr_G: 'on', gr_H: 'on' }
         non_admin_session

    assert_equal 200, last_response.status

    inc_matches = (57..60).to_a
    exc_matches = all_match_ids - inc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_semi_finals
    get '/fixtures', {}, non_admin_session
    post '/fixtures',
         { st_sf: 'on',
           gr_A: 'on', gr_B: 'on', gr_C: 'on', gr_D: 'on', gr_E: 'on', gr_F: 'on', gr_G: 'on', gr_H: 'on' }
         non_admin_session

    assert_equal 200, last_response.status

    inc_matches = [61, 62]
    exc_matches = all_match_ids - inc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_final
    get '/fixtures', {}, non_admin_session
    post '/fixtures',
         { st_f: 'on',
           gr_A: 'on', gr_B: 'on', gr_C: 'on', gr_D: 'on', gr_E: 'on', gr_F: 'on', gr_G: 'on', gr_H: 'on' }
         non_admin_session

    assert_equal 200, last_response.status

    inc_matches = [63, 64]
    exc_matches = all_match_ids - inc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_group_stages_and_final
    get '/fixtures', {}, non_admin_session
    post '/fixtures',
         { st_gr: 'on', st_f: 'on',
           gr_A: 'on', gr_B: 'on', gr_C: 'on', gr_D: 'on', gr_E: 'on', gr_F: 'on', gr_G: 'on', gr_H: 'on' }
         non_admin_session

    assert_equal 200, last_response.status

    inc_matches = (1..48).to_a + [63, 64]
    exc_matches = all_match_ids - inc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_group_C
    get '/fixtures', {}, non_admin_session
    post '/fixtures',
         { st_gr: 'on',
           gr_C: 'on' }
         non_admin_session

    assert_equal 200, last_response.status

    inc_matches = [5, 7, 22, 24, 39, 40]
    exc_matches = all_match_ids - inc_matches
    fixtures_page_parts(inc_matches, exc_matches)
  end

  def test_filter_matches_no_matches_returned
    get '/fixtures', {}, non_admin_session
    post '/fixtures',
         { exc_pred: 'on',
           st_f: 'on',
           gr_A: 'on', gr_B: 'on', gr_C: 'on', gr_D: 'on', gr_E: 'on', gr_F: 'on', gr_G: 'on', gr_H: 'on' }
         non_admin_session

    assert_includes body_text, 'No matches meet your criteria, please try again!'
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
