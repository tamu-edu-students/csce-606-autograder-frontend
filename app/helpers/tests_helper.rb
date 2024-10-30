module TestsHelper
  def update_remote(user, auth_token)
    @assignment.generate_tests_file
    @assignment.push_changes_to_github(user, auth_token)
  end

  def current_user_and_token
    [ User.find(session[:user_id]), session[:github_token] ]
  end

  # To remain compatible with the existing test_block,
  # treat it as JSON string. This can be removed once
  # dynamic test block partials are complete.
  def parse_test_block(test_block_param)
    begin
      if test_block_param.present?
        JSON.parse(test_block_param)
      else
        {}
      end
    rescue JSON::ParserError => e
      Rails.logger.error "Error parsing test block: #{e.message}"
      {}
    end
  end
end
