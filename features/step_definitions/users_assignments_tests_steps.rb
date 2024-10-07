require 'rspec/mocks'

World(RSpec::Mocks::ExampleMethods)

Before do
  OmniAuth.config.test_mode = true
  RSpec::Mocks.setup
end

After do
  RSpec::Mocks.teardown
end

Given('I am on the {string} page') do |page_name|
    path = case page_name
    when
        'Login' then root_path
    else
        raise "Unknown page: #{page_name}"
    end
    visit path
end

Then('I should see the {string} page') do |page_name|
    expected_path = case page_name
    when
        "Course Dashboard" then assignments_path
    when
        "Login" then root_path
    end

    expect(current_path).to eq(expected_path)
end

Then('I should see the error message {string}') do |string|
    expect(page).to have_content(string)
end

And('I should have the role {string}') do |string|
    current_user = User.last
    expect(current_user.role).to eq(string)
end

When('I attempt to log in with GitHub with invalid credentials') do
    visit '/auth/failure'
end

When('I log in with GitHub as {string} who has the role of {string}') do |string, string2|
    auth_hash = OmniAuth::AuthHash.new({
        provider: "github",
        uid: "#{string}_uid",
        info: {
            name: string,
            email: "#{string}@example.com",
            nickname: string,
            role: string2
        },
        credentials: {
            token: "fake_access_token"
        }
        })

    OmniAuth.config.mock_auth[:github] = auth_hash
    user = User.find_or_create_by_auth_hash(auth_hash)

    if user.role
        # Mock organization check
        client = instance_double(Octokit::Client)
        allow(Octokit::Client).to receive(:new).and_return(client)
        allow(client).to receive(:organization_member?)
        .with('AutograderFrontend', user.name)
        .and_return(user.role.present?)
    else
        allow_any_instance_of(SessionsController).to receive(:user_belongs_to_organization?).and_return(false)
    end

    visit '/auth/github/callback' # Triggers OmniAuth GitHub login
end
