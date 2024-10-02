Given(/^I am logged in as an organization member$/) do
    user = User.find_or_create_by!(role: 'organization_member')
    login_as(user)
  end
  
  When(/^I click the "Export Assignment" button for "(.*)"$/) do |assignment_name|
    assignment = Assignment.find_by!(name: assignment_name)
    find("button[data-assignment='#{assignment_name}']", text: 'Export Assignment').click
  end
  
  Then(/^I should see "(.*)\.zip" file in my downloads folder$/) do |assignment_name|
    zip_file_name = "#{assignment_name}.zip"
    expect(page).to have_content(zip_file_name) 
  end
  