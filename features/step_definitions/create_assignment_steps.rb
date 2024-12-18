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
  allow_any_instance_of(AssignmentsController).to receive(:build_complete_tree).and_return(
    [
      { name: "code.tests", path: "tests/c++/code.tests", type: "file" },
      { name: "io_tests", path: "tests/c++/io_tests", type: "dir", children: [
        { name: "input.txt", path: "tests/c++/io_tests/input.txt", type: "file" },
        { name: "output.txt", path: "tests/c++/io_tests/output.txt", type: "file" },
        { name: "readme.txt", path: "tests/c++/io_tests/readme.txt", type: "file" }
      ] }
    ]
  )
  allow_any_instance_of(Assignment).to receive(:init_run_autograder_script)
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

Given('I create an assignment with the name {string} and the repository {string} and files {string}') do |assignment_name, repository_name, files|
  steps %(
    Given I am logged in as an "instructor" named "alice"
    When I click the "Create Assignment" button
    And I fill in "Assignment name" with "#{assignment_name}"
    And I fill in "Repository name" with "#{repository_name}"
    And I add "#{files}" to the "Approved files" field
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

Then('I should see the "Approved files" text area') do
  expect(page).to have_field("assignment[files_to_submit]")
end

When('I add {string} to the "Approved files" field') do |approved_files|
  expected_files = approved_files.gsub(/\\n/, ' ').split.map(&:strip).reject(&:empty?).join(" ")
  allow(Git).to receive(:clone) do |url, path|
    FileUtils.mkdir_p(path)
    run_autograder_path = File.join(path, "run_autograder")
    File.open(run_autograder_path, "w") do |file|
      file.write("files_to_submit=( #{expected_files} )")
    end
  end
  fill_in 'assignment[files_to_submit]', with: approved_files
end

Given('an assignment with name {string}, repository name {string}, and approved files {string}') do |assignment_name, repository_name, files|
  steps %(
    Given I am logged in as an "instructor" named "alice"
    When I click the "Create Assignment" button
    And I fill in "Assignment name" with "#{assignment_name}"
    And I fill in "Repository name" with "#{repository_name}"
    And I add "#{files}" to the "Approved files" field
    And I click the "Submit" button
  )
end
