When('I create a new test with type {string}') do |type|
  click_link('Add new test')
  select type, from: 'Test type'
 #click_button 'Create Test'

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

Given('I go to eidt page') do
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
  @assignment = Assignment.find_by(assignment_name: 'assignment1')
  table.hashes.each do |test|
    @assignment.tests.create!(
      name: test['test_name'],
      test_type: test['test_type'],
      points: test['test_points'],
      target: test['test_target'],
      actual_test: test['actual_test']
    )
  end
end

Then('I should not see an error message saying {string}') do |message|
  expect(page).not_to have_content(message)
end

Given('the assignment contains no tests') do
  @assignment = Assignment.find_by(assignment_name: 'assignment1')
  @assignment.tests.destroy_all
end

Then('the test block should contain the fields {string}') do |fields|
  expect(page).to have_content("Actual test")
end



Given('the test block contains the field {string}') do |field|
  expect(page).to have_content("Actual test")
end

When('I fill in the field with {string}') do |value|
  fill_in 'Actual test', with: 'actual test'
end

Then('I should see the test added to the list of tests in assignment1') do
  expect(page).to have_content('Test was successfully created')
end

Then('I should see a message saying {string}') do |message|
  expect(page).to have_content(message)
end

Given('the test block has the field {string}') do |field|
  expect(page).to have_content("Actual test")
end

Given('the field is empty') do
  # Ensure the field is empty by either clearing it or checking its initial value
  fill_in 'Actual test', with: ''

end

Then('I should not see the test added to the list of tests in assignment1') do
  expect(page).not_to have_content('Test was successfully created')
end

Given('the test block contains the fields {string} and {string}') do |field1, field2|
  expect(page).to have_content('Actual test')
end

When('I fill in the field {string} with {string}') do |field, value|
  fill_in 'Actual test', with: 'actual test'
  fill_in 'Target', with: 'target'
end
