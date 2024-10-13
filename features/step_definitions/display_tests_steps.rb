Given(/^I am logged in as a (instructor|TA)$/) do |role|
  user = User.find_or_create_by!(role: role)
  login_as(user)
end

  Given(/^I am on the "Assignment Management" page for "(.*)"$/) do |assignment_name|
    @assignment = Assignment.find_or_create_by!(assignment_name: assignment_name)
    # mkdrir_p
    FileUtils.mkdir_p(File.join(@assignment.local_repository_path))
    visit assignment_path(@assignment)

    expect(page).to have_content(@assignment.assignment_name)
  end

  Given(/^there is a test case of type "(.*)"$/) do |type|
    click_link('Add new test')
    select type, from: 'Test type'
  end

  Given(/^the test case has name "(.*)"$/) do |name|
    fill_in 'Name', with: name
    fill_in 'Points', with: '10'
    fill_in 'Target', with: 'target.cpp'
    fill_in 'Actual test', with: 'actual test'
  end

  When(/^I click on that test case$/) do
    click_on "Create Test"
  end

  Then(/^I should see the correct details of the test case$/) do
    expect(page).to have_content('Test was successfully created')
  end
