require "test_helpers"

class TablesPageServiceTest < Minitest::Test
  def test_builds_page_with_official_scoreboard_tables
    repository = FakePointRepository.new
    service = Services::Pages::Tables.new(point_repository: repository)

    page = service.call

    assert_equal repository.scoreboard_data, page.tables
    assert_equal [[:load_scoreboard_data, 'Official']], repository.calls
  end

  class FakePointRepository
    attr_reader :calls, :scoreboard_data

    def initialize
      @calls = []
      @scoreboard_data = {
        overall_table: [{ user_name: 'Clare Mac' }],
        group_table: [{ user_name: 'Maccas' }],
        knockout_table: [{ user_name: 'Mr. Mean' }]
      }
    end

    def load_scoreboard_data(scoring_system)
      calls << [:load_scoreboard_data, scoring_system]
      scoreboard_data
    end
  end
end
