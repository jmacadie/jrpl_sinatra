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
    register_account_services
    register_admin_services
    register_core_services
    register_page_services
  end

  private

  def register_account_services
    register_edit_user_service
    register_remember_me_service
    register_sign_in_service
    register_sign_up_service
  end

  def register_admin_services
    register_broadcaster_service
    register_delete_user_service
    register_reset_user_password_service
    register_result_service
    register_toggle_user_admin_service
    register_tournament_role_service
  end

  def register_core_services
    register_lockdown_service
    register_prediction_service
  end

  def register_page_services
    register_admin_page_service
    register_fixtures_page_service
    register_graphs_page_service
    register_match_page_service
    register_tables_page_service
  end

  def register_query_runner
    @app.set :query_runner, Repositories::QueryRunner.new(
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
    @template_renderer = Renderers::SinatraTemplate.new(app: @app.new!)
  end

  def register_email_sender
    @email_sender = Services::Mailers::EmailSender.new(
      query_runner: @app.settings.query_runner,
      config: @app.settings.email,
      environment: @app.environment
    )
    @app.set :email_sender, @email_sender
  end

  def register_lockdown_service
    mr_men_service = Services::Core::MrMen.new(
      prediction_repository: @prediction_repository
    )
    mailer = predictions_mailer
    @app.set :lockdown_service, Services::Core::Lockdown.new(
      match_repository: @match_repository,
      mr_men_service:,
      predictions_mailer: mailer,
      lockdown_policy: Policies::Lockdown.new
    )
  end

  def predictions_mailer
    Services::Mailers::Predictions.new(
      match_repository: @match_repository,
      prediction_repository: @prediction_repository,
      emails_sent_repository: @emails_sent_repository,
      renderer: @template_renderer,
      email_sender: @email_sender
    )
  end

  def register_result_service
    scoreboard_service = create_scoreboard_service
    mailer = result_mailer(scoreboard_service)
    @app.set :match_result_service, Services::Admin::Result.new(
      match_repository: @match_repository,
      scoreboard_service:,
      result_mailer: mailer,
      lockdown_policy: Policies::Lockdown.new
    )
  end

  def create_scoreboard_service
    Services::Core::Scoreboard.new(
      match_repository: @match_repository,
      prediction_repository: @prediction_repository,
      point_repository: @point_repository
    )
  end

  def result_mailer(scoreboard_service)
    Services::Mailers::Result.new(
      match_repository: @match_repository,
      prediction_repository: @prediction_repository,
      scoreboard_service:,
      renderer: @template_renderer,
      email_sender: @email_sender,
      emails_sent_repository: @emails_sent_repository
    )
  end

  def register_prediction_service
    @app.set :match_prediction_service, Services::Core::Prediction.new(
      match_repository: @match_repository,
      prediction_repository: @prediction_repository,
      lockdown_policy: Policies::Lockdown.new
    )
  end

  def register_match_page_service
    @app.set :match_page_service, Services::Pages::Match.new(
      match_repository: @match_repository,
      prediction_repository: @prediction_repository,
      user_repository: @user_repository,
      lockdown_policy: Policies::Lockdown.new
    )
  end

  def register_broadcaster_service
    @app.set :match_broadcaster_service, Services::Admin::Broadcaster.new(
      match_repository: @match_repository
    )
  end

  def register_fixtures_page_service
    @app.set :fixtures_page_service, Services::Pages::Fixtures.new(
      fixtures_repository: @fixtures_repository
    )
  end

  def register_graphs_page_service
    @app.set :graphs_page_service, Services::Pages::Graphs.new(
      cumulative_points_repository: @cumulative_points_repository,
      user_repository: @user_repository
    )
  end

  def register_tables_page_service
    @app.set :tables_page_service, Services::Pages::Tables.new(
      point_repository: @point_repository
    )
  end

  def register_admin_page_service
    @app.set :admin_page_service, Services::Pages::Admin.new(
      user_repository: @user_repository,
      tournament_role_repository: @tournament_role_repository
    )
  end

  def register_tournament_role_service
    @app.set :tournament_role_service, Services::Admin::TournamentRole.new(
      tournament_role_repository: @tournament_role_repository
    )
  end

  def register_edit_user_service
    @app.set :edit_user_page_service, Services::Pages::EditUser.new(
      user_repository: @user_repository
    )
    @app.set :edit_user_service, Services::Accounts::EditUser.new(
      user_repository: @user_repository
    )
  end

  def register_sign_in_service
    @app.set :sign_in_service, Services::Accounts::SignIn.new(
      user_repository: @user_repository
    )
  end

  def register_remember_me_service
    @app.set :remember_me_login_service, Services::Accounts::RememberMe.new(
      cookie_repository: @cookie_repository,
      token_generator: -> { SecureRandom.hex(32) }
    )
  end

  def register_sign_up_service
    @app.set :sign_up_service, Services::Accounts::SignUp.new(
      user_repository: @user_repository
    )
  end

  def register_reset_user_password_service
    @app.set :reset_user_password_service, Services::Admin::ResetUserPassword.new(
      user_repository: @user_repository
    )
  end

  def register_delete_user_service
    @app.set :delete_user_service, Services::Admin::DeleteUser.new(
      user_repository: @user_repository
    )
  end

  def register_toggle_user_admin_service
    @app.set :toggle_user_admin_service, Services::Admin::ToggleUserAdmin.new(
      user_repository: @user_repository
    )
  end
end
