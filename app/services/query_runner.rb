class QueryRunner
  def initialize(db_pool:, environment:, logger: nil)
    @db_pool = db_pool
    @environment = environment
    @logger = logger
  end

  def run_query(statement, *params)
    @db_pool.with do |conn|
      run_query_on_connection(conn, statement, *params)
    end
  end

  def run_script(sql)
    @db_pool.with do |conn|
      conn.exec(sql)
    end
  end

  private

  def run_query_on_connection(conn, statement, *params)
    if @environment == 'development' && @logger
      @logger.info "\n#{get_sql(statement, params)}"
    end

    conn.exec_params(statement, params)
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
    p_dt = "'#{convert_date(p)} #{convert_time(p)}'"
    [p_int, p_text, p_date, p_time, p_dt]
  end

  # rubocop:disable Metrics/AbcSize
  def get_sql(statement, params)
    sql = statement
    params.each_with_index do |p, i|
      formatted_param = convert_param(p)
      sql = sql.gsub("$#{i + 1}::int",       formatted_param[0])
      sql = sql.gsub("$#{i + 1}::text",      formatted_param[1])
      sql = sql.gsub("$#{i + 1}::date",      formatted_param[2])
      sql = sql.gsub("$#{i + 1}::time",      formatted_param[3])
      sql = sql.gsub("$#{i + 1}::timestamp", formatted_param[4])
      sql = sql.gsub("$#{i + 1}",            p.to_s)
    end
    sql
  end
  # rubocop:enable Metrics/AbcSize
end
