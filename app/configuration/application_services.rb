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
require_relative '../services/admin_page'
require_relative '../services/delete_user'
require_relative '../services/edit_user_page'
require_relative '../services/edit_user'
require_relative '../services/email_sender'
require_relative '../services/fixtures_page'
require_relative '../services/graphs_page'
require_relative '../services/lockdown'
require_relative '../services/match_broadcaster'
require_relative '../services/match_page'
require_relative '../services/match_prediction'
require_relative '../services/match_result_mailer'
require_relative '../services/match_result'
require_relative '../services/mr_men'
require_relative '../services/reset_user_password'
require_relative '../services/scoreboard'
require_relative '../services/sign_in'
require_relative '../services/sign_up'
require_relative '../services/sinatra_template_renderer'
require_relative '../services/tables_page'
require_relative '../services/toggle_user_admin'
require_relative '../services/tournament_role'
require_relative '../policies/lockdown'

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
    @app.set :query_runner, Services::QueryRunner.new(
      db_pool: @app.settings.db_pool,
      logger: Logger.new($stdout),
      environment: @app.environment
    )
  end

  def create_repositories
    @cookie_repository = create_repository(Repositories::Cookie)
    @cumulative_points_repository = create_repository(
      Repositories::CumulativePoints
    )
    @emails_sent_repository = create_repository(Repositories::EmailsSent)
    @fixtures_repository = create_repository(Repositories::Fixtures)
    @match_repository = create_repository(Repositories::Match)
    @prediction_repository = create_repository(Repositories::Prediction)
    @tournament_role_repository = create_repository(Repositories::TournamentRole)
    @user_repository = create_repository(Repositories::User)
    @point_repository = create_repository(Repositories::Point)
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
    @template_renderer = Services::SinatraTemplateRenderer.new(app: @app.new!)
  end

  def register_email_sender
    @email_sender = Services::EmailSender.new(
      query_runner: @app.settings.query_runner,
      config: @app.settings.email,
      environment: @app.environment
    )
    @app.set :email_sender, @email_sender
  end

  def register_lockdown_services
    mr_men_service = Services::MrMen.new(
      prediction_repository: @prediction_repository
    )
    @app.set :lockdown_service, Services::Lockdown.new(
      match_repository: @match_repository,
      prediction_repository: @prediction_repository,
      emails_sent_repository: @emails_sent_repository,
      mr_men_service: mr_men_service,
      renderer: @template_renderer,
      email_sender: @email_sender,
      lockdown_policy: Policies::Lockdown.new
    )
  end

  def register_match_result_service
    scoreboard_service = create_scoreboard_service
    result_mailer = result_mailer(scoreboard_service)
    @app.set :match_result_service, Services::MatchResult.new(
      match_repository: @match_repository,
      scoreboard_service:,
      result_mailer:,
      lockdown_policy: Policies::Lockdown.new
    )
  end

  def create_scoreboard_service
    Services::Scoreboard.new(
      match_repository: @match_repository,
      prediction_repository: @prediction_repository,
      point_repository: @point_repository
    )
  end

  def result_mailer(scoreboard_service)
    Services::MatchResultMailer.new(
      match_repository: @match_repository,
      prediction_repository: @prediction_repository,
      scoreboard_service:,
      renderer: @template_renderer,
      email_sender: @email_sender,
      emails_sent_repository: @emails_sent_repository
    )
  end

  def register_match_prediction_service
    @app.set :match_prediction_service, Services::MatchPrediction.new(
      match_repository: @match_repository,
      prediction_repository: @prediction_repository,
      lockdown_policy: Policies::Lockdown.new
    )
  end

  def register_match_page_service
    @app.set :match_page_service, Services::MatchPage.new(
      match_repository: @match_repository,
      prediction_repository: @prediction_repository,
      user_repository: @user_repository,
      lockdown_policy: Policies::Lockdown.new
    )
  end

  def register_match_broadcaster_service
    @app.set :match_broadcaster_service, Services::MatchBroadcaster.new(
      match_repository: @match_repository
    )
  end

  def register_fixtures_page_service
    @app.set :fixtures_page_service, Services::FixturesPage.new(
      fixtures_repository: @fixtures_repository
    )
  end

  def register_graphs_page_service
    @app.set :graphs_page_service, Services::GraphsPage.new(
      cumulative_points_repository: @cumulative_points_repository,
      user_repository: @user_repository
    )
  end

  def register_tables_page_service
    @app.set :tables_page_service, Services::TablesPage.new(
      point_repository: @point_repository
    )
  end

  def register_admin_page_service
    @app.set :admin_page_service, Services::AdminPage.new(
      user_repository: @user_repository,
      tournament_role_repository: @tournament_role_repository
    )
  end

  def register_tournament_role_service
    @app.set :tournament_role_service, Services::TournamentRole.new(
      tournament_role_repository: @tournament_role_repository
    )
  end

  def register_edit_user_services
    @app.set :edit_user_page_service, Services::EditUserPage.new(
      user_repository: @user_repository
    )
    @app.set :edit_user_service, Services::EditUser.new(
      user_repository: @user_repository
    )
  end

  def register_sign_in_service
    @app.set :sign_in_service, Services::SignIn.new(
      user_repository: @user_repository
    )
  end

  def register_sign_up_service
    @app.set :sign_up_service, Services::SignUp.new(
      user_repository: @user_repository
    )
  end

  def register_reset_user_password_service
    @app.set :reset_user_password_service, Services::ResetUserPassword.new(
      user_repository: @user_repository
    )
  end

  def register_delete_user_service
    @app.set :delete_user_service, Services::DeleteUser.new(
      user_repository: @user_repository
    )
  end

  def register_toggle_user_admin_service
    @app.set :toggle_user_admin_service, Services::ToggleUserAdmin.new(
      user_repository: @user_repository
    )
  end
end
