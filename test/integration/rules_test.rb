require_relative '../helpers/test_helpers'

class RulesIntegrationTest < Minitest::Test
  include TestIntegrationMethods

  def test_rules_page_is_public
    get '/rules'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'How does it work?'
  end
end
