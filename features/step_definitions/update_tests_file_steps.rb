require 'rspec/mocks'

Before do
  RSpec::Mocks.setup
  allow_any_instance_of(Assignment).to receive(:push_changes_to_github)

  allow_any_instance_of(Assignment).to receive(:fetch_directory_structure).and_return(
    [
      { name: ".gitignore", type: "file" },
      { name: "README.md", type: "file" },
      { name: "tests", type: "directory", children: [
        { name: "unit_test.cpp", type: "file" }
      ] }
    ]
  )

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
  case test_type
  when 'unit'
    fill_in 'Enter Unit', with: test
  when 'approved_includes', 'compile', 'memory_errors', 'i_o',
    'script', 'coverage', 'performance'
    raise "Step not implemented for test type: #{test_type}"
  else
    raise "Unknown test type: #{test_type}"
  end
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
  stub_request(:get, "https://api.github.com/repos/AutograderFrontend/#{@assignment.repository_name}/contents/tests/c++").
        with(
          headers: {
          'Accept'=>'application/vnd.github.v3+json',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type'=>'application/json',
          'User-Agent'=>'Octokit Ruby Gem 9.1.0'
          }).
  to_return(status: 200, body: [], headers: {})
  for i in 1..string.to_i
    visit assignment_path(@assignment)
    click_link('Add New Test')
    select "unit", from: 'Test Type'
    fill_in 'Name', with: "test#{i}"
    fill_in 'Points', with: 10
    page.execute_script("document.getElementById('test_target').value = 'target.cpp';")
    steps %(And I add the "unit" dynamic text block field)
    click_button "Create Test"

    # Wait for the success message to ensure the test case is created
    Capybara.using_wait_time(50) do
      expect(page).to have_content("Test was successfully created")
    end
  end
end

When('I delete the {string} test') do |string|
  test = @assignment.tests.find_by(name: "test#{string.to_i+1}")
  puts
  visit assignment_path(@assignment, test_id: test.id)
  click_button 'Delete Test'

  page.driver.browser.switch_to.alert.accept
end
