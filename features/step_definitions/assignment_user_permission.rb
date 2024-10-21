Given("I am on the {string} page for user permissions") do |page_name|
    visit assignments_path if page_name == "Manage Assignments"
end

When("I click on {string} for {string}") do |link, assignment|
    within("tr", text: assignment) do
        click_link link
    end
end

When('I {string} {string} for the user {string}') do |action, access, username|
    stub_request(:put, %r{https://api\.github\.com/repos/AutograderFrontend/.+/collaborators/.+})
    .with(
      body: hash_including("permission"),
      headers: {
        'Accept' => 'application/vnd.github.v3+json',
        'Content-Type' => 'application/json',
        'User-Agent' => /Octokit Ruby Gem.*/
      }
    )
    .to_return(status: 200, body: "", headers: {})
    user = User.find_by(name: username)
    checkbox_id = "#{access}_user_#{user.id}"

    case action.downcase
    when "select"
      check(checkbox_id)
    when "deselect"
      uncheck(checkbox_id)
    else
      raise "Unknown action: #{action}. Use 'select' or 'deselect'."
    end
end
