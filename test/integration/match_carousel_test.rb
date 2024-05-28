require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_carousel
    get '/match/1?ring=eJwzMDA0MDA2AJEmAA7TAko=', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_html,
                    '<a href="/match/3?ring=eJwzMAACYwMDQwMDEwAOyQJJ">&lt; Previous match</a>'
    assert_includes body_html,
                    '<a href="/match/4?ring=eJwzMDAyMDA2MDA0MDABAA7dAks=">Next match &gt;</a>'
  end

  def test_carousel_below_minimum
    get '/match/2?ring=eJwzMAACIwMDYwMDQwAOxwJH', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_html,
                    '<a href="/match/3?ring=eJwzMDA0MDAyMDA2MDAEAA7RAkg='
    refute_includes body_html, '&lt; Previous match'
  end

  def test_carousel_above_maximum
    get '/match/51?ring=eJwzMDAyMDY0MAaSxgAO_wJS', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_html,
                    '<a href="/match/50?ring=eJwzMDA0MAYiIwNjYwAO9QJR'
    refute_includes body_html, 'Next match &gt;'
  end
end
