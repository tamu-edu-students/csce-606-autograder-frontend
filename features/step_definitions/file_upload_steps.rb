require 'rspec/mocks'

Before do
  RSpec::Mocks.setup
  allow_any_instance_of(AssignmentsHelper).to receive(:render_file_tree).and_return(
    "<ul class='file-tree'>
       <li class='folder'>
         <span class='folder-name' onclick='toggleFolder(this)'>target</span>
         <a class='upload-icon' onclick='openFileUpload(this, \"target/text_file.txt\")' title='Upload File'>⬆️</a>
       </li>
     </ul>".html_safe +
     "<input type='file' id='fileUploadInput' style='display: none;' data-upload-path='target/text_file.txt' onchange='uploadFile(this)'>".html_safe
  )
end

After do
  RSpec::Mocks.teardown
end

When("I select the Upload File button next to {string} folder in file tree") do |folder_name|
  upload_icon = find("li.folder", text: folder_name).find(".upload-icon")
  
  # Click the upload icon to open the file upload dialog
  upload_icon.click
end

When("I upload a new file {string} under the {string} folder") do |file_name, folder_name|
    # Simulate the file input element and create a fake file object
    file_path = Rails.root.join("spec/fixtures/#{file_name}")

    # Construct the params hash
    params = {
      file: Rack::Test::UploadedFile.new(file_path, 'text/plain'), # Adjust MIME type if needed
      path: folder_name,
      id: @assignment.id
    }
    
    @stub = stub_request(:put, "https://api.github.com/repos/AutograderFrontend/assignment1/contents/tests/#{folder_name}/#{file_name}").
    with(
      body: "{\"content\":\"VGVzdCBjb250ZW50IGZvciBmaWxlIHVwbG9hZC4=\",\"message\":\"Upload test_file.txt\"}",
      headers: {
      'Accept'=>'application/vnd.github.v3+json',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Octokit Ruby Gem 9.1.0'
      }).
    to_return(status: 200, body: "", headers: {})

    # Simulate the POST request to the upload_file action
    page.driver.post "/assignments/#{@assignment.id}/upload_file", params

    #Checking the success response
    @upload_response = JSON.parse(page.driver.response.body)

    if @upload_response['success']
      #Including the success message for later checks
      allow_any_instance_of(AssignmentsHelper).to receive(:render_file_tree).and_return(
        " <h4>File uploaded successfully!</h4>
          <ul class='file-tree'>
           <li class='folder'>
             <span class='folder-name' onclick='toggleFolder(this)'>target</span>
             <a class='upload-icon' onclick='openFileUpload(this, \"target/text_file.txt\")' title='Upload File'>⬆️</a>
           </li>
         </ul>".html_safe +
         "<input type='file' id='fileUploadInput' style='display: none;' data-upload-path='target/text_file.txt' onchange='uploadFile(this)'>".html_safe
      )
      visit assignment_path(@assignment)
    end
end

Then("I should see the {string} file under the {string} folder in file directory") do |file_name, folder_name|
  #Within the test setting, it is impossible to upload file to a remote repository as real HTTP interactions are disabled.
  #So a good point to check whether the remote repository is updated, is to verify that the relevant GitHub API receives
  #a call with the correct arguments.
  
  expect(@stub).to have_been_requested
end