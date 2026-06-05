module DBPredictions
  def add_prediction(user_id, match_id, home_team_points, away_team_points)
    delete_prediction(user_id, match_id)
    sql = insert_prediction_query()
    run_query(sql, user_id, match_id, home_team_points, away_team_points)
  end

  private

  def delete_prediction(user_id, match_id)
    sql = <<~SQL
    DELETE FROM prediction
    WHERE user_id = $1::int AND match_id = $2::int;
    SQL
    run_query(sql, user_id, match_id)
  end

  def insert_prediction_query
    <<~SQL
      INSERT INTO prediction
        (user_id, match_id, home_team_points, away_team_points)
      VALUES ($1::int, $2::int, $3::int, $4::int);
    SQL
  end
end
