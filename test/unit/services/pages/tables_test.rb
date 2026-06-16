require "test_helpers"

class TablesPageServiceTest < Minitest::Test
  def test_builds_page_with_official_scoreboard_tables
    repository = FakePointRepository.new
    service = Services::Pages::Tables.new(point_repository: repository)

    page = service.call

    assert_equal(
      {
        overall_table: [
          { user_name: 'Clare Mac', total_points: 3, rank: '1' }
        ],
        group_table: [
          { user_name: 'Maccas', total_points: 1, rank: '1' }
        ],
        knockout_table: [
          { user_name: 'Mr. Mean', total_points: 0, rank: '1' }
        ]
      },
      page.tables
    )
    assert_equal [[:load_scoreboard_data, 'Official']], repository.calls
  end

  class FakePointRepository
    attr_reader :calls

    def initialize
      @calls = []
      @scoreboard_data = {
        overall_table: [{ user_name: 'Clare Mac', total_points: 3 }],
        group_table: [{ user_name: 'Maccas', total_points: 1 }],
        knockout_table: [{ user_name: 'Mr. Mean', total_points: 0 }]
      }
    end

    def load_scoreboard_data(scoring_system:)
      calls << [:load_scoreboard_data, scoring_system]
      @scoreboard_data
    end
  end
end
