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
  RSpec::Mocks.teardown
  WebMock.disable!
  FileUtils.rm_rf('assignment-repos')
end



Given('I am logged in as a(n) {string} named {string}') do |role, name|
  # TODO: fix this once login is merged
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
      {html_url: "https://https://github.com/AutograderFrontend/#{value}.git"})
      
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

Then('I should see the {string} in {string} of the {string} repository') do |file, dir, repository_name|
  expect(File.exist?("#{ENV["ASSIGNMENTS_BASE_PATH"]}/#{repository_name}/#{dir}/#{file}")).to be true
end

Then('I should see the deploy_key in {string} of the {string} repository') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Given('An assignment with the name {string}') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

When('I try to create an assignment with the name {string}') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('I should see an error message') do
  pending # Write code here that turns the phrase above into concrete actions
end

Given('I am logged in as a {string}') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('I should not see the {string} button') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

When('I try to visit the {string} page') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end
