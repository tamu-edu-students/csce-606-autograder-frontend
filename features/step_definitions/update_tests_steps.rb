Given(/^I am logged in as an instructor$/) do
  user = User.find_or_create_by!(role: 'instructor')
  login_as(user)
end
Given('I have created a test case of type {string}') do |test_type|
  test_block = case test_type
  when 'approved_includes' then { approved_includes: [ 'iostream', 'vector' ] }
  when 'compile' then { file_paths: [ 'file1' ] }
  when 'memory_errors' then { file_paths: [ 'file1', 'file2' ] }
  when 'coverage' then { main_path: 'main.cpp', source_paths: [ 'source1.cpp' ] }
  when 'performance' then { code: 'EXPECT_EQ(1, 1);' }
  when 'unit' then { code: 'EXPECT_EQ(1, 1);' }
  when 'i_o' then { input_path: 'input.txt', output_path: 'output.txt' }
  when 'memory_errors' then { file_paths: [ 'file1', 'file2' ] }
  when 'script' then { script_path: 'script.sh' }
  else raise "Unknown test type: #{test_type}"
  end
  Test.create!(
    assignment: @assignment,
    test_type: test_type,
    name: "#{test_type}_test",
    target: "main.cpp",
    points: 10.0,
    test_block: test_block,
  )
  @assignment.reload
  @test_case = @assignment.tests.last
end
Given(/^I have created an assignment with a test case of type "(.*)"$/) do |type|
  @test_case = TestCase.create!(assignment: @assignment, type: type, name: "#{type}_test")
end
When('I view the test') do
  visit assignment_path(@assignment, test_id: @test_case.id)
end
Then("I should see the test type as a read-only text field") do
      field = find_field("test_test_type", readonly: true)
      expect(field.value).to eq("approved_includes")
end
When(/^I update the test case with valid input$/) do
  # Navigate to the assignment management page (the show page with the form)
  visit  assignment_path(@assignment, test_id: @test_case.id)
  # Find and edit the test
  within('#test-details') do
    fill_in 'Name', with: "Updated #{@test_case.name}"
    fill_in 'Points', with: 10.0
    click_button 'Update Test'  # Update button in the form
  end
  expect(page).to have_content("Test was successfully updated")
  @test_case.reload  # Reload the test case to reflect the updated values
end
When('I delete the test case') do
  visit assignment_path(@assignment, test_id: @test_case.id)
  click_button 'Delete Test'
  # Switch to the alert and accept it
  page.driver.browser.switch_to.alert.accept
end
Then(/^I should see the updated test case in the assignment$/) do
  visit  assignment_path(@assignment, test_id: @test_case.id)
  # save_and_open_page
  expect(page).to have_field('Name', with: @test_case.name)
  expect(page).to have_field('Points', with: '10.0')
end
Then('I should not see the test case in the assignment') do
  visit assignment_path(@assignment)
  expect(page).not_to have_content("#{@test_case.name}")
end
When(/^I update the test case with invalid input$/) do
   # Navigate to the assignment management page (the show page with the form)
   visit assignment_path(@assignment, test_id: @test_case.id)
   # Find and edit the test
   within('#test-details') do
     fill_in 'Name', with: ""
     fill_in 'Points', with: -5
     click_button 'Update Test'  # Update button in the form
   end
   @test_case.reload  # Reload the test case to reflect the updated values
end
Then(/^I should see an error message$/) do
  expect(page).to have_content('Missing attributes: name')
  expect(page).to have_content('Points must be greater than 0')
end