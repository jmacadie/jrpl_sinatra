require_relative '../helpers/test_helpers'

class TournamentRoleServiceTest < Minitest::Test
  def test_sets_tournament_role
    repository, service = build_service

    result = service.call(role_id: 25, team_id: 4)

    assert_success(result, 'Winner Group A set to Switzerland', reset: false)
    assert_equal [
      [:role_numbers],
      [:team_selected_in_stage?, 25, 4],
      [:role_name, 25],
      [:set_team, 25, 4],
      [:team_name, 4]
    ], repository.calls
  end

  def test_resets_tournament_role
    repository, service = build_service

    result = service.call(role_id: 25, team_id: 0)

    assert_success(result, 'Winner Group A reset', reset: true)
    assert_equal [
      [:role_numbers],
      [:role_name, 25],
      [:reset_team, 25]
    ], repository.calls
  end

  def test_rejects_invalid_team
    repository, service = build_service

    result = service.call(role_id: 25, team_id: 25)

    assert_failure(result, 'Invalid team number: 25')
    assert_equal [[:role_numbers]], repository.calls
  end

  def test_rejects_invalid_role
    repository, service = build_service

    result = service.call(role_id: 24, team_id: 4)

    assert_failure(result, 'Invalid role number: 24')
    assert_equal [[:role_numbers]], repository.calls
  end

  def test_rejects_team_already_selected_in_stage
    repository, service = build_service(selected: true)

    result = service.call(role_id: 25, team_id: 4)

    assert_failure(result, 'Switzerland is already selected for this stage')
    assert_equal [
      [:role_numbers],
      [:team_selected_in_stage?, 25, 4],
      [:team_name, 4]
    ], repository.calls
  end

  def test_converts_unique_constraint_failure_to_result
    repository, service = build_service(unique_violation: true)

    result = service.call(role_id: 25, team_id: 4)

    assert_failure(result, 'Switzerland is already selected for this stage')
    assert_equal [
      [:role_numbers],
      [:team_selected_in_stage?, 25, 4],
      [:role_name, 25],
      [:set_team, 25, 4],
      [:team_name, 4]
    ], repository.calls
  end

  private

  def build_service(selected: false, unique_violation: false)
    repository = FakeTournamentRoleRepository.new(
      selected:,
      unique_violation:
    )
    service = TournamentRoleService.new(
      tournament_role_repository: repository
    )
    return repository, service
  end

  def assert_success(result, message, reset:)
    assert_predicate result, :success?
    assert_equal message, result.message
    assert_equal 'success', result.status
    assert_equal reset, result.reset
  end

  def assert_failure(result, message)
    refute_predicate result, :success?
    assert_equal message, result.message
    assert_equal 'danger', result.status
    assert_nil result.reset
  end

  class FakeTournamentRoleRepository
    attr_reader :calls

    def initialize(selected: false, unique_violation: false)
      @selected = selected
      @unique_violation = unique_violation
      @calls = []
    end

    def role_numbers
      calls << [:role_numbers]
      [24, 54]
    end

    def team_selected_in_stage?(role_id, team_id)
      calls << [:team_selected_in_stage?, role_id, team_id]
      @selected
    end

    def role_name(role_id)
      calls << [:role_name, role_id]
      'Winner Group A'
    end

    def team_name(team_id)
      calls << [:team_name, team_id]
      'Switzerland'
    end

    def set_team(role_id, team_id)
      calls << [:set_team, role_id, team_id]
      raise PG::UniqueViolation if @unique_violation
    end

    def reset_team(role_id)
      calls << [:reset_team, role_id]
    end
  end
end
