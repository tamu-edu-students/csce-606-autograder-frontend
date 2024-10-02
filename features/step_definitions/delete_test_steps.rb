Given('I am logged in as an instructor') do
    @user = User.create!(email: 'email@gmail.com', password: 'password', role: 'instructor') 
    login_as(@user)  # implement
  end
  
  Given('I have created an assignment with a test case of type {string}') do |test_type|
    @assignment = Assignment.create!(assignment_name: 'Assignment', repository_name: 'repo')  
    @test = @assignment.tests.create!(name: 'Test Case 1', test_type: test_type, points: 10, target: 'test_target.cpp') 
  end
  
  When('I delete the test case') do
    visit assignment_tests_path(@assignment)  # Navigate to the page showing all tests for the assignment implement
    click_link 'Delete', match: :first  # Click the delete link for the test case
  end
  
  Then('I should be prompted to confirm the deletion') do
    page.driver.browser.switch_to.alert.text  # Capture the alert text for confirmation
    expect(page.driver.browser.switch_to.alert.text).to eq('Are you sure you want to delete this test case?')  
  end
  
  Then('I should not see the test case in the assignment') do
    expect(page).not_to have_content(@test.name)  
  end
  