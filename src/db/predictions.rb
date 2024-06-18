module DBPredictions
  def add_prediction(user_id, match_id, home_team_points, away_team_points)
    delete_prediction(user_id, match_id)
    sql = insert_prediction_query()
    query(sql, user_id, match_id, home_team_points, away_team_points)
  end

  def predictions_for_match(match_id)
    sql = predictions_for_match_query()
    result = query(sql, match_id)
    result.map do |tuple|
      { pred_id: tuple['prediction_id'].to_i,
        home_score: tuple['home_team_points'].to_i,
        away_score: tuple['away_team_points'].to_i }
    end
  end

  private

  def delete_prediction(user_id, match_id)
    sql = <<~SQL
    DELETE FROM prediction
    WHERE user_id = $1::int AND match_id = $2::int;
    SQL
    query(sql, user_id, match_id)
  end

  def insert_prediction_query
    <<~SQL
      INSERT INTO prediction
        (user_id, match_id, home_team_points, away_team_points)
      VALUES ($1::int, $2::int, $3::int, $4::int);
    SQL
  end

  def predictions_for_match_query
    <<~SQL
      SELECT
        prediction_id,
        home_team_points,
        away_team_points
      FROM prediction
      WHERE match_id = $1::int;
    SQL
  end
end
