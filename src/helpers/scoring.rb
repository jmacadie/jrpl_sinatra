module Scoring
  def update_scoreboard(match_id, home_score=nil, away_score=nil)
    result = get_result(home_score, away_score)
    predictions = @storage.predictions_for_match(match_id)
    update_official_scoring(result, predictions)
    update_autoquiz_scoring(predictions)
  end

  private

  def update_official_scoring(result, predictions)
    scoring_id = 1 # @storage.id_for_scoring_system('Official')
    match_type = result_type(result[:home_score], result[:away_score])
    predictions.each do |pred|
      result_pts = official_result_points(match_type, pred)
      score_pts = official_score_points(result, pred)
      @storage.add_points(pred[:pred_id], scoring_id, result_pts, score_pts)
    end
  end

  def official_result_points(match_type, prediction)
    pred_type = result_type(prediction[:home_score], prediction[:away_score])
    match_type == pred_type ? 1 : 0
  end

  def official_score_points(result, prediction)
    if prediction[:home_score] == result[:home_score] &&
       prediction[:away_score] == result[:away_score]
      2
    else
      0
    end
  end

  def update_autoquiz_scoring(predictions)
    # scoring_id = 2 # @storage.id_for_scoring_system('AutoQuiz')
    predictions.each do |pred|
      # TODO: implement me!
    end
  end

  def get_result(home_score, away_score)
    if home_score.nil? ||
       away_score.nil?
      @storage.match_result(match_id)
    else
      { home_score: home_score,
        away_score: away_score }
    end
  end

  def result_type(home_score, away_score)
    case home_score <=> away_score
    when 1  then 'home_win'
    when -1 then 'away_win'
    else         'draw'
    end
  end
end
