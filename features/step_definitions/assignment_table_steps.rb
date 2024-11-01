When('I click on {string} link') do |assignment_name|
    find('a', text: assignment_name).click
  end

Then('I should be redirected to the {string} page for {string}') do |page_name, assignment_name|
    expect(page).to have_content("#{page_name}: #{assignment_name}")
end

Then('I should see {string} button in each assignment row') do |button_text|
    within('#assignments-table tbody') do
        expect(page).to have_css('tr a', text: button_text, count: all('tr').size)
    end
end





Then('I should see {string} column left justified') do |column_name|
    column = find('#assignments-table th', text: column_name)
    expect(column[:class]).to include('text-left')
end

Then('I should see {string} column highlighted') do |column_name|
    header = find('th', text: column_name)
    expect(header[:class]).to include('highlight-column') # Check directly on the element with a short wait
end




Then('I should not see {string} button in each assignment row') do |button_text|
    within('#assignments-table tbody') do
      all('tr').each do |row|
        expect(row).not_to have_link(button_text)
      end
    end
  end
