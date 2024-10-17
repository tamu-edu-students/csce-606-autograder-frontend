  When('I enter {string} into the search bar') do |query|
    fill_in 'query', with: query
  end

  Given('I have searched for {string}') do |query|
    fill_in 'query', with: query
    click_button 'Search Assignment'
  end

  Then('I should see {string} in the list of assignments') do |repository_name|
    expect(page).to have_content(repository_name)
  end

  Then('I should see a message indicating no matching assignments found') do
    expect(page).to have_content('No matching assignments found') # Ensure this message matches your app's output
  end

  When('I clear the search bar') do
    fill_in 'query', with: '' # Clears the search bar by entering an empty string
    click_button 'Search Assignment'
  end

  Then('I should see the full list of assignments') do
    Assignment.all.each do |assignment|
      expect(page).to have_content(assignment.repository_name)
    end
  end

  When('I click the search button without entering any text') do
    fill_in 'query', with: ''
    click_button 'Search Assignment'
  end
