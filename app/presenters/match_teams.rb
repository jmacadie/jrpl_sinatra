module Presenters
  class MatchTeams
    def initialize(match:)
      @match = match
    end

    def home_name
      team_name(:home_name, :home_tournament_role)
    end

    def away_name
      team_name(:away_name, :away_tournament_role)
    end

    private

    def team_name(team_key, tr_key)
      @match[team_key] || @match[tr_key]
    end
  end
end
