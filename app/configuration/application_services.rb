require_relative '../services/query_runner'
require_relative '../repositories/cumulative_points'
require_relative '../repositories/fixtures'
require_relative '../repositories/match'
require_relative '../repositories/point'
require_relative '../repositories/prediction'
require_relative '../repositories/tournament_role'
require_relative '../repositories/user'

module ApplicationServices
  def self.register(app)
    register_shared_services(app)
    register_repositories(app)
    register_template_renderer(app)
    register_email_sender(app)
    register_match_result_service(app)
    register_match_prediction_service(app)
    register_match_page_service(app)
    register_match_broadcaster_service(app)
    register_fixtures_page_service(app)
    register_graphs_page_service(app)
    register_tournament_role_services(app)
  end

  def self.register_shared_services(app)
    app.set :app_logger, Logger.new($stdout)
    app.set :query_runner, QueryRunner.new(
      db_pool: app.settings.db_pool,
      logger: app.settings.app_logger,
      environment: app.environment
    )
  end

  def self.register_repositories(app)
    register_repository(
      app,
      :cumulative_points_repository,
      CumulativePointsRepository
    )
    register_repository(app, :fixtures_repository, FixturesRepository)
    register_repository(app, :match_repository, MatchRepository)
    register_repository(app, :prediction_repository, PredictionRepository)
    register_repository(
      app,
      :tournament_role_repository,
      TournamentRoleRepository
    )
    register_repository(app, :user_repository, UserRepository)
    register_repository(app, :point_repository, PointRepository)
  end

  def self.register_repository(app, name, repository_class)
    app.set name, repository_class.new(
      query_runner: app.settings.query_runner
    )
  end

  def self.register_template_renderer(app)
    app.set :template_renderer, SinatraTemplateRenderer.new(app: app.new!)
  end

  def self.register_email_sender(app)
    app.set :email_sender, EmailSender.new(
      query_runner: app.settings.query_runner,
      config: app.settings.email,
      environment: app.environment
    )
  end

  def self.register_match_result_service(app)
    scoreboard_service = get_scoreboard_service(app)
    result_mailer = get_result_mailer(app, scoreboard_service)
    app.set :match_result_service, MatchResultService.new(
      match_repository: app.settings.match_repository,
      scoreboard_service:,
      result_mailer:
    )
  end

  def self.get_scoreboard_service(app)
    ScoreboardService.new(
      match_repository: app.settings.match_repository,
      prediction_repository: app.settings.prediction_repository,
      point_repository: app.settings.point_repository
    )
  end

  def self.get_result_mailer(app, scoreboard_service)
    MatchResultMailer.new(
      match_repository: app.settings.match_repository,
      prediction_repository: app.settings.prediction_repository,
      scoreboard_service:,
      renderer: app.settings.template_renderer,
      email_sender: app.settings.email_sender,
      query_runner: app.settings.query_runner
    )
  end

  def self.register_match_prediction_service(app)
    app.set :match_prediction_service, MatchPredictionService.new(
      match_repository: app.settings.match_repository,
      prediction_repository: app.settings.prediction_repository
    )
  end

  def self.register_match_page_service(app)
    app.set :match_page_service, MatchPageService.new(
      match_repository: app.settings.match_repository,
      prediction_repository: app.settings.prediction_repository,
      user_repository: app.settings.user_repository
    )
  end

  def self.register_match_broadcaster_service(app)
    app.set :match_broadcaster_service, MatchBroadcasterService.new(
      match_repository: app.settings.match_repository
    )
  end

  def self.register_fixtures_page_service(app)
    app.set :fixtures_page_service, FixturesPageService.new(
      fixtures_repository: app.settings.fixtures_repository
    )
  end

  def self.register_graphs_page_service(app)
    app.set :graphs_page_service, GraphsPageService.new(
      cumulative_points_repository:
        app.settings.cumulative_points_repository,
      user_repository: app.settings.user_repository
    )
  end

  def self.register_tournament_role_services(app)
    repository = app.settings.tournament_role_repository
    app.set :tournament_roles_page_service, TournamentRolesPageService.new(
      tournament_role_repository: repository
    )
    app.set :tournament_role_service, TournamentRoleService.new(
      tournament_role_repository: repository
    )
  end
end
