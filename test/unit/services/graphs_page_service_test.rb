require_relative '../../helpers/test_helpers'
require_relative '../../../app/services/graphs_page'

class GraphsPageServiceTest < Minitest::Test
  def test_builds_page_with_users
    cumulative_points_repository, user_repository, service = build_service(
      points: [],
      users: [{ user_id: 4, user_name: 'Maccas' }]
    )
    page = service.page

    assert_equal [{ user_id: 4, user_name: 'Maccas' }], page.users
    assert_equal [[:load_all_users_details]], user_repository.calls
    assert_empty cumulative_points_repository.calls
  end

  def test_builds_relative_points_and_competition_rankings
    repository, _, service = build_service(points: cumulative_points_fixture)
    points = service.points

    assert_graph_values(points.first)
    assert_equal [[:load_cumulative_points]], repository.calls
  end

  def test_builds_default_points_when_no_results_exist
    _, _, service = build_service(points: [])

    assert_equal [{
      match: 'None',
      users: [{
        user_name: 'None',
        cum_points: 0,
        rel_points: 0,
        rank: 1
      }]
    }], service.points
  end

  private

  def build_service(points:, users: [])
    cumulative_points_repository = FakeCumulativePointsRepository.new(points:)
    user_repository = FakeUserRepository.new(users:)
    service = Services::GraphsPage.new(
      cumulative_points_repository:,
      user_repository:
    )
    return cumulative_points_repository, user_repository, service
  end

  def cumulative_points_fixture
    [{
      match_id: 2,
      match: 'Hungary vs Switzerland',
      users: [
        user_fixture(1, 'Alice', 3),
        user_fixture(2, 'Bob', 1),
        user_fixture(3, 'Cara', 1),
        user_fixture(4, 'Dan', 0)
      ]
    }]
  end

  def user_fixture(user_id, user_name, cumulative_points)
    {
      user_id:,
      user_name:,
      cum_points: cumulative_points
    }
  end

  def assert_graph_values(match)
    assert_equal [0, 2, 2, 3],
                 (match[:users].map { |user| user[:rel_points] })
    assert_equal [1, 2, 2, 4],
                 (match[:users].map { |user| user[:rank] })
  end

  class FakeCumulativePointsRepository
    attr_reader :calls

    def initialize(points:)
      @points = points
      @calls = []
    end

    def load_cumulative_points
      calls << [:load_cumulative_points]
      @points
    end
  end

  class FakeUserRepository
    attr_reader :calls

    def initialize(users:)
      @users = users
      @calls = []
    end

    def load_all_users_details
      calls << [:load_all_users_details]
      @users
    end
  end
end
