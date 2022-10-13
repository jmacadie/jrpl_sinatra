require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_carousel
    get '/match/1', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_html, '<a href="/match/3">&lt; Previous match</a>'
    assert_includes body_html, '<a href="/match/4">Next match &gt;</a>'
  end

  def test_carousel_below_minimum
    get '/match/2', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_html, '<a href="/match/3">Next match &gt;</a>'
    refute_includes body_html, '&lt; Previous match'
  end

  def test_carousel_above_maximum
    get '/match/64', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_html, '<a href="/match/63">&lt; Previous match</a>'
    refute_includes body_html, 'Next match &gt;'
  end

  def test_carousel_predicted
    get '/match/6', {}, non_admin_session_predicted_criteria

    assert_includes body_html, '<a href="/match/7">Next match'
    refute_includes body_html, 'Previous match'
  end

  def test_carousel_not_predicted_group_stages
    get '/match/3', {}, non_admin_session_not_predicted_group_stages_criteria

    assert_includes body_html, '<a href="/match/2">&lt; Previous match</a>'
    assert_includes body_html, '<a href="/match/1">Next match &gt;</a>'
  end

  def test_carousel_not_predicted_group_stages_2
    get '/match/48', {}, non_admin_session_not_predicted_group_stages_criteria

    assert_includes body_html, '<a href="/match/47">&lt; Previous match</a>'
    refute_includes body_html, 'Next match &gt;'
  end
end
