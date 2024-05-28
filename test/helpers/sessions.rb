def nil_session
  { 'rack.session' => {
    user_name: nil,
    user_id: nil,
    user_email: nil
  } }
end

def admin_session
  { 'rack.session' => {
    user_name: 'Maccas',
    user_id: 4,
    user_email: 'james.macadie@telerealtrillium.com',
    user_roles: 'Admin'
  } }
end

def admin_session_with_all_criteria
  { 'rack.session' => {
    user_name: 'Maccas',
    user_id: 4,
    user_email: 'james.macadie@telerealtrillium.com',
    user_roles: 'Admin',
    criteria: {
      match_status: "all",
      prediction_status: "all",
      tournament_stages:
        ["Group Stages",
         "Round of 16",
         "Quarter Finals",
         "Semi Finals",
         "Third Fourth Place Play-off",
         "Final"]
    }
  } }
end

def non_admin_session
  { 'rack.session' => {
    user_name: 'Clare Mac',
    user_id: 11,
    user_email: 'clare@macadie.co.uk'
  } }
end

def non_admin_session_with_all_criteria
  { 'rack.session' => {
    user_name: 'Clare Mac',
    user_id: 11,
    user_email: 'clare@macadie.co.uk',
    criteria: {
      match_status: "all",
      prediction_status: "all",
      tournament_stages:
      ["Group Stages",
       "Round of 16",
       "Quarter Finals",
       "Semi Finals",
       "Third Fourth Place Play-off",
       "Final"]
    }
  } }
end

def non_admin_session_predicted_criteria
  { 'rack.session' => {
    user_name: 'Clare Mac',
    user_id: 11,
    user_email: 'clare@macadie.co.uk',
    criteria: {
      match_status: "all",
      prediction_status: "predicted",
      tournament_stages:
        ["Group Stages",
         "Round of 16",
         "Quarter Finals",
         "Semi Finals",
         "Third Fourth Place Play-off",
         "Final"]
    }
  } }
end

def non_admin_session_not_predicted_group_stages_criteria
  { 'rack.session' => {
    user_name: 'Clare Mac',
    user_id: 11,
    user_email: 'clare@macadie.co.uk',
    criteria: {
      match_status: "all",
      prediction_status: "not_predicted",
      tournament_stages: ["Group Stages"]
    }
  } }
end
