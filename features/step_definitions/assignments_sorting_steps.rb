Given("the following assignments with creation time exist:") do |table|
    table.hashes.each do |hash|
      @assignment = Assignment.create!(assignment_name: hash['assignment_name'], repository_name: hash['repository_name'], created_at: hash['created_at'], updated_at: hash['updated_at'])
    end
end

Then('I should see a table displaying assignments with columns for "Assignment Name", "Created On", "Last Updated", and "Actions"') do
    within('table') do
        expect(page).to have_css('th', text: 'Assignment Name')
        expect(page).to have_css('th', text: 'Created On')
        expect(page).to have_css('th', text: 'Last Updated')
        expect(page).to have_css('th', text: 'Actions')
        expect(page).to have_css('tbody tr')
        within('tbody') do
          all('tr').each do |row|
            expect(row).to have_css('td', count: 4)
          end
        end
      end
    end

When('I click on the {string} column header') do |header|
    within('#assignments-table thead') do
        find('th', text: header).click
    end
end

Then('the assignments should be sorted by {string} in {word} order') do |column, order|
    column_index = {
      'repo name' => 0,
      'creation date' => 1,
      'last updated date' => 2
    }[column.downcase]

    rows = all('#assignments-table tbody tr')
    values = rows.map { |row| row.all('td')[column_index].text }

    if column.downcase.include?('date')
      # Convert string dates to DateTime objects for comparison
      parsed_values = values.map { |v| DateTime.strptime(v, '%d-%m-%Y %H:%M') }
      sorted_values = parsed_values.sort
      # Convert back to original string format for comparison
      expected_values = order == 'ascending' ? sorted_values.reverse : sorted_values
      expected_values = expected_values.map { |v| v.strftime('%d-%m-%Y %H:%M') }
    else
      # For non-date columns, sort as strings
      sorted_values = values.sort
      expected_values = order == 'ascending' ? sorted_values.reverse : sorted_values
    end

    expect(values).to eq(expected_values)
  end

Then('I should see a {word} arrow') do |direction|
    arrow_id = case direction
    when 'downward'
                    '&#x25BC;'
    when 'upward'
                    '&#x25B2;'
    else
                    raise "Unknown direction: #{direction}"
    end

    within('#assignments-table thead') do
        expect(page).to have_css("span[id^='arrow-']", text: arrow_id, visible: :all)
    end
end
