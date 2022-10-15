require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_carousel
    get '/match/1?ring=001003001004', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_html, '<a href="/match/3?ring=000003001004">&lt; Previous match</a>'
    assert_includes body_html, '<a href="/match/4?ring=002003001004">Next match &gt;</a>'
  end

  def test_carousel_below_minimum
    get '/match/2?ring=000002003001', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_html, '<a href="/match/3?ring=001002003001">Next match &gt;</a>'
    refute_includes body_html, '&lt; Previous match'
  end

  def test_carousel_above_maximum
    get '/match/64?ring=00203e03f040', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_html, '<a href="/match/63?ring=00103e03f040">&lt; Previous match</a>'
    refute_includes body_html, 'Next match &gt;'
  end
end
