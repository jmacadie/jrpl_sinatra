require 'pg'

require_relative 'cookies'
require_relative 'login'
require_relative 'match_predictions'
require_relative 'matches'
require_relative 'points'
require_relative 'predictions'
require_relative 'users'

class DatabasePersistence
  include DBPersCookies
  include DBPersLogin
  include DBPersMatchPredictions
  include DBPersMatches
  include DBPersPoints
  include DBPersPredictions
  include DBPersUsers

  # rubocop:disable Metrics/AbcSize
  def initialize(logger, conf)
    hash = { dbname: conf['database'] }
    hash[:host] = conf['host'] if !conf['host'].nil?
    hash[:port] = conf['port'] if !conf['port'].nil?
    hash[:user] = conf['username'] if !conf['username'].nil?
    hash[:password] = conf['password'] if !conf['password'].nil?
    @db = PG.connect(**hash)
    @logger = logger
  end
  # rubocop:enable Metrics/AbcSize

  def disconnect
    @db.close
  end

  def tournament_stage_names
    sql = 'SELECT name FROM stage;'
    result = query(sql)
    result.map { |tuple| tuple['name'] }
  end

  private

  def convert_str_to_int(str)
    # This is needed because nil.to_i returns 0!!!
    str ? str.to_i : nil
  end

  def convert_date(p)
    Date.parse(p.to_s).strftime('%Y-%m-%d')
  rescue Date::Error
    ''
  end

  def convert_time(p)
    DateTime.parse(p.to_s).strftime('%H:%M:%S')
  rescue Date::Error
    ''
  end

  def convert_param(p)
    p_int = p.to_s
    p_text = "'#{p}'"
    p_date = "'#{convert_date(p)}'"
    p_time = "'#{convert_time(p)}'"
    [p_int, p_text, p_date, p_time]
  end

  # rubocop:disable Metrics/AbcSize
  def get_sql(statement, params)
    sql = statement
    params.each_with_index do |p, i|
      formatted_param = convert_param(p)
      sql = sql.gsub("\$#{i + 1}::int",  formatted_param[0])
      sql = sql.gsub("\$#{i + 1}::text", formatted_param[1])
      sql = sql.gsub("\$#{i + 1}::date", formatted_param[1])
      sql = sql.gsub("\$#{i + 1}::time", formatted_param[1])
      sql = sql.gsub("\$#{i + 1}",       p.to_s)
    end
    sql
  end
  # rubocop:enable Metrics/AbcSize

  def query(statement, *params)
    sql = get_sql(statement, params)
    @logger.info "\n#{sql}"
    @db.exec_params(statement, params)
  end
end
