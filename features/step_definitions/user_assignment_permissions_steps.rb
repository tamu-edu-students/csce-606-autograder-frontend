def login_as(name)
  @current_user = User.find_by(name: name)
  # Simulate session creation
  page.set_rack_session(user_id: @current_user.id)
  # Simulate GitHub token for API calls
  page.set_rack_session(github_token: 'fake_github_token')
end

Given("the following users exist in assignment permissions:") do |table|
  table.hashes.each do |hash|
    user = User.create!(name: hash['name'], role: hash['role'])
    Assignment.all.each do |assignment|
      access = hash["#{assignment.assignment_name}_access"]
      user.assignments << assignment if access == 'read-write'
    end
  end
end

Given("I am logged in as {string}") do |username|
  login_as(username)
end

Given("I am on the {string} page for assignment permissions") do |page_name|
  visit users_path if page_name == "Manage Users"
end

# Step definitions for user interactions
When("I click on {string}") do |username|
  click_link username
end

When("I select the assignment on the page {string}") do |repo_name|
  assignment = Assignment.find_by(repository_name: repo_name)
  find(:css, "input[type='checkbox'][value='#{assignment.id}']").set(true)
end

When("I select the assignments on the page {string} and {string}") do |repo1, repo2|
  [ repo1, repo2 ].each do |repo_name|
    assignment = Assignment.find_by(repository_name: repo_name)
    checkbox = find(:css, "input[type='checkbox'][value='#{assignment.id}']", visible: :all)
    checkbox.set(true)
  end
end

When("I click Select All") do
  Assignment.all.each do |assignment|
    checkbox = find(:css, "input[type='checkbox'][value='#{assignment.id}']", visible: :all)
    checkbox.set(true) unless checkbox.checked?
  end
end

When("I click Revoke All") do
  Assignment.all.each do |assignment|
    checkbox = find(:css, "input[type='checkbox'][value='#{assignment.id}']", visible: :all)
    checkbox.set(false) if checkbox.checked?
  end
end

When("I click {string}") do |button_text|
  if button_text == "Save Changes"
    stub_request(:put, /https:\/\/api\.github\.com\/repos\/AutograderFrontend\/.*\/collaborators\/.*/).
      with(
        body: /"permission":"(push|pull)"/,
        headers: {
          'Accept'=>'application/vnd.github.v3+json',
          'Authorization'=>/token .+/,
          'Content-Type'=>'application/json'
        }
      ).
      to_return(status: 200, body: "", headers: {})
  end
  click_button button_text
end

When("I de-select the assignment on the page {string}") do |repo_name|
  assignment = Assignment.find_by(repository_name: repo_name)
  checkbox = find(:css, "input[type='checkbox'][value='#{assignment.id}']", visible: :all)
  checkbox.set(false) unless !checkbox.checked?
end

When("I de-select the assignments on the page {string} and {string}") do |repo1, repo2|
  [ repo1, repo2 ].each do |repo_name|
    assignment = Assignment.find_by(repository_name: repo_name)
    checkbox = find(:css, "input[type='checkbox'][value='#{assignment.id}']", visible: :all)
    checkbox.set(false) unless !checkbox.checked?
  end
end

# Step definitions for verifying results
Then("I should see that {string} has {string} access to the remote {string} repository") do |name, access_type, repo_name|
  user = User.find_by(name: name)
  assignment = Assignment.find_by(repository_name: repo_name)

  # Mock the GitHub API call
  allow_any_instance_of(Octokit::Client).to receive(:add_collaborator)
    .with("AutograderFrontend/#{repo_name}", name, permission: access_type == 'read-write' ? 'push' : 'pull')
    .and_return(true)

  # Verify the user's assignment access in the database
  if access_type == 'read-write'
    expect(user.assignments).to include(assignment)
  else
    expect(user.assignments).not_to include(assignment)
  end
end
