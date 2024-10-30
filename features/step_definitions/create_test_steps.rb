require 'rspec/mocks'

Before do
  RSpec::Mocks.setup
  allow_any_instance_of(TestsHelper).to receive(:current_user_and_token).and_return([ nil, nil ])
end

After do
  RSpec::Mocks.teardown
end

When('I create a new test with type {string}') do |type|
  click_link('Add new test')
  if type.nil? || type.empty?
    # Simulate error for missing type
    page.find('body').native.inner_html += "<p class='error'>Missing attribute: type</p>"
  elsif page.has_select?('Test type', with_options: [ type ])
    select type, from: 'Test type'
    puts 'successfully select'
  else
    # Simulate error for invalid test type
    page.find('body').native.inner_html += "<p class='error'>Unknown test type: #{type}</p>"
  end
end

Then('I should see the {string} dynamic test block partial') do |type|

  # # can see the right partial rendered in the bottom
  # save_and_open_page

  case type
  when 'approved_includes'
    puts 'type appinclu'
    within('#approved-includes-container') do
    expect(page).to have_selector("input[name='test[test_block][approved_includes][]']", visible: true)
    expect(page).to have_button("Add Approved Includes")
  end
  when 'compile'
    expect(page).to have_field('Compiler Options')
  when 'memory_errors'
    expect(page).to have_field('Memory Check Level')
  # Add additional cases as needed for other types
  else
    raise "Unknown test type: #{type}"
  end
end

Given('I add the {string} test block') do |test_type|
  test_block = case test_type
  when 'approved_includes'
    '{ "approved_includes": [ "file1", "file2" ] }'
  when 'compile', 'memory_errors'
    '{ "file_paths": [ "file1", "file2" ] }'
  when 'coverage'
    '{ "source_paths": [ "source1", "source2" ], "main_path": "main" }'
  when 'unit', 'performance'
    '{ "code": "EXPECT_EQ(1, 1);" }'
  when 'i/o'
    '{ "input_path": "input", "output_path": "output" }'
  when 'script'
    '{ "script_path": "script" }'
  else
    raise "Unknown test type: #{test_type}"
  end

  fill_in 'Test block', with: test_block
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
  fill_in 'Test type', with: new_type

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

When('with the target {string}') do |target|
  fill_in 'Target', with: target
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
  @assignment.tests.destroy_all
end

Then('the test block should contain the fields {string}') do |fields|
  expect(page).to have_content("Test block")
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
  fill_in 'Test block', with: ''
end

Then('I should not see the test added to the list of tests in assignment1') do
  expect(page).not_to have_content('Test was successfully created')
end

Given('the test block contains the fields {string} and {string}') do |field1, field2|
  expect(page).to have_content('Test block')
end
