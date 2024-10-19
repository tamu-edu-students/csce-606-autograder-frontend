Given("I am on the {string} page for user permissions") do |page_name|
    visit assignments_path if page_name == "Manage Assignments"
end

