module TestMatchesAll
  def test_view_matches_list_signed_in
    get '/matches/all', {}, user_11_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Filters'
    assert_includes last_response.body, 'type="radio"'
    assert_includes last_response.body, 'type="checkbox"'
    assert_includes last_response.body, "<a href=\"/match/48\">"
    assert_includes body_text, 'Winner Group A'
  end

  def test_view_matches_list_signed_out
    get '/matches/all'

    assert_equal 302, last_response.status
    assert_equal 'You must be signed in to do that.', session[:message]
  end

  def test_locked_down_displayed_matches_list
    get '/matches/all', {}, user_11_session

    assert_includes body_text, 'Qatar Qatar vs. Ecuador Ecuador Not yet predicted'
    assert_includes body_text, 'England England 4 vs. 5 Iran Iran Not yet predicted'
    assert_includes body_text, 'Denmark Denmark vs. Tunisia Tunisia Predicted: Tunisia Win Predicted: Tunisia Win 71 - 72'
    assert_includes body_text, 'Mexico Mexico 61 vs. 62 Poland Poland Predicted: Draw Predicted: Draw 6 - 6'
  end

  def test_select_deselect_all_on_match_filter_form
    get '/matches/all', {}, user_11_session

    assert_includes last_response.body, 'Select/Deselect All'
  end
end
