require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_view_matches_list_signed_in
    get '/fixtures', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Filters'
    assert_includes body_html, '<a href="/match/48'
    assert_includes body_text, 'Winner Group A'
  end

  def test_view_matches_list_signed_out
    get '/fixtures'

    assert_equal 302, last_response.status
    assert_equal 'You must be signed in to do that.', session[:message]
  end

  def test_locked_down_displayed_matches_list
    get '/fixtures', {}, non_admin_session

    assert_includes body_text, 'Qatar Qatar vs. Ecuador Ecuador Not yet predicted'
    assert_includes body_text, 'Denmark Denmark vs. Tunisia Tunisia Predicted: Tunisia Win Predicted: Tunisia Win 71 - 72'
  end

  def test_select_deselect_all_on_match_filter_form
    get '/fixtures', {}, non_admin_session

    assert_includes body_text, 'Unselect all'
  end
end
