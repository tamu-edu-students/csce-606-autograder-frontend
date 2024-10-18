  When("I try to access a protected page") do
    visit assignments_path  # Now try to access the protected page
  end

  Then("I should see a {string} button in the navigation bar") do |button_text|
    within('nav.navbar') do
      expect(page).to have_link(button_text)  # Ensure the "Logout" button is visible
    end
  end

  Then("I should not see a {string} button in the navigation bar") do |button_text|
    within('nav.navbar') do
      expect(page).to have_no_link(button_text, wait: 10)  # Wait for the logout button to disappear
    end
  end
