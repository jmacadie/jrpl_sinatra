require 'concurrent'

class Lockdown
  include Concurrent::Async

  def initialize(application)
    super()
    @app = application
    @lockdown_threshold = Time.now + @app.lockdown_buffer
  end

  def locked_down?(match)
    match[:match_datetime] < @lockdown_threshold
  end

  def check_lockdown
    matches = @app.storage.lockdown_matches()
    matches.each { |m| check_one_match(m) }
  end

  private

  def check_one_match(match)
    return unless locked_down?(match)
    send_lockdown_email(match)
    @app.storage.record_predictions_email_sent(match[:match_id])
  end

  def send_lockdown_email(match)
    subject = "#{match[:match_id]} locked down"
    body = "#{match[:match_id]} locked down"
    @app.send_email(subject, body)
  end
end
