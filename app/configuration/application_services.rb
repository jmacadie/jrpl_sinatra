require_relative '../services/query_runner'
require_relative '../repositories/cookie'
require_relative '../repositories/cumulative_points'
require_relative '../repositories/email'
require_relative '../repositories/fixtures'
require_relative '../repositories/match'
require_relative '../repositories/point'
require_relative '../repositories/prediction'
require_relative '../repositories/tournament_role'
require_relative '../repositories/user'
require_relative '../services/admin_page_service'
require_relative '../services/delete_user_service'
require_relative '../services/edit_user_page_service'
require_relative '../services/edit_user_service'
require_relative '../services/email_sender'
require_relative '../services/fixtures_page_service'
require_relative '../services/graphs_page_service'
require_relative '../services/lockdown_service'
require_relative '../services/match_broadcaster_service'
require_relative '../services/match_page_service'
require_relative '../services/match_prediction_service'
require_relative '../services/match_result_mailer'
require_relative '../services/match_result_service'
require_relative '../services/mr_men_service'
require_relative '../services/reset_user_password_service'
require_relative '../services/scoreboard_service'
require_relative '../services/sign_in_service'
require_relative '../services/sign_up_service'
require_relative '../services/sinatra_template_renderer'
require_relative '../services/tables_page_service'
require_relative '../services/toggle_user_admin_service'
require_relative '../services/tournament_role_service'

class ApplicationServices
  def initialize(app:)
    @app = app
  end

  def register
    register_query_runner
    create_repositories
    register_repositories
    create_template_renderer
    register_email_sender
    register_lockdown_services
    register_match_result_service
    register_match_prediction_service
    register_match_page_service
    register_match_broadcaster_service
    register_page_services
    register_tournament_role_service
    register_edit_user_services
    register_sign_in_service
    register_sign_up_service
    register_reset_user_password_service
    register_delete_user_service
    register_toggle_user_admin_service
  end

  private

  def register_page_services
    register_fixtures_page_service
    register_graphs_page_service
    register_tables_page_service
    register_admin_page_service
  end

  def register_query_runner
    @app.set :query_runner, QueryRunner.new(
      db_pool: @app.settings.db_pool,
      logger: Logger.new($stdout),
      environment: @app.environment
    )
  end

  def create_repositories
    @cookie_repository = create_repository(CookieRepository)
    @cumulative_points_repository = create_repository(
      CumulativePointsRepository
    )
    @emails_sent_repository = create_repository(EmailsSentRepository)
    @fixtures_repository = create_repository(FixturesRepository)
    @match_repository = create_repository(MatchRepository)
    @prediction_repository = create_repository(PredictionRepository)
    @tournament_role_repository = create_repository(TournamentRoleRepository)
    @user_repository = create_repository(UserRepository)
    @point_repository = create_repository(PointRepository)
  end

  def create_repository(repository_class)
    repository_class.new(
      query_runner: @app.settings.query_runner
    )
  end

  def register_repositories
    @app.set :cookie_repository, @cookie_repository
    @app.set :user_repository, @user_repository
  end

  def create_template_renderer
    @template_renderer = SinatraTemplateRenderer.new(app: @app.new!)
  end

  def register_email_sender
    @email_sender = EmailSender.new(
      query_runner: @app.settings.query_runner,
      config: @app.settings.email,
      environment: @app.environment
    )
    @app.set :email_sender, @email_sender
  end

  def register_lockdown_services
    mr_men_service = MrMenService.new(
      prediction_repository: @prediction_repository
    )
    @app.set :lockdown_service, LockdownService.new(
      match_repository: @match_repository,
      prediction_repository: @prediction_repository,
      emails_sent_repository: @emails_sent_repository,
      mr_men_service: mr_men_service,
      renderer: @template_renderer,
      email_sender: @email_sender
    )
  end

  def register_match_result_service
    scoreboard_service = create_scoreboard_service
    result_mailer = result_mailer(scoreboard_service)
    @app.set :match_result_service, MatchResultService.new(
      match_repository: @match_repository,
      scoreboard_service:,
      result_mailer:
    )
  end

  def create_scoreboard_service
    ScoreboardService.new(
      match_repository: @match_repository,
      prediction_repository: @prediction_repository,
      point_repository: @point_repository
    )
  end

  def result_mailer(scoreboard_service)
    MatchResultMailer.new(
      match_repository: @match_repository,
      prediction_repository: @prediction_repository,
      scoreboard_service:,
      renderer: @template_renderer,
      email_sender: @email_sender,
      emails_sent_repository: @emails_sent_repository
    )
  end

  def register_match_prediction_service
    @app.set :match_prediction_service, MatchPredictionService.new(
      match_repository: @match_repository,
      prediction_repository: @prediction_repository
    )
  end

  def register_match_page_service
    @app.set :match_page_service, MatchPageService.new(
      match_repository: @match_repository,
      prediction_repository: @prediction_repository,
      user_repository: @user_repository
    )
  end

  def register_match_broadcaster_service
    @app.set :match_broadcaster_service, MatchBroadcasterService.new(
      match_repository: @match_repository
    )
  end

  def register_fixtures_page_service
    @app.set :fixtures_page_service, FixturesPageService.new(
      fixtures_repository: @fixtures_repository
    )
  end

  def register_graphs_page_service
    @app.set :graphs_page_service, GraphsPageService.new(
      cumulative_points_repository: @cumulative_points_repository,
      user_repository: @user_repository
    )
  end

  def register_tables_page_service
    @app.set :tables_page_service, TablesPageService.new(
      point_repository: @point_repository
    )
  end

  def register_admin_page_service
    @app.set :admin_page_service, AdminPageService.new(
      user_repository: @user_repository,
      tournament_role_repository: @tournament_role_repository
    )
  end

  def register_tournament_role_service
    @app.set :tournament_role_service, TournamentRoleService.new(
      tournament_role_repository: @tournament_role_repository
    )
  end

  def register_edit_user_services
    @app.set :edit_user_page_service, EditUserPageService.new(
      user_repository: @user_repository
    )
    @app.set :edit_user_service, EditUserService.new(
      user_repository: @user_repository
    )
  end

  def register_sign_in_service
    @app.set :sign_in_service, SignInService.new(
      user_repository: @user_repository
    )
  end

  def register_sign_up_service
    @app.set :sign_up_service, SignUpService.new(
      user_repository: @user_repository
    )
  end

  def register_reset_user_password_service
    @app.set :reset_user_password_service, ResetUserPasswordService.new(
      user_repository: @user_repository
    )
  end

  def register_delete_user_service
    @app.set :delete_user_service, DeleteUserService.new(
      user_repository: @user_repository
    )
  end

  def register_toggle_user_admin_service
    @app.set :toggle_user_admin_service, ToggleUserAdminService.new(
      user_repository: @user_repository
    )
  end
end
