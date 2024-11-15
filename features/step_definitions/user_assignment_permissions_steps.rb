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

Given("the following permissions exist:") do |table|
  table.hashes.each do |hash|
    user = User.find_or_create_by!(name: hash['user'])
    assignment = Assignment.find_or_create_by!(repository_name: hash['assignment'])
    @permission = Permission.create!(user: user, assignment: assignment, role: hash['role'])
  end
end

Given("I am logged in as {string}") do |username|
  login_as(username)
end

Given("I am on the {string} page for assignment permissions") do |page_name|
  visit users_path if page_name == "Manage Users"
end

# Step definitions for user interactions
When("I click on {string}") do |link|
  if link == "include"
    find('#test_include').click
    expect(page).to have_css('#include-file-tree-dropdown', visible: true, wait: 5)
  elsif link == "compile"
    find('#test_block_compile_paths').click
    expect(page).to have_css('#compile-file-tree-dropdown', visible: true, wait: 5)
  elsif link == "source-paths"
    find('#test_block_source_paths').click
    expect(page).to have_css('#source-path-file-tree-dropdown', visible: true, wait: 5)
  elsif link == "memory_errors"
    find('#test_block_mem_error_paths').click
    expect(page).to have_css('#mem-error-file-tree-dropdown', visible: true, wait: 5)
  else
    click_link link
  end
end

When('I {string} {string} for the assignment {string}') do |action, access, repository_name|
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
  assignment = Assignment.find_by(repository_name: repository_name)
  checkbox_id = "#{access}_assignment_#{assignment.id}"

  case action.downcase
  when "select"
    check(checkbox_id)
  when "deselect"
    uncheck(checkbox_id)
  else
    raise "Unknown action: #{action}. Use 'select' or 'deselect'."
  end
end

When('I select {string} for the {string} permission') do |action, permission_type|
    button_id = case [ action, permission_type ]
    when [ "Select All", "read" ]
      "#select-all-read"
    when [ "Revoke All", "read" ]
      "#revoke-all-read"
    when [ "Select All", "write" ]
      "#select-all-write"
    when [ "Revoke All", "write" ]
      "#revoke-all-write"
    else
      raise "Unknown action or permission type: #{action} #{permission_type}"
    end

    find(button_id).click
end

When("I click {string}") do |button_text|
  if button_text == "Save Changes"
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
    stub_request(:delete, %r{https://api\.github\.com/repos/AutograderFrontend/.+/collaborators/.+})
    .with(
      headers: {
        'Accept' => 'application/vnd.github.v3+json',
        'Content-Type' => 'application/json',
        'User-Agent' => /Octokit Ruby Gem.*/
      }
    )
    .to_return(status: 204, body: "", headers: {})
  end
  click_button button_text
end

# Step definitions for verifying results
Then("I should see that {string} has {string} access to the remote {string} repository") do |name, access_type, repo_name|
  user = User.find_by(name: name)
  assignment = Assignment.find_by(repository_name: repo_name)
  permission = Permission.find_by(user: user, assignment: assignment)

  expected_role = case access_type
  when "read"
    "read"
  when "write"
    "read_write"
  else
    "no-permission"
  end

  github_permission = (permission.role == "read_write") ? "push" : "pull"

  if permission.role == "read" || permission.role == "read_write"
    expect(WebMock).to have_requested(:put, %r{https://api\.github\.com/repos/AutograderFrontend/#{repo_name}/collaborators/#{user.name}})
      .with(
        body: hash_including("permission" => github_permission),
        headers: {
          'Accept' => 'application/vnd.github.v3+json',
          'Content-Type' => 'application/json',
          'User-Agent' => /Octokit Ruby Gem.*/
        }
      )
  elsif permission.role == "no-permission"
    expect(WebMock).to have_requested(:delete, "https://api.github.com/repos/#{repo_identifier}/collaborators/#{user_name}")
      .with(
        headers: {
          'Accept' => 'application/vnd.github.v3+json',
          'Content-Type' => 'application/json',
          'User-Agent' => /Octokit Ruby Gem.*/
        }
      )
  end
end
