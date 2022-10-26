class App < Sinatra::Application
  get '/graphs' do
    user_signed_in?
    @users = @storage.load_all_users_details
    @points = @storage.cum_points
    relative_points()
    position_points()
    @points = default_data if @points == []
    erb :graphs
  end

  private

  def default_data
    [{
      match: 'None',
      users:
        [{
          user_name: 'None',
          cum_points: 0,
          rel_points: 0,
          rank: 1
        }]
    }]
  end

  def relative_points
    @points.each do |match|
      max = match[:users].map { |user| user[:cum_points] }.max
      match[:users].each do |user|
        user[:rel_points] = max - user[:cum_points]
      end
    end
  end

  def position_points
    @points.each { |match| rank_one_match(match) }
  end

  def rank_one_match(match)
    last = -1
    rank = 0
    sorted = ranked_match(match)
    sorted.each_with_index do |user, index|
      if user[1] != last
        rank = index + 1
        last = user[1]
      end
      set_rank(match, user[0], rank)
    end
  end

  def ranked_match(match)
    match[:users].map { |user| [user[:user_id], user[:cum_points]] }
                 .sort_by { |_, points| -points }
  end

  def set_rank(match, user_id, rank)
    match[:users].filter { |u| u[:user_id] == user_id }
                 .first[:rank] = rank
  end
end
