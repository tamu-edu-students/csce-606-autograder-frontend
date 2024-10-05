Given(/^I am logged in as an organization member$/) do
    user = User.create!(name: "#{string}_user", email: "#{string}@example.com", role: string)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  When(/^I click the "Export Assignment" button for "(.*)"$/) do |assignment_name|
    assignment = Assignment.find_by!(name: assignment_name)
    find("button[data-assignment='#{assignment_name}']", text: 'Export Assignment').click
  end

  Then(/^I should see "(.*)\.zip" file in my downloads folder$/) do |assignment_name|
    zip_file_name = "#{assignment_name}.zip"
    expect(page).to have_content(zip_file_name)
  end
