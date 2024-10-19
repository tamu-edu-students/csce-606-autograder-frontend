When('I select {string} from the test type dropdown') do |test_type|
    #pending # Write code here that turns the phrase above into concrete actions
    select test_type, from: 'Test type'

  end
  
  
  Then('I should see {string} in the test block') do |string|
    #pending # Write code here that turns the phrase above into concrete actions
    expect(page).to have_content("Test Block")
  end