require "test_helpers"

class FixturesPageServiceTest < Minitest::Test
  def test_builds_page_with_default_criteria
    repository, service = build_service(
      matches: [{ match_id: 4 }, { match_id: 8 }]
    )
    page = service.call(user_id: 11)

    assert_default_criteria(page.criteria)
    assert_default_page_data(page)
    assert_equal [[:load_matches, page.criteria, 11], [:stage_names]],
                 repository.calls
  end

  def test_builds_criteria_from_submitted_params
    _, service = build_service(matches: [{ match_id: 6 }])
    params = {
      'exc_pred' => 'on',
      'st_gr' => 'on',
      'st_qf' => 'on',
      'gr_C' => 'on'
    }

    page = service.call(
      user_id: 4,
      submitted_params: params
    )

    assert_submitted_criteria(page.criteria)
    assert_nil page.message
  end

  def test_returns_warning_for_empty_submitted_results
    _, service = build_service(matches: [])
    page = service.call(
      user_id: 4,
      submitted_params: {}
    )

    assert_equal Services::Pages::Fixtures::WARNING_MESSAGE, page.message
    assert_equal 'warning', page.message_level
  end

  def test_does_not_warn_for_empty_initial_results
    _, service = build_service(matches: [])
    page = service.call(user_id: 4)

    assert_nil page.message
    assert_nil page.message_level
  end

  private

  def build_service(matches:)
    repository = FakeFixturesRepository.new(matches:)
    service = Services::Pages::Fixtures.new(fixtures_repository: repository)
    return repository, service
  end

  def assert_default_criteria(criteria)
    assert criteria[:exclude_played]
    refute criteria[:exclude_predicted]
    assert criteria[:stages].values.all?
    assert criteria[:groups].values.all?
  end

  def assert_default_page_data(page)
    assert_equal [{ match_id: 4 }, { match_id: 8 }], page.matches
    assert_equal ['Group Stages', 'Final'], page.stage_names
    assert_equal [4, 8], page.match_ids
    assert_nil page.message
    assert_nil page.message_level
  end

  def assert_submitted_criteria(criteria)
    refute criteria[:exclude_played]
    assert criteria[:exclude_predicted]
    assert_equal selected_stages, criteria[:stages]
    assert_equal selected_groups, criteria[:groups]
  end

  def selected_stages
    {
      group: true,
      round32: false,
      round16: false,
      quarter_final: true,
      semi_final: false,
      final: false
    }
  end

  def selected_groups
    ('A'..'L').to_h do |group|
      [group.to_sym, group == 'C']
    end
  end

  class FakeFixturesRepository
    attr_reader :calls

    def initialize(matches:)
      @matches = matches
      @calls = []
    end

    def load_matches(criteria:, user_id:)
      calls << [:load_matches, criteria, user_id]
      @matches
    end

    def stage_names
      calls << [:stage_names]
      ['Group Stages', 'Final']
    end
  end
end
