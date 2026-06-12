module Services
  module Pages
    class Graphs
      Page = Struct.new(:users, keyword_init: true)

      def initialize(cumulative_points_repository:, user_repository:)
        @cumulative_points_repository = cumulative_points_repository
        @user_repository = user_repository
      end

      def page
        Page.new(users: @user_repository.load_all_users_details)
      end

      def points
        rows = @cumulative_points_repository.load_cumulative_point_rows
        points = Presenters::CumulativePoints.new(rows).grouped_points
        points = default_points if points.empty?
        add_relative_points(points)
        add_rankings(points)
        points
      end

      private

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
end
