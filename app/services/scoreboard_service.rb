class ScoreboardService
  def initialize(match_repository:, prediction_repository:, point_repository:)
    @match_repository = match_repository
    @prediction_repository = prediction_repository
    @point_repository = point_repository
  end

  def update_scoreboard(match_id, home_score=nil, away_score=nil)
    result = result_for(match_id, home_score, away_score)
    predictions = @prediction_repository.predictions_for_match(match_id)
    update_official_scoring(result, predictions)
    update_autoquiz_scoring(predictions)
  end

  def scoreboard_data(scoring_system)
    @point_repository.load_scoreboard_data(scoring_system)
  end

  private

  def update_official_scoring(result, predictions)
    scoring_id = 1 # id_for_scoring_system('Official')
    match_type = result_type(result[:home_score], result[:away_score])
    predictions.each do |pred|
      result_pts = official_result_points(match_type, pred)
      score_pts = official_score_points(result, pred)
      @point_repository.add_points(pred[:pred_id], scoring_id, result_pts,
                                   score_pts)
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
    # scoring_id = 2 # id_for_scoring_system('AutoQuiz')
    predictions.each do |_pred|
      # TODO: implement me!
    end
  end

  def result_for(match_id, home_score, away_score)
    if home_score.nil? || away_score.nil?
      match = @match_repository.load_single_match(1, match_id)
      { home_score: match[:home_score], away_score: match[:away_score] }
    else
      { home_score:,
        away_score: }
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
