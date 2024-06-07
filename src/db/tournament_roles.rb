module DBTournamentRoles
  def tournament_roles
    sql = tournament_roles_query()
    result = query(sql)
    result = map_tournament_roles(result)
    transform_tournament_roles(result)
  end

  def set_tournament_role(role, team)
    sql = <<~SQL
    UPDATE tournament_role
    SET team_id = $2
    WHERE tournament_role_id = $1
    SQL
    query(sql, role, team)
  end

  def reset_tournament_role(role)
    sql = <<~SQL
    UPDATE tournament_role
    SET team_id = NULL
    WHERE tournament_role_id = $1
    SQL
    query(sql, role)
  end

  private

  def map_tournament_roles(result)
    result.map do |tuple|
      {
        stage: tuple['stage'],
        role: tuple['tournament_role'],
        id: tuple['tournament_role_id'],
        selected_team_id: tuple['selected_team_id'].to_i,
        team_id: tuple['team_id'].to_i,
        team: tuple['team']
      }
    end
  end

  def transform_tournament_roles(result)
    stages = unique_stages(result)
    stages.each do |stage|
      roles = tournament_roles_for_stage(result, stage[:stage])
      stage[:roles] = add_teams_to_role(result, roles)
    end
  end

  def unique_stages(result)
    result.map { |row| { stage: row[:stage] } }.uniq
  end

  def tournament_roles_for_stage(result, stage)
    result.filter { |row| row[:stage] == stage }
          .map do |row|
      {
        role: row[:role],
        id: row[:id],
        selected: row[:selected_team_id]
      }
    end.uniq
  end

  def add_teams_to_role(result, roles)
    roles.each do |role|
      role[:teams] = teams_for_role(result, role[:id])
    end
  end

  def teams_for_role(result, role_id)
    result.filter { |row| row[:id] == role_id }
          .map do |teams|
      {
        team_id: teams[:team_id],
        team: teams[:team]
      }
    end
  end

  def tournament_roles_query
    <<~SQL
    SELECT
      s.name AS stage,
      tr.name AS tournament_role,
      tr.tournament_role_id AS tournament_role_id,
      t.team_id AS selected_team_id,
      COALESCE(tm.team_id, tg.team_id) AS team_id,
      COALESCE(tm.name, tg.name) AS team

    FROM tournament_role tr
      INNER JOIN stage s ON s.stage_id = tr.stage_id

      -- Selected team
      LEFT JOIN team t ON t.team_id = tr.team_id

      -- Teams from source match
      LEFT JOIN
        (SELECT match_id, home_team_id AS team_id FROM match UNION ALL
         SELECT match_id, away_team_id AS team_id FROM match) m ON
        m.match_id = tr.from_match_id
          LEFT JOIN tournament_role trm ON trm.tournament_role_id = m.team_id
            LEFT JOIN team tm ON tm.team_id = trm.team_id

      -- Teams from source group
      LEFT JOIN meta_group_map mgm ON mgm.meta_group_id = tr.from_group_id
        LEFT JOIN tournament_role trg ON trg.from_group_id = mgm.group_id AND trg.stage_id = 1
          LEFT JOIN team tg ON tg.team_id = trg.team_id

    WHERE tr.stage_id > 1

    ORDER BY s.stage_id, tr.tournament_role_id;
    SQL
  end
end
