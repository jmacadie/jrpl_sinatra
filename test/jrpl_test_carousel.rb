module TestCarousel
  def test_carousel_predicted
    get '/match/6', {}, user_11_session_predicted_criteria

    assert_includes last_response.body, '<a href="/match/7">Next match'
    refute_includes last_response.body, 'Previous match'
  end

  def test_carousel_not_predicted_group_stages
    get '/match/3', {}, user_11_session_not_predicted_group_stages_criteria

    assert_includes last_response.body, '<a href="/match/2">&lt; Previous match</a>'
    assert_includes last_response.body, '<a href="/match/1">Next match &gt;</a>'
  end

  def test_carousel_not_predicted_group_stages_2
    get '/match/48', {}, user_11_session_not_predicted_group_stages_criteria

    assert_includes last_response.body, '<a href="/match/47">&lt; Previous match</a>'
    refute_includes last_response.body, 'Next match &gt;'
  end
end
