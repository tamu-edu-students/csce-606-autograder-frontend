Given(/^I am logged in as an instructor or TA$/) do
    user = User.find_or_create_by!(role: [ 'instructor', 'TA' ].sample)
    login_as(user)
  end

  Given(/^I am on the "Assignment Management" page for "(.*)"$/) do |assignment_name|
    assignment = Assignment.find_by!(name: assignment_name)
    visit assignment_management_path(assignment)

    expect(page).to have_content(assignment.name)
  end

  Given(/^there is a test case of type "(.*)"$/) do |type|
    @test_case = TestCase.create!(type: type, assignment: @current_assignment)
  end

  Given(/^the test case has name "(.*)"$/) do |name|
    @test_case.update!(name: name)
  end

  When(/^I click on that test case$/) do
    find('tr', text: @test_case.name).click
  end

  Then(/^I should see the correct details of the test case$/) do
    expect(page).to have_content(@test_case.name)
    expect(page).to have_content(@test_case.type)
    expect(page).to have_content(@test_case.points.to_s)
    expect(page).to have_content(@test_case.target || 'N/A')
    expect(page).to have_content(@test_case.include || 'N/A')
    expect(page).to have_content(@test_case.number || 'N/A')
    expect(page).to have_content(@test_case.timeout.to_s)
    expect(page).to have_content(@test_case.visibility || 'visible')
    expect(page).to have_content(@test_case.show_output ? 'True' : 'False')
    expect(page).to have_content(@test_case.skip ? 'True' : 'False')
  end
