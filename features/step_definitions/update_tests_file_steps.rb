require 'rspec/mocks'

Before do
  RSpec::Mocks.setup
  allow_any_instance_of(Assignment).to receive(:push_changes_to_github)
  allow_any_instance_of(TestsHelper).to receive(:current_user_and_token).and_return(
    [ User.create!(name: 'Test User', email: 'test@example.com'), 'fake_github_token' ]
  )

  # Simulate login by setting session and current_user
  @current_user = User.create!(name: 'sam', email: 'sam@example.com', role: 'instructor')
  page.set_rack_session(user_id: @current_user.id)
end

After do
  RSpec::Mocks.teardown
  FileUtils.rm_rf(ENV["ASSIGNMENTS_BASE_PATH"])
end


Then('the .tests file should contain the properly formatted test') do |table|
  table.hashes.each do |test_params|
    expected = "/*\n" +
    "@name: #{test_params['name']}\n" +
    "@points: #{test_params['points'].to_f}\n" +
    "@test_type: #{test_params['type']}\n" +
    "@target: #{test_params['target']}\n" +
    "@number: 1\n" +
    "*/\n" +
    "<test>\n" +
    test_params['test_code'].split("\n").map { |line| "\t#{line}" }.join("\n") + "\n" +
    "</test>\n\n"

    file_path = File.join(ENV["ASSIGNMENTS_BASE_PATH"], @assignment.repository_name, "tests", "c++", "code.tests")
    actual_content = File.read(file_path)
    # expect the strings to be equal
    expect(actual_content).to include(expected)
  end
end

Then('the .tests file should contain the remaining {string} tests') do |string|
  file_path = File.join(ENV["ASSIGNMENTS_BASE_PATH"], @assignment.repository_name, "tests", "c++", "code.tests")
  file = File.read(file_path)
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

When('I fill in the {string} test block with {string}') do |test_type, test|
  test_block = case test_type
  when 'unit'
    { code: test }
  when 'approved_includes', 'compile', 'memory_errors', 'i/o',
    'script', 'coverage', 'performance'
    raise "Step not implemented for test type: #{test_type}"
  else
    raise "Unknown test type: #{test_type}"
  end

  fill_in 'Test block', with: test_block.to_json
end

Then('I should see a success message') do
  expect(page).to have_content(/Test was successfully .+/)
end

Given('the assignment contains one test') do
  steps %(
    Given I have created a test case of type "unit"
  )
end

Then('the .tests file should contain both properly formatted tests') do |table|
  table.hashes.each do |test|
    expected = "/*\n" +
    "@name: name\n" +
    "@points: 10.0\n" +
    "@test_type: unit\n" +
    "@target: target.cpp\n" +
    "@number: 1\n" +
    "*/\n" +
    "<test>\n" +
    "\tEXPECT_EQ(1, 1);\n" +
    "</test>\n\n" +
    "/*\n" +
    "@name: #{test['name']}\n" +
    "@points: #{test['points'].to_f}\n" +
    "@test_type: #{test['type']}\n" +
    "@target: #{test['target']}\n" +
    "@number: 2\n" +
    "*/\n" +
    "<test>\n" +
    test['test_code'].split("\n").map { |line| "\t#{line}" }.join("\n") + "\n" +
    "</test>\n\n"

    file_path = File.join(@assignment.local_repository_path, "tests", "c++", "code.tests")
    actual_content = File.read(file_path)
    expect(actual_content).to include(expected)
  end
end

Given('the assignment contains {string} tests') do |string|
  for i in 1..string.to_i
    visit assignment_path(@assignment)
    click_link('Add new test')
    select "unit", from: 'Test type'
    fill_in 'Name', with: "test#{i}"
    fill_in 'Points', with: 10
    fill_in 'Target', with: 'target.cpp'
    fill_in 'Test block', with: { code: 'EXPECT_EQ(1, 1);' }.to_json
    click_button "Create Test"
  end
end

When('I delete the {string} test') do |string|
  test = @assignment.tests.find_by(name: "test#{string.to_i+1}")
  visit assignment_path(@assignment, test_id: test.id)
  click_button 'Delete Test'
end
