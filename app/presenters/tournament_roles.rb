module Presenters
  class TournamentRoles
    def initialize(rows)
      @rows = normalize_ids(rows)
    end

    def grouped_roles
      unique_stages.each do |stage|
        roles = roles_for_stage(stage[:stage])
        stage[:group_roles] = add_teams_to_roles(roles)
      end
    end

    private

    def normalize_ids(rows)
      rows.map do |row|
        row.merge(
          selected_team_id: row[:selected_team_id].to_i,
          team_id: row[:team_id].to_i
        )
      end
    end

    def unique_stages
      @rows.map { |row| { stage: row[:stage] } }.uniq
    end

    def roles_for_stage(stage)
      @rows.filter { |row| row[:stage] == stage }
           .map do |row|
             {
               role: row[:role],
               id: row[:id],
               selected: row[:selected_team_id]
             }
           end.uniq
    end

    def add_teams_to_roles(roles)
      roles.each do |role|
        selected = selected_by_other_roles(roles, role[:id])
        role[:teams] = teams_for_role(role[:id], selected)
      end
    end

    def selected_by_other_roles(roles, role_id)
      roles.filter { |other| other[:id] != role_id }
           .filter { |other| other[:selected].positive? }
           .map { |other| other[:selected] }
           .uniq
    end

    def teams_for_role(role_id, selected)
      @rows.filter { |row| row[:id] == role_id }
           .map do |row|
             {
               team_id: row[:team_id],
               team_name: row[:team],
               disabled: selected.include?(row[:team_id])
             }
           end
    end
  end
end
