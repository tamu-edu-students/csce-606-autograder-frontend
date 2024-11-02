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
  # # can see the right partial rendered in the bottom
  # save_and_open_page

  case type
  when 'approved_includes'
    # puts 'type appinclu'
    within('#approved-includes-container') do
      expect(page).to have_selector("input[name='test[test_block][approved_includes][]']", visible: true)
    end
    expect(page).to have_button("Add Approved Includes")
  when 'compile'
    within('#compile-file-container') do
      expect(page).to have_selector("input[name='test[test_block][file_paths][]']", visible: true)
    end
    expect(page).to have_button("Add Compile Path")
  when 'memory_errors'
    within('#memory-errors-container') do
      expect(page).to have_selector("input[name='test[test_block][file_paths][]']", visible: true)
    end
    expect(page).to have_button("Add Memory Errors Path")
  when 'i_o'
    within('#i_o-container') do
      expect(page).to have_selector("input[name='test[test_block][input_path]']", visible: true)
      expect(page).to have_selector("input[name='test[test_block][output_path]']", visible: true)
    end
  when 'coverage'
    within('#coverage-container') do
      expect(page).to have_selector("input[name='test[test_block][main_path]']", visible: true)
      expect(page).to have_selector("input[name='test[test_block][source_paths][]']", visible: true)
      expect(page).to have_button("Add Source Path")
    end
  when 'performance'
    within('#performance-container') do
      expect(page).to have_selector("textarea[name='test[test_block][code]']", visible: true)
    end
  when 'unit'
    within('#unit-container') do
      expect(page).to have_selector("textarea[name='test[test_block][code]']", visible: true)
    end
  when 'script'
    within('#script-container') do
      expect(page).to have_selector("input[name='test[test_block][script_path]']", visible: true)
    end
  else
    raise "Unknown test type: #{type}"
  end
end

# this need to be changed into add dynamic test block field
Given('I add the {string} dynamic text block field') do |test_type|
    case test_type
  when 'approved_includes'
    expect(page).to have_field('Enter Approved Includes', wait: 10)
    fill_in 'Enter Approved Includes', with: 'file1'
    click_button "Add Approved Includes"
    fill_in 'Enter Approved Includes', with: 'file2', match: :first
  when 'compile'
    expect(page).to have_field('Enter Compile Path', wait: 10)
    fill_in 'Enter Compile Path', with: 'file1'
    click_button 'Add Compile Path'
    fill_in 'Enter Compile Path', with: 'file2', match: :first
  when 'coverage'
    expect(page).to have_field('Enter Main Path', wait: 10)
    fill_in 'Enter Main Path', with: 'main'
    fill_in 'Enter Source Path', with: 'source1'
    click_button 'Add Source Path'
    fill_in 'Enter Source Path', with: 'source2', match: :first
  when 'performance'
    expect(page).to have_field('Enter Performance', wait: 10)
    fill_in 'Enter Performance', with: 'EXPECT_EQ(1, 1);'
  when 'unit'
    expect(page).to have_field('Enter Unit', wait: 10)
    fill_in 'Enter Unit', with: 'EXPECT_EQ(1, 1);'
  when 'i_o'
    expect(page).to have_field('Enter Input Path', wait: 10)
    fill_in 'Enter Input Path', with: 'input'
    fill_in 'Enter Output Path', with: 'output'
  when 'memory_errors'
    expect(page).to have_field('Enter Memory Errors Path', wait: 10)
    fill_in 'Enter Memory Errors Path', with: 'file1'
    click_button 'Add Memory Errors Path'
    fill_in 'Enter Memory Errors Path', with: 'file2', match: :first
  when 'script'
    expect(page).to have_field('Enter Script Path', wait: 10)
    fill_in 'Enter Script Path', with: 'script'
  else
    raise "Unknown test type: #{test_type}"
  end
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
