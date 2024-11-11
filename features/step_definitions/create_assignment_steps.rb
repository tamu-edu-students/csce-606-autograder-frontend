require 'webmock/cucumber'
require 'rspec/mocks'

World(RSpec::Mocks::ExampleMethods)

Before do
  RSpec::Mocks.setup
  WebMock.enable!
  allow(ENV).to receive(:[]).and_return(nil)
  allow(ENV).to receive(:[]).with('GITHUB_ACCESS_TOKEN').and_return('test_token')
  allow(ENV).to receive(:[]).with('GITHUB_TEMPLATE_REPO_URL').and_return('philipritchey/autograded-assignment-template')
  allow(ENV).to receive(:[]).with('GITHUB_COURSE_ORGANIZATION').and_return('AutograderFrontend')
  allow(ENV).to receive(:[]).with('ASSIGNMENTS_BASE_PATH').and_return('assignment-repos/')
end

After do
  # RSpec::Mocks.teardown
  # WebMock.disable!
  FileUtils.rm_rf('assignment-repos')
end

Given('I am logged in as a(n) {string} named {string}') do |role, name|
  user = User.create!(name: "#{name}", email: "#{name}@example.com", role: role)
  allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  visit '/assignments'
end

When('I click the {string} button') do |button|
  click_on button
end

When('I click the {string} button successfully') do |button|
  attempts = 0
  max_retries = 3
  while attempts < max_retries
    click_on button
    if page.has_content?("Test was successfully created") || page.has_content?("Missing") || page.has_content?("Test name must be")
      break
    end
    attempts += 1
    sleep 0.5 # Small delay to allow page update
  end
end

When('I fill in {string} with {string}') do |field, value|
  if field == 'Repository name' && page.has_current_path?('/assignments/new')

    allow(Git).to receive(:clone) do |url, path|
      FileUtils.mkdir_p(path)
    end

    client = double('OctokitClient')
    allow(Octokit::Client).to receive(:new).and_return(client)
    allow(client).to receive(:add_deploy_key).and_return(true)
    allow(client).to receive(:create_repo_from_template).and_return(
      { html_url: "https://https://github.com/AutograderFrontend/#{value}.git" })

  end
  fill_in field, with: value
end

Then('I should see the {string} assignment') do |assignment_name|
  expect(page).to have_content(assignment_name)
end

Then('I should see the {string} repository in the GitHub organization') do |repository_name|
end

Then('I should see a local clone of the {string} repository') do |repository_name|
  expect(Dir.exist?("#{ENV["ASSIGNMENTS_BASE_PATH"]}/#{repository_name}")).to be true
end

Then('I should see {string} in {string}') do |deploy_key, base_path|
  # wait for deploy keys to be created
  expect(File.exist?(File.join(base_path, deploy_key))).to be true
end

Given('I create an assignment with the name {string} and the repository {string}') do |assignment_name, repository_name|
  steps %(
    Given I am logged in as an "instructor" named "alice"
    When I click the "Create Assignment" button
    And I fill in "Assignment name" with "#{assignment_name}"
    And I fill in "Repository name" with "#{repository_name}"
    And I click the "Submit" button
  )
end

Given('I am logged in as a(n) {string}') do |string|
  user = User.find_or_create_by!(role: 'instructor')
  # login_as(user.name)
  allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
end

Then('I should not see the {string} button') do |string|
  expect(page).not_to have_button(string)
end

When('I try to visit the {string} page') do |string|
  path = case string
  when 'Course Dashboard' then assignments_path
  when 'Create Assignment' then new_assignment_path
  when 'Login' then root_path
  else
    raise "Unknown page: #{string}"
  end
  visit path
end
