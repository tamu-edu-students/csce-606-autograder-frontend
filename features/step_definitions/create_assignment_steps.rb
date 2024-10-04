  Given('I am logged in as an {string} named {string}') do |role, name|
    # TODO: fix this once login is merged
    visit '/assignments'
  end

  When('I click the {string} button') do |button|
    click_on button
  end

  When('I fill in {string} with {string}') do |field, value|
    fill_in field, with: value
  end

  Then('I should see the {string} assignment') do |assignment_name|
    expect(page).to have_content(assignment_name)
  end

  Then('I should see the {string} repository in the GitHub organization') do |repository_name|
    # mock octokit client to return the repository
  end

  Then('I should see a local clone of the {string} repository') do |string|
    pending # Write code here that turns the phrase above into concrete actions
  end

  Then('I should see the {string} in {string} of the {string} repository') do |string, string2, string3|
    pending # Write code here that turns the phrase above into concrete actions
  end

  Then('I should see the deploy_key in {string} of the {string} repository') do |string, string2|
    pending # Write code here that turns the phrase above into concrete actions
  end

  Given('An assignment with the name {string}') do |string|
    pending # Write code here that turns the phrase above into concrete actions
  end

  When('I try to create an assignment with the name {string}') do |string|
    pending # Write code here that turns the phrase above into concrete actions
  end

  Then('I should see an error message') do
    pending # Write code here that turns the phrase above into concrete actions
  end

  Given('I am logged in as a {string}') do |string|
    pending # Write code here that turns the phrase above into concrete actions
  end

  Then('I should not see the {string} button') do |string|
    pending # Write code here that turns the phrase above into concrete actions
  end

  When('I try to visit the {string} page') do |string|
    pending # Write code here that turns the phrase above into concrete actions
  end
