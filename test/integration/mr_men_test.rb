require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_calc_mr_men
    get '/match/2', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_includes body_html,
                    '<tr> <td>Mr. Mean</td> <td><strong>Draw</strong><br />1&nbsp;-&nbsp;1</td> <td>-</td> </tr>'
    assert_includes body_html,
                    '<tr> <td>Mr. Median</td> <td><strong>Hungary Win</strong><br />2&nbsp;-&nbsp;1</td> <td>-</td> </tr>'
    assert_includes body_html,
                    '<tr> <td>Mr. Mode</td> <td><strong>Hungary Win</strong><br />2&nbsp;-&nbsp;0</td> <td>-</td> </tr>'
  end

  def test_calc_mr_men_v2
    get '/match/3', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_includes body_html,
                    '<tr> <td>Mr. Mean</td> <td><strong>Croatia Win</strong><br />4&nbsp;-&nbsp;2</td> <td>-</td> </tr>'
    assert_includes body_html,
                    '<tr> <td>Mr. Median</td> <td><strong>Draw</strong><br />1&nbsp;-&nbsp;1</td> <td>-</td> </tr>'
    assert_includes body_html,
                    '<tr> <td>Mr. Mode</td> <td><strong>Spain Win</strong><br />1&nbsp;-&nbsp;0</td> <td>-</td> </tr>'
  end
end
