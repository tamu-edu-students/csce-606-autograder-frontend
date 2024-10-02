When('I create a new test with type {string}') do |test_type|
    visit new_assignment_test_path(@assignment)  
    fill_in 'Test Type', with: test_type  
    click_button 'Create Test'  
  end
  
  Then('I should see an error message saying {string}') do |error_message|
    expect(page).to have_content(error_message)  
  end
  
  Given('I am on the {string} page for {string}') do |page_name, assignment_name|
    @assignment = Assignment.find_by(assignment_name: assignment_name)  
    visit assignment_management_path(@assignment)  
  end
  
  Given('I create a new test with type {string}') do |test_type|
    step "I create a new test with type \"#{test_type}\""  
  end
  
  Given('there is text in the test block') do
    fill_in 'Test Block', with: 'content' 
  end
  
  When('I change the test type to {string}') do |new_test_type|
    select new_test_type, from: 'Test Type'  
  end
  
  Then('I should be prompted with a warning that the test block will be cleared') do
    expect(page).to have_content('Warning: The test block will be cleared')  
  end
  
  Then('I should see a button to confirm') do
    expect(page).to have_button('Confirm')  
  end
  
  Given('the following assignments exist:') do |table|
    table.hashes.each do |row|
      Assignment.create!(assignment_name: row['assignment_name'], repository_name: row['repository_name'])  
    end
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
    table.hashes.each do |row|
      @assignment.tests.create!(name: row['test_name'], test_type: row['test_type'], points: row['test_points'], target: row['test_target'])  
    end
  end
  
  Then('I should not see an error message saying {string}') do |error_message|
    expect(page).not_to have_content(error_message)  
  end
  
  Given('the assignment contains no tests') do
    @assignment.tests.destroy_all  
  end
  
  Then('the test block should contain the fields {string}') do |fields|
    expect(page).to have_content(fields)  
  end
  
  Given('with the name {string}') do |name|
    step "with the name \"#{name}\""  
  end
  
  Given('with the points {string}') do |points|
    step "with the points \"#{points}\""  
  end
  
  Given('the test block contains the field {string}') do |field|
    expect(page).to have_field(field)  
  end
  
  When('I fill in the field with {string}') do |value|
    fill_in 'Test Block', with: value  
  end
  
  Then('I should see the test added to the list of tests in assignment1') do
    expect(page).to have_content('Test added successfully')  
  end
  
  Then('I should see a message saying {string}') do |message|
    expect(page).to have_content(message)  
  end
  
  Given('the test block has the field {string}') do |field|
    expect(page).to have_field(field)  
  end
  
  Given('the field is empty') do
    expect(find_field('Test Block').value).to be_blank  
  end
  
  Then('I should not see the test added to the list of tests in assignment1') do
    expect(page).not_to have_content('Test added successfully')  
  end
  
  Given('the test block contains the fields {string} and {string}') do |field1, field2|
    expect(page).to have_field(field1)  
    expect(page).to have_field(field2)  
  end
  
  When('I fill in the field {string} with {string}') do |field, value|
    fill_in field, with: value  
  end
  