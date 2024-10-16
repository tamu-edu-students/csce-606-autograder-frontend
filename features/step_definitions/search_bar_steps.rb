  Given('We have the following assignments exist:') do |table|
    table.hashes.each do |assignment|
      Assignment.create!(
        assignment_name: assignment['assignment_name'],
        repository_name: assignment['repository_name']
      )
    end
  end
  
  Given('I am on the assignments page') do
    visit assignments_path
  end
  
  When('I enter {string} into the search bar') do |query|
    fill_in 'query', with: query
  end
  
  When('I click the search button') do
    click_button 'Search Assignment'
  end
  
  Given('I have searched for {string}') do |query|
    fill_in 'query', with: query
    click_button 'Search Assignment'
  end
  
  Then('I should see {string} in the list of assignments') do |repository_name|
    expect(page).to have_content(repository_name)
  end
  
  
  