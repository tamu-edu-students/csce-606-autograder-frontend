# Step to create multiple assignments from a table
Given('the following assignments exist:') do |table|
  table.hashes.each do |row|
    Assignment.create!(assignment_name: row['assignment_name'], repository_name: row['repository_name'], repository_url: row['repository_url'])
  end
end

# Step to create users and update their access to assignments
Given('the following users exist:') do |table|
  table.hashes.each do |row|
    user = User.create!(username: row['username'], role: row['role'])
    
    # Assuming each user has access fields like assignment1_access, assignment2_access, etc.
    row.each do |key, value|
      if key.start_with?('assignment') && key.end_with?('_access')
        assignment = Assignment.find_by(assignment_name: key.gsub('_access', ''))
        user.assignment_accesses.create!(assignment: assignment, access: value) if assignment
      end
    end
  end
end

# Step to log in as a specific user
Given('I am logged in as {string}') do |username|
  user = User.find_by(username: username)
  if user
    session[:user_id] = user.id # Check once - this is Manual session setup, can replace with any other authentication helper if needed
  else
    raise "User #{username} not found"
  end
end

# Step to visit a specific page
Given('I am on the {string} page') do |page_name|
  visit path_to(page_name) # Ensure `path_to` helper is defined and returns the correct paths
end

# Step to click a specific user link
When('I click on {string}') do |username|
  user = User.find_by(username: username)
  if user
    click_link(user.username) # Assuming usernames are clickable links
  else
    raise "User #{username} not found"
  end
end

# Step to select a specific assignment by repository name
When('I select the assignment {string}') do |assignment_repo_name|
  find('option', text: assignment_repo_name).select_option
end

# Step to select multiple assignments by repository names
When('I select the assignments {string}') do |assignment_repo_names|
  assignment_repo_names.split(' and ').each do |assignment_repo_name|
    find('option', text: assignment_repo_name).select_option
  end
end

# Step to click a button by its text
When('I click the {string} button') do |button_text|
  click_button(button_text)
end

# Step to click any button by its text (alternative version)
When('I click {string}') do |button_text|
  click_button(button_text)
end

# Step to de-select an assignment by repository name
When('I de-select the assignment {string}') do |assignment_repo_name|
  find('option', text: assignment_repo_name).unselect_option
end

# Step to de-select multiple assignments by repository names
When('I de-select the assignments {string}') do |assignment_repo_names|
  assignment_repo_names.split(' and ').each do |assignment_repo_name|
    find('option', text: assignment_repo_name).unselect_option
  end
end

# Step to check that a user has specific access to a repository
Then('I should see that {string} has {string} access to the remote {string} repository') do |username, access_type, repository_name|
  user = User.find_by(username: username)
  assignment = Assignment.find_by(repository_name: repository_name)

  if user && assignment
    # Review this  - can we use some implementation for `access_for` that checks the user's access to an assignment
    expect(user.access_for(assignment)).to eq(access_type)
  else
    raise "User #{username} or Assignment #{repository_name} not found"
  end
end
