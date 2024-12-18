When('I click on {string} link') do |repository_name|
  @assignment = Assignment.find_or_create_by!(repository_name: repository_name)
  stub_request(:get, "https://api.github.com/repos/AutograderFrontend/#{@assignment.repository_name}/contents/tests/c++")
  .with(
    headers: {
    'Accept'=>'application/vnd.github.v3+json',
    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'Content-Type'=>'application/json',
    'User-Agent'=>'Octokit Ruby Gem 9.1.0'
  })
  .to_return(status: 200, body: [], headers: {})
    find('a', text: repository_name).click
  end

Then('I should be redirected to the Assignment page for {string}') do |assignment_name|
    expect(page).to have_content("#{assignment_name}")
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
