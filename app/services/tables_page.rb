module Services
  class TablesPage
    Page = Struct.new(:tables, keyword_init: true)

    def initialize(point_repository:)
      @point_repository = point_repository
    end

    def call
      Page.new(
        tables: @point_repository.load_scoreboard_data('Official')
      )
    end
  end
end
