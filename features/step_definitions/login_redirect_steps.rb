When('I navigate to the home page') do
    visit root_path
  end
  
  Then('I should be automatically redirected to the course dashboard') do
    expect(page).to have_current_path(assignments_path)
  end
  
  Given('I am not logged in to the system') do
    # Simulate no logged-in session by clearing the session
    page.set_rack_session(user_id: nil)
  end
  
  When('I navigate to the login page') do
    visit root_path
  end
  
  Then('I should not be redirected') do
    expect(page).to have_current_path(root_path)
  end
  
  When('I attempt to access the course dashboard') do
    visit assignments_path
  end
  
  Then('I should be redirected to the login page') do
    expect(page).to have_current_path(root_path)
  end
  