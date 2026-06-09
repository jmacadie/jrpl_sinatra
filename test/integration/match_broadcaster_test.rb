require 'json'
require "test_helpers"

class MatchBroadcasterIntegrationTest < Minitest::Test
  include TestIntegrationMethods

  def test_admin_changes_match_broadcaster
    get '/match/6', {}, admin_session
    post '/match/broadcaster/edit',
         { match_id: '6',
           broadcaster: '1',
           authenticity_token: csrf_token }

    assert_equal 200, last_response.status
    assert_equal 'application/json', last_response['Content-Type']
    assert_equal(
      { 'message' => 'Broadcaster changed', 'status' => 'success' },
      JSON.parse(last_response.body)
    )

    get '/match/6', {}, admin_session
    assert_includes body_html,
                    '<option value="1" selected> BBC </option>'
  end
end
