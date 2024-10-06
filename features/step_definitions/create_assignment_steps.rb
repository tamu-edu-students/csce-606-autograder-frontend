  Given('I am logged in as an {string}') do |string|
    #pending # Write code here that turns the phrase above into concrete actions
  end

  When('I click the {string} button') do |string|
    #pending # Write code here that turns the phrase above into concrete actions
    click_on string
  end


  When('I fill in the repository name with {string}') do |string|
    pending # Write code here that turns the phrase above into concrete actions
  end


  When('I fill in the description with {string}') do |string|
    pending # Write code here that turns the phrase above into concrete actions
  end


  Then('I should see the new assignment in the course assignments list') do
    pending # Write code here that turns the phrase above into concrete actions
  end

  Then('I should see the {string} repository in the CSCE {int} GitHub organization') do |string, int|
    # Then('I should see the {string} repository in the CSCE {float} GitHub organization') do |string, float|
    pending # Write code here that turns the phrase above into concrete actions
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



  Given('I am logged in as a {string}') do |string|
    pending # Write code here that turns the phrase above into concrete actions
  end

  Then('I should not see the {string} button') do |string|
    pending # Write code here that turns the phrase above into concrete actions
  end


When('I try to visit the {string} page') do |string|
  path = case string
  when 'Course Dashboard' then assignments_path
  when 'Create Assignment' then new_assignment_path
  when 'Login' then root_path
  else
    raise "Unknown page: #{string}"
  end
  visit path
end
