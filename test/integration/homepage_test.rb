require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_homepage_signed_out
    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'JRPL'
    refute_includes body_text, 'Sign Out'
    refute_includes body_text, 'Edit Details'
    refute_includes body_text, 'Admin'
  end

  def test_homepage_signed_in
    get '/', {}, non_admin_session
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'JRPL'
    assert_includes body_text, 'Sign Out'
    assert_includes body_text, 'Edit Details'
    refute_includes body_text, 'Admin'
  end

  def test_homepage_signed_in_admin
    get '/', {}, admin_session
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'JRPL'
    assert_includes body_text, 'Sign Out'
    assert_includes body_text, 'Edit Details'
    assert_includes body_text, 'Admin'
  end
end
