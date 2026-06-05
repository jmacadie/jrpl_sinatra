require_relative '../services/query_runner'
require_relative '../repositories/match'
require_relative '../repositories/match_prediction'
require_relative '../repositories/point'
require_relative '../repositories/prediction'
require_relative '../repositories/user'

module ApplicationServices
  def self.register(app)
    register_shared_services(app)
    register_repositories(app)
    register_match_result_services(app)
    register_match_prediction_services(app)
    register_match_page_services(app)
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
    register_repository(app, :match_repository, MatchRepository)
    register_repository(
      app,
      :match_prediction_repository,
      MatchPredictionRepository
    )
    register_repository(app, :prediction_repository, PredictionRepository)
    register_repository(app, :user_repository, UserRepository)
    register_repository(app, :point_repository, PointRepository)
  end

  def self.register_repository(app, name, repository_class)
    app.set name, repository_class.new(
      query_runner: app.settings.query_runner
    )
  end

  def self.register_match_result_services(app)
    register_scoreboard_service(app)
    register_result_mailer(app)
    register_match_result_operations(app)
  end

  def self.register_scoreboard_service(app)
    app.set :scoreboard_service, ScoreboardService.new(
      match_repository: app.settings.match_repository,
      prediction_repository: app.settings.prediction_repository,
      point_repository: app.settings.point_repository
    )
  end

  def self.register_result_mailer(app)
    register_email_sender(app)
    app.set :template_renderer, SinatraTemplateRenderer.new(app: app.new!)
    register_match_result_mailer(app)
  end

  def self.register_email_sender(app)
    app.set :email_sender, EmailSender.new(
      query_runner: app.settings.query_runner,
      config: app.settings.email,
      environment: app.environment
    )
  end

  def self.register_match_result_mailer(app)
    app.set :match_result_mailer, MatchResultMailer.new(
      match_repository: app.settings.match_repository,
      match_prediction_repository: app.settings.match_prediction_repository,
      scoreboard_service: app.settings.scoreboard_service,
      renderer: app.settings.template_renderer,
      email_sender: app.settings.email_sender,
      query_runner: app.settings.query_runner
    )
  end

  def self.register_match_result_operations(app)
    app.set :match_result_operations, MatchResultOperations.new(
      match_repository: app.settings.match_repository,
      scoreboard_service: app.settings.scoreboard_service,
      result_mailer: app.settings.match_result_mailer
    )
  end

  def self.register_match_prediction_services(app)
    app.set :match_prediction_operations, MatchPredictionOperations.new(
      match_repository: app.settings.match_repository,
      prediction_repository: app.settings.prediction_repository
    )
  end

  def self.register_match_page_services(app)
    app.set :match_page_operations, MatchPageOperations.new(
      match_repository: app.settings.match_repository,
      match_prediction_repository: app.settings.match_prediction_repository,
      user_repository: app.settings.user_repository
    )
    app.set :match_page_service, MatchPageService.new(
      operations: app.settings.match_page_operations
    )
  end
end
