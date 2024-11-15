Then("I should see a points editor and test name for each test in their respective test groupings") do
    # Loop through each `.test-info` element in the DOM
    all('.test-info').each do |test_info|
      # Check for the presence of a test name link within `.test-info`
      expect(test_info).to have_css('a.text-link', text: /\d+\) Test_\w+_\d+/) # Regex to match names like "1) Test_BF_1"
      
      # Check for the presence of the points editor form
      expect(test_info).to have_css('form.inline-form')
      expect(test_info).to have_css('input.points-input')
    end
  end
  
  When('I click on the point editor for {string} and enter {string} in the text field') do |test_name, points|
    test = Test.find_by(name: test_name)
  
    # Ensure the test grouping list is present
    expect(page).to have_css('.test-grouping-list', wait: 5)
    puts "Test grouping list exists: #{page.has_css?('.test-grouping-list')}"
  
    within('.test-grouping-list') do
      test_cards = all('.test-card')
      puts "Number of test cards: #{test_cards.size}"
  
      # Ensure there are test cards
      expect(test_cards).not_to be_empty
  
      test_cards.each do |test_card|
        link = test_card.find('.test-info a.text-link')
  
        if link.text.include?("#{test.position}) #{test_name}")
          input = test_card.find('.points-input')
          input.click
          input.set(points)
  
          # Dispatch events for Stimulus controller
          page.execute_script(<<~JS, input.native)
            arguments[0].value = '#{points}';
            arguments[0].dispatchEvent(new Event('input', { bubbles: true }));
            arguments[0].dispatchEvent(new Event('change', { bubbles: true }));
          JS
  
          # Verify input value
          puts "Input value after setting: #{input.value}"
          break
        end
      end
    end
  
    # Verify backend update
    updated_test = Test.find_by(name: test_name)
    puts "Backend points value: #{updated_test.points}"
    expect(updated_test.points.to_s).to eq(points.to_s)
  end
  
  
  # Simulate clicking outside the input field or pressing Enter
  When('I click outside the text field or press Enter') do
    
    find('#totalPoints').click
    # Add a small wait for AJAX
    sleep 0.5
    page.evaluate_script('location.reload()')

  end
  
  # Verify that the points were updated correctly in the database
  Then('the points for {string} should update to {string}') do |test_name, points|
    test = Test.find_by(name: test_name)
    expect(test.points.to_s).to eq(points)
  end
  
  # Verify that the total points at the top of the page are updated correctly
  Then('the total points at the top should update to {string}') do |total_points|
    expect(page).to have_content("Total Points: #{total_points}")
  end