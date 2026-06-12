module Services
  module Pages
    class Tables
      Page = Struct.new(:tables, keyword_init: true)

      def initialize(point_repository:)
        @point_repository = point_repository
      end

      def call
        tables = @point_repository.load_scoreboard_data('Official')
        Page.new(
          tables: Presenters::Scoreboard.new(tables).ranked_tables
        )
      end
    end
  end
end
