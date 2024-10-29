Given(/^I am logged in as an instructor$/) do
    user = User.find_or_create_by!(role: 'instructor')
    login_as(user)
  end

  Given('I have created a test case of type {string}') do |test_type|
    visit assignment_path(@assignment)
    click_link('Add new test')
    select test_type, from: 'Test type'
    fill_in 'Name', with: 'name'
    fill_in 'Points', with: 10
    fill_in 'Target', with: 'target.cpp'
    steps %(And I add the "#{test_type}" test block)
    click_button "Create Test"

    @test_case = @assignment.tests.last
  end

  Given(/^I have created an assignment with a test case of type "(.*)"$/) do |type|
    @test_case = TestCase.create!(assignment: @assignment, type: type, name: "#{type}_test")
  end

  When(/^I update the test case with valid input$/) do
    # Navigate to the assignment management page (the show page with the form)
    visit  assignment_path(@assignment, test_id: @test_case.id)

    # Find and edit the test
    within('#test-details') do
      fill_in 'Name', with: "Updated #{@test_case.name}"
      fill_in 'Points', with: 10.0
      select 'i/o', from: 'Test type'
      click_button 'Update Test'  # Update button in the form
    end

    @test_case.reload  # Reload the test case to reflect the updated values
  end

  When('I delete the test case') do
    visit assignment_path(@assignment, test_id: @test_case.id)
    click_button 'Delete Test'
  end

  Then(/^I should see the updated test case in the assignment$/) do
    visit assignment_path(@assignment)
    expect(page).to have_content("#{@test_case.name}")
    expect(page).to have_content('i/o')
    expect(page).to have_content('10.0')
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
