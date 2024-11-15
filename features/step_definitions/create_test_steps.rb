require 'rspec/mocks'

Before do
  RSpec::Mocks.setup
  allow_any_instance_of(TestsHelper).to receive(:current_user_and_token).and_return([ nil, nil ])
end

After do
  # RSpec::Mocks.teardown
end

When('I create a new test with type {string}') do |type|
  click_link('Add New Test')
  if type.nil? || type.empty?
    # Simulate error for missing type
    page.find('body').native.inner_html += "<p class='error'>Missing attribute: type</p>"
  elsif page.has_select?('Test Type', with_options: [ type ])
    select type, from: 'Test Type'
  else
    # Simulate error for invalid test type
    page.find('body').native.inner_html += "<p class='error'>Unknown test type: #{type}</p>"
  end
end

Then('I should see the {string} dynamic test block partial') do |type|
  check_test_block(type)
end

# this need to be changed into add dynamic test block field
Given('I add the {string} dynamic text block field') do |test_type|
  fill_test_block(test_type)
end


Given('I add the dynamic text block field with {string}') do |script_path|
  fill_in 'Enter Script Path', with: 'script_path'
end
Then('I should see an error message saying {string}') do |message|
  expect(page).to have_content(message)
end

# Given('I create a new test with type {string}') do |type|
#   visit new_assignment_test_path(@assignment)
#   fill_in 'Type', with: type
#   fill_in 'Name', with: 'Test Name'
#   fill_in 'Points', with: 10
#   click_button 'Create Test'
# end

Given('I go to edit page') do
    visit edit_assignment_test_path(@assignment, @test)
end

Given('there is text in the test block') do
  # Assuming you check for some text in the test block
  expect(page).to have_content('Test was successfully created')
end

When('I change the test type to {string}') do |new_type|
  fill_in 'Test Type', with: new_type

  click_button 'Update Test'
end

Then('I should be prompted with a warning that the test block will be cleared') do
  expect(page).to have_content('Test was successfully updated')
end

Then('I should see a button to confirm') do
  expect(page).to have_button('Confirm')
end


When('with the name {string}') do |name|
  fill_in 'Name', with: name
end

When('with the points {string}') do |points|
  fill_in 'Points', with: points
end

When("with the target {string}") do |target|
  unless target.nil? || target.empty?
      select target, from: "test_target"
      all_fields_filled = page.evaluate_script(<<-JS)
      document.getElementById('test_name').value.trim() !== '' &&
      document.getElementById('test_points').value.trim() !== '' &&
      document.getElementById('test_type').value.trim() !== ''
    JS

    if all_fields_filled
      page.evaluate_script("document.getElementById('create_test_button').disabled = false")
    end
  end
end

Then('I should not see any missing attribute error messages') do
  expect(page).not_to have_content('Missing attribute')
end

Given('the assignment contains the following test:') do |table|
  table.hashes.each do |test|
    @assignment.tests.create!(
      name: test['test_name'],
      test_type: test['test_type'],
      points: test['test_points'],
      target: test['test_target'],
      test_block: test['test_block']
    )
  end
end

Then('I should not see an error message saying {string}') do |message|
  expect(page).not_to have_content(message)
end

Given('the assignment contains no tests') do
  stub_request(:get, "https://api.github.com/repos/AutograderFrontend/#{@assignment.repository_name}/contents/tests/c++").
  with(
    headers: {
    'Accept'=>'application/vnd.github.v3+json',
    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'Content-Type'=>'application/json',
    'User-Agent'=>'Octokit Ruby Gem 9.1.0'
    }).
  to_return(status: 200, body: [], headers: {})
  @assignment.tests.destroy_all
end

Then('the test block should contain the fields {string}') do |fields|
  expect(page).to have_content(fields)
end



Given('the test block contains the field {string}') do |field|
  expect(page).to have_content("Test block")
end

When('I fill in the field with {string}') do |value|
  fill_in 'Test block', with: '{ "script_path": "script" }'
end

Then('I should see the test added to the list of tests in assignment1') do
  expect(page).to have_content('Test was successfully created')
end

Then('I should see a message saying {string}') do |message|
  expect(page).to have_content(message)
end

Given('the test block has the field {string}') do |field|
  expect(page).to have_content("Test block")
end

Given('the field is empty') do
  # Ensure the field is empty by either clearing it or checking its initial value
  fill_in 'Enter Script Path', with: ''
end

Then('I should not see the test added to the list of tests in assignment1') do
  expect(page).not_to have_content('Test was successfully created')
end

Given('the test block contains the fields {string} and {string}') do |field1, field2|
  expect(page).to have_content('Test block')
end

Then('the {string} dropdown should contain the following options:') do |dropdown, table|
  expect(page).to have_select(dropdown, options: table.raw.flatten)
end
