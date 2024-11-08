Given(/^I am logged in as an instructor$/) do
    user = User.find_or_create_by!(role: 'instructor')
    login_as(user)
  end

  Given('I have created a test case of type {string}') do |test_type|
    visit assignment_path(@assignment)
    click_link('Add New Test')
    select test_type, from: 'Test Type'
    fill_in 'Name', with: 'name'
    fill_in 'Points', with: 10
    page.execute_script("document.getElementById('test_target').value = 'target.cpp';")
    steps %(And I add the "#{test_type}" dynamic text block field)
    click_button "Create Test"

    # Wait for the success message to ensure the test case is created
    Capybara.using_wait_time(10) do
      expect(page).to have_content("Test was successfully created")
    end

    @assignment.reload
    @test_case = @assignment.tests.last
    puts "Test Case ID: #{@test_case&.id}"
  end

  Given(/^I have created an assignment with a test case of type "(.*)"$/) do |type|
    @test_case = TestCase.create!(assignment: @assignment, type: type, name: "#{type}_test")
  end

  When('I view the test') do
    visit assignment_path(@assignment, test_id: @test_case.id)
  end

  Then('I should see the test type as a read-only text field') do
    # Check that the test type is displayed as a read-only text field and not as a dropdown
    expect(page).to have_field('Test Type', readonly: true)
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
