require 'rspec/mocks'

Before do
  RSpec::Mocks.setup
  allow_any_instance_of(Assignment).to receive(:push_changes_to_github)
  allow_any_instance_of(TestsHelper).to receive(:current_user_and_token).and_return(
  [ User.create!(id: 1, name: 'Test User', email: 'test@example.com'), 'fake_github_token' ])
end

After do
  RSpec::Mocks.teardown
end


Then('the .tests file should contain the properly formatted test') do |table|
  table.hashes.each do |test_params|
    expected = "/*\n" +
    "@name: #{test_params['name']}\n" +
    "@points: #{test_params['points'].to_f}\n" +
    "@test_type: #{test_params['type']}\n" +
    "@target: #{test_params['target']}\n" +
    "*/\n" +
    "<test>\n" +
    "#{test_params['test_code']}\n" +
    "</test>\n"
    
    file_path = File.join(ENV["ASSIGNMENTS_BASE_PATH"], @assignment.repository_name, "tests", "c++", "code.tests")
    actual_content = File.read(file_path)
    # expect the strings to be equAL
    expect(actual_content).to eq(expected)
  end
end

Then('the .tests file should contain the remaining {string} tests') do |string|
  # count the number of tests in the file
  file = File.read(
  File.join(ENV["ASSIGNMENTS_BASE_PATH"],
  @assignment.repository_name,
  "code.tests"
  )).to include(expected)
  expect(file.scan(/<test>/).count).to eq(string.to_i)
end

When('I add a new unit test called {string}') do |string|
  steps %(
        When I create a new test with type "unit"
        And with the name "#{string}"
    )
end

When('I set it to {string} points') do |string|
  steps %(
        When with the points "#{string}"
    )
end

When('I set the target to {string}') do |string|
  steps %(
        When with the target "#{string}"
    )
end

When('I fill in the test block with {string}') do |string|
  fill_in 'Actual test', with: string
end

Then('I should see a success message') do
  expect(page).to have_content('Test was successfully created')
end

Given('the assignment contains one test') do
  steps %(
        Given I have created a test case of type "unit"
    )
end

Then('the .tests file should contain both properly formatted tests') do
  # create a new test
  
end

Given('the assignment contains {string} tests') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

When('I delete the {string} test') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end
