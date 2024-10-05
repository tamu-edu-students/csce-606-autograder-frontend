# features/step_definitions/user_management_steps.rb

# Step to log in with a specific role using your current session management
Given('I am am logged in with the {string} role') do |role|
    user = User.find_by(role: role)
    if user
      session[:user_id] = user.id
    else
      raise "User with role #{role} not found"
    end
  end

  # Step to log in as a TA
  Given('I am am logged in as a TA') do
    user = User.find_by(role: 'ta')
    if user
      session[:user_id] = user.id
    else
      raise "TA not found"
    end
  end

  # Step to log in as a user by their username
  Given('I am am logged in as {string}') do |username|
    user = User.find_by(username: username)
    if user
      session[:user_id] = user.id
    else
      raise "User #{username} not found"
    end
  end

  # Step to visit the 'Manage Users' page (this would map to a specific route, depending on your views)
  When('I try to visit the {string} page') do |page_name|
    if page_name == "Manage Users"
      visit '/manage_users' # Not configured in routes yet
    else
      raise "Page #{page_name} not found"
    end
  end

  # Step to check for the presence of the page content
  Then('I should see the {string} page') do |page_name|
    expect(page).to have_content(page_name)
  end

  # Step to check for an error message
  Then('I should see an error message') do
    expect(page).to have_content('You are not authorized to access this page')
  end

  # Step to set up predefined users from the table
  Given('the following users exist:') do |table|
    table.hashes.each do |row|
      User.create!(username: row['username'], role: row['role'], access: row['access'])
    end
  end

  # Step to navigate to the 'Manage Users' page
  Given('I am on the {string}') do |page_name|
    if page_name == "Manage Users"
      visit '/manage_users' # Not configured in routes yet
    else
      raise "Page #{page_name} not found"
    end
  end

  # Step to click on a specific user by username
  When('I click on the {string} user') do |username|
    user = User.find_by(username: username)
    if user
      click_link(user.username)
    else
      raise "User #{username} not found"
    end
  end

  # Step to verify the user's permissions via checkboxes
  Then('I should see a list of checkboxes indicating the assignments that {string} has write access to') do |username|
    user = User.find_by(username: username)
    assignments = Assignment.all # Check this once
    assignments.each do |assignment|
      if user.has_write_access?(assignment) # Review this once - Can use permissions thing in controller for has_write_access? method for users
        expect(page).to have_checked_field(assignment.assignment_name)
      else
        expect(page).to have_unchecked_field(assignment.assignment_name)
      end
    end
  end

  # Step to check for the presence of buttons
  Then('I should see a {string} button') do |button_text|
    expect(page).to have_button(button_text)
  end
