Given(/^I am logged in as an organization member$/) do
    user = User.create!(name: "#{string}_user", email: "#{string}@example.com", role: string)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  When(/^I click the "Create and Download ZIP" button for "(.*)"$/) do |assignment_name|
    @assignment = Assignment.find_by!(assignment_name: assignment_name)
    # mock
    FileUtils.touch(File.join(@assignment.local_repository_path, "#{@assignment.assignment_name}.zip"))
    click_on 'Create and Download ZIP'
  end

  Then(/^I should see "(.*)\.zip" file in my downloads folder$/) do |assignment_name|
    visit assignment_path(@assignment)

    # The new zip file name based on the assignment name
    zip_filename = "#{@assignment.assignment_name}.zip"

    expect(page).to have_content("#{zip_filename} downloaded successfully")
  end
