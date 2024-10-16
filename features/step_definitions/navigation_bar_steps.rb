  When("I am on any page of the app") do
    visit assignments_path  # Visit a random page like assignments
  end

  Then("I should see a navigation bar at the top of the view") do
    expect(page).to have_css('nav.navbar')  # Ensure a navigation bar exists
  end

  Then("the navigation bar should have the following links:") do |table|
    table.hashes.each do |row|
      expect(page).to have_link(row['Link Text'], href: row['Link Target'])  # Verify the presence of each link
    end
  end

  When("I click the {string} link in the navigation bar") do |link_text|
    within('nav.navbar') do
      expect(page).to have_link(link_text, wait: 10)
      click_link(link_text)
    end
  end

  Then("I should be redirected to the {string} page at {string}") do |page_name, path|
    expect(current_path).to eq(path)  # Check that the current path is correct
  end

  Then("I should be logged out of the system") do
    expect(page).to have_content('Logged out successfully')  # Ensure the logout link is no longer visible after logging out
  end

  Then("I should be redirected to the {string} page") do |page_name|
    path = case page_name
    when "login"
             root_path
    when "course dashboard"
             assignments_path
    when "manage users"
             users_path
    else
             root_path  # Default to root if page_name is not recognized
    end
    expect(page).to have_current_path(path, wait: 10)  # Wait for the correct page redirection
  end

  Then("I should still see the navigation bar at the top of the page") do
    expect(page).to have_css('nav.navbar')  # Ensure the navigation bar persists across pages
  end

  When("I click the app name in the navigation bar") do
    within('nav.navbar') do
      click_link("Autograder Frontend")
    end
  end
