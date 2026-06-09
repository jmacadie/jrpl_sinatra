module Services
  module Pages
    class Fixtures
      WARNING_MESSAGE = 'No matches meet your criteria, please try again!'

      STAGE_PARAMS = {
        group: 'st_gr',
        round32: 'st_r32',
        round16: 'st_r16',
        quarter_final: 'st_qf',
        semi_final: 'st_sf',
        final: 'st_f'
      }.freeze

      GROUP_PARAMS = ('A'..'L').to_h do |group|
        [group.to_sym, "gr_#{group}"]
      end.freeze

      Result = Struct.new(
        :criteria,
        :matches,
        :stage_names,
        :match_ids,
        :message,
        :message_level,
        keyword_init: true
      )

      def initialize(fixtures_repository:)
        @fixtures_repository = fixtures_repository
      end

      def call(user_id:, criteria: nil, submitted_params: nil)
        submitted = !submitted_params.nil?
        criteria = criteria_from(submitted_params) if submitted
        criteria ||= default_criteria
        matches = @fixtures_repository.load_matches(criteria, user_id)
        message = warning_message(matches, submitted)

        Result.new(
          criteria:,
          matches:,
          stage_names: @fixtures_repository.stage_names,
          match_ids: matches.map { |match| match[:match_id] },
          message:,
          message_level: message && 'warning'
        )
      end

      private

      def default_criteria
        {
          exclude_played: true,
          exclude_predicted: false,
          stages: selected_by_default(STAGE_PARAMS),
          groups: selected_by_default(GROUP_PARAMS)
        }
      end

      def selected_by_default(param_map)
        param_map.to_h { |name, _| [name, true] }
      end

      def criteria_from(submitted_params)
        {
          exclude_played: posted?(submitted_params, 'exc_play'),
          exclude_predicted: posted?(submitted_params, 'exc_pred'),
          stages: selections(submitted_params, STAGE_PARAMS),
          groups: selections(submitted_params, GROUP_PARAMS)
        }
      end

      def selections(submitted_params, param_map)
        param_map.to_h do |name, param_name|
          [name, posted?(submitted_params, param_name)]
        end
      end

      def posted?(submitted_params, param_name)
        submitted_params[param_name] == 'on'
      end

      def warning_message(matches, submitted)
        WARNING_MESSAGE if submitted && matches.empty?
      end
    end
  end
end
