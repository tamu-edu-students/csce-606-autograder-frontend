Given(/^I am logged in as an instructor$/) do
    user = User.find_or_create_by!(role: 'instructor')
    login_as(user)
  end

  Given(/^I have created an assignment with a test case of type "(.*)"$/) do |type|
    @test_case = TestCase.create!(assignment: @assignment, type: type, name: "#{type}_test")
  end

  When(/^I update the test case with valid input$/) do
    visit edit_test_case_path(@test_case)
    fill_in 'test_case_name', with: "Updated #{@test_case.name}"
    fill_in 'test_case_points', with: 10.0
    select 'i/o', from: 'test_case_type'
    click_button 'Save'
    @test_case.reload
  end

  Then(/^I should see the updated test case in the assignment$/) do
    visit assignment_path(@assignment)
    expect(page).to have_content("Updated #{@test_case.name}")
    expect(page).to have_content('i/o')
    expect(page).to have_content('10.0')
  end

  When(/^I update the test case with invalid input$/) do
    visit edit_test_case_path(@test_case)
    fill_in 'test_case_name', with: ""
    fill_in 'test_case_points', with: -5
    click_button 'Save'
  end

  Then(/^I should see an error message$/) do
    expect(page).to have_content('Error: Name can’t be blank')
    expect(page).to have_content('Error: Points must be greater than 0')
  end
