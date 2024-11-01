And(/^"([^"]*)" test exists in "([^"]*)" in order$/) do |_, _, table|
    table.hashes.each_with_index do |row, index|
      test_name = row['Test Name']
      grouping_name = row['Grouping Name']

      test_grouping = TestGrouping.find_or_create_by!(name: grouping_name, assignment: @assignment)

      test = test_grouping.tests.find_or_initialize_by(name: test_name)
      test.assignment = @assignment
      test.points = 5
      test.test_block = { code: "sample code" }
      test.test_type = "unit"
      test.target = "sample_target"
      test.position = index + 1
      test.save!

      test_grouping.reload
      expect(test.position).to eq(index + 1)
      expect(test_grouping.tests.order(:position).pluck(:name)).to include(test_name)
    end
  end

Then("I should not be able to update grouping name in the test group") do
    within(".test-grouping-list") do
        expect(page).not_to have_selector(".edit-button")
    end
end

Then("I should see a point editor next to each test") do
    within(".test-list") do
        all(".test-card").each do |test_card|
        expect(test_card).to have_selector(".edit-button")
        end
    end
end

And("I should see a point total field at top") do
    expect(page).to have_selector("div[data-points-target='totalPoints']", text: /Total Points:/)
end
