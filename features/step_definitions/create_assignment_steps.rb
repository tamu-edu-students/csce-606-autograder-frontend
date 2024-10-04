Given('I am logged in as an {string}') do |role|
  # Ensure the role is either 'instructor' or 'TA'
  unless ['instructor', 'TA'].include?(role)
    raise ArgumentError, "Role must be either 'instructor' or 'TA'."
  end

  # Find or create a user with the specified role
  user = User.find_or_create_by!(role: role) do |user|
    user.email = "#{role}@example.com"  # Ensure unique email for different roles
    user.password = 'password123'       # Assign a default password
  end

  # Log in the user using your login helper method
  login_as(user)
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
  
  Then('I should see an error message') do
    pending # Write code here that turns the phrase above into concrete actions
  end
  
  
  Then('I should not see the {string} button') do |string|
    pending # Write code here that turns the phrase above into concrete actions
  end
  
  When('I try to visit the {string} page') do |string|
    pending # Write code here that turns the phrase above into concrete actions
  end