require 'test_helpers'

class TournamentRolesPresenterTest < Minitest::Test
  def test_handles_empty_input
    roles = Presenters::TournamentRoles.new(rows: []).call

    assert_empty roles
  end

  def test_groups_a_single_stage_and_role
    roles = present(
      [
        role_row(
          stage: 'Final',
          role: 'Winner Semi-Final 1',
          id: '53',
          selected_team_id: '4',
          team_id: '4',
          team: 'Switzerland'
        )
      ]
    )

    assert_equal single_role_output, roles
  end

  def test_preserves_stage_role_and_team_ordering
    roles = present(ordered_role_rows)
    semi_final_roles = roles[0][:group_roles]

    assert_equal ['Semi-finals', 'Final'], stage_names(roles)
    assert_equal ['Winner QF 2', 'Winner QF 1'],
                 role_names(semi_final_roles)
    assert_equal ['Spain', 'Switzerland'],
                 team_names(semi_final_roles[0])
  end

  def test_disables_teams_selected_by_another_role_in_the_stage
    roles = present(
      [
        role_row(stage: 'Final', role: 'Winner SF 1', id: '53',
                 selected_team_id: '4', team_id: '4', team: 'Switzerland'),
        role_row(stage: 'Final', role: 'Winner SF 2', id: '54',
                 team_id: '4', team: 'Switzerland'),
        role_row(stage: 'Final', role: 'Winner SF 2', id: '54',
                 team_id: '8', team: 'Spain')
      ]
    )
    first_role, second_role = roles[0][:group_roles]

    assert_equal [false], disabled_flags(first_role)
    assert_equal [true, false], disabled_flags(second_role)
  end

  def test_converts_nil_and_blank_ids_to_zero
    roles = present(
      [
        role_row(stage: nil, role: nil, id: nil, selected_team_id: nil,
                 team_id: '', team: nil)
      ]
    )
    role = roles[0][:group_roles][0]

    assert_nil roles[0][:stage]
    assert_nil role[:role]
    assert_nil role[:id]
    assert_equal 0, role[:selected]
    assert_equal(
      { team_id: 0, team_name: nil, disabled: false },
      role[:teams][0]
    )
  end

  private

  def single_role_output
    [
      {
        stage: 'Final',
        group_roles: [
          {
            role: 'Winner Semi-Final 1',
            id: '53',
            selected: 4,
            teams: [
              {
                team_id: 4,
                team_name: 'Switzerland',
                disabled: false
              }
            ]
          }
        ]
      }
    ]
  end

  def ordered_role_rows
    [
      role_row(stage: 'Semi-finals', role: 'Winner QF 2', id: '46',
               team_id: '8', team: 'Spain'),
      role_row(stage: 'Semi-finals', role: 'Winner QF 2', id: '46',
               team_id: '4', team: 'Switzerland'),
      role_row(stage: 'Semi-finals', role: 'Winner QF 1', id: '45',
               team_id: '2', team: 'Germany'),
      role_row(stage: 'Final', role: 'Winner SF 1', id: '53',
               team_id: '4', team: 'Switzerland')
    ]
  end

  def present(rows)
    Presenters::TournamentRoles.new(rows:).call
  end

  def role_row(attributes)
    {
      stage: attributes[:stage],
      role: attributes[:role],
      id: attributes[:id],
      selected_team_id: attributes[:selected_team_id],
      team_id: attributes[:team_id],
      team: attributes[:team]
    }
  end

  def stage_names(roles)
    roles.map { |stage| stage[:stage] }
  end

  def role_names(roles)
    roles.map { |role| role[:role] }
  end

  def team_names(role)
    role[:teams].map { |team| team[:team_name] }
  end

  def disabled_flags(role)
    role[:teams].map { |team| team[:disabled] }
  end
end
