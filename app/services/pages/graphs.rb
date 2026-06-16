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
        points = @cumulative_points_repository.load_cumulative_point_rows
        Presenters::GraphPoints.new(points:).call
      end
    end
  end
end
