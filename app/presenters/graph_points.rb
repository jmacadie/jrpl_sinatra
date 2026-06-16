module Presenters
  class GraphPoints
    def initialize(points:)
      @points = normalize(points)
    end

    def call
      points = grouped_points
      points = default_points if points.empty?
      add_relative_points(points)
      add_rankings(points)
    end

    private

    def grouped_points
      unique_matches.each do |match|
        match[:users] = users_for_match(match[:match_id])
      end
    end

    def normalize(rows)
      rows.map do |row|
        row.merge(
          match_id: row[:match_id].to_i,
          user_id: row[:user_id].to_i,
          cum_points: row[:cum_points].to_i
        )
      end
    end

    def unique_matches
      @points.map do |row|
        {
          match_id: row[:match_id],
          match: row[:match]
        }
      end.uniq
    end

    def users_for_match(match_id)
      @points.filter { |row| row[:match_id] == match_id }
             .map do |row|
               {
                 user_id: row[:user_id],
                 user_name: row[:user_name],
                 cum_points: row[:cum_points]
               }
             end
    end

    def default_points
      [{
        match: 'None',
        users: [{
          user_name: 'None',
          cum_points: 0,
          rel_points: 0,
          rank: 1
        }]
      }]
    end

    def add_relative_points(points)
      points.each do |match|
        maximum = match[:users].map { |user| user[:cum_points] }.max
        match[:users].each do |user|
          user[:rel_points] = maximum - user[:cum_points]
        end
      end
    end

    def add_rankings(points)
      points.each { |match| rank_match(match) }
    end

    def rank_match(match)
      last_points = nil
      rank = 0
      ranked_users(match).each_with_index do |user, index|
        if user[:cum_points] != last_points
          rank = index + 1
          last_points = user[:cum_points]
        end
        user[:rank] = rank
      end
    end

    def ranked_users(match)
      match[:users].sort_by { |user| -user[:cum_points] }
    end
  end
end
