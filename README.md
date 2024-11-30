# Autograder Frontend for CSCE 120 Autograder Core-Compatible Repositories

A management system for creating and maintaining autograders compatible with [Dr. Philip Ritchey's (Texas A&M University Dept. of CSE) autograder system](https://github.com/philipritchey/autograder-core).

Documentation
- [Setting up a Deployment](#setting-up-a-deployment)
- [Setting up a Development Environment](#setting-up-a-development-environment)
- [Setting up a Testing Environment](#setting-up-a-testing-environment)
- [Contact the Development Team](#contact-the-development-team)

Links
- [Code Climate](https://codeclimate.com/github/tamu-edu-students/csce-606-autograder-frontend)
- [Heroku Deployment](https://csce-606-autograder-frontend-9219bed98016.herokuapp.com/)
- [GitHub Projects](https://github.com/orgs/tamu-edu-students/projects/67/views/2)
- [Team Working Agreement](https://github.com/tamu-edu-students/csce-606-autograder-frontend/blob/main/team_working_agreement.md)

---

# Setting up a Deployment

## Prerequisites:
- [Create a GitHub Organization](#create-a-github-organization)
- [Set up a Heroku App](#set-up-a-heroku-app) 
- [Connect the Application with GitHub OAuth](#connect-the-application-with-gitHub-oauth)

This application will streamline the process of creating auto-graded assignments by providing a GUI to generate new assignment GitHub repositories and interactively create new tests. All the GitHub repositories need to be created under the organization for the course.

## Create a GitHub Organization:  
First, you need to have a GitHub account. Go to your GitHub account and follow these steps:  
1. In the upper-right corner of any page on GitHub, click your profile photo, then click **Settings**.  
2. In the "Access" section of the sidebar, click **Organizations**.  
3. Next to the "Organizations" header, click **New organization**.  
4. Follow the prompts to create your organization.  

In the Organization, you may want to give different roles to the different members (you don’t want to give write permissions to everyone). There are some predefined roles in GitHub:  
- All-repository read  
- All-repository write  
- All-repository triage  
- All-repository maintain  
- All-repository admin  
- CI/CD admin  

Lastly, your organization must contain a fork of the **Autograder Core repository**. This repository contains core autograder functionality that is common to all assignments. When a student submits their work to Gradescope, both the assignment-specific repository, as well as this repository, are cloned into the autograder environment to run tests on the submission.  

### To fork this repository:  
1. Navigate to the GitHub repository: [https://github.com/AutograderFrontend/autograder-core](https://github.com/AutograderFrontend/autograder-core).  
2. Click either the **“Fork”** button at the top of the window or the “fork this repo” link in the README.  
3. Set the **“Owner”** field to the name of your newly-created GitHub Organization.  
4. You may optionally change the repository name, but you must then make sure that your `GITHUB_AUTOGRADER_CORE_REPO` environment variable (discussed below in the Heroku setup documentation) matches the new name.  
5. Click **“Create fork”**.  

### Optional Steps:  

#### Assign an organization role:  
1. In the upper-right corner of GitHub, select your profile photo, then click **Your organizations**.  
2. Next to the organization, click **Settings**.  
3. In the "Access" section of the sidebar, click **Organization roles**, then click **Role assignments**.  
4. Click **New role assignment**.  
5. Search for users or teams that you want to assign a role to, then select the role you want to give to these users and teams.  
6. Click **Add new assignment**.  

> A user or team can have multiple organization roles. However, you can only assign one role at a time.  

#### View an organization’s role assignments:  
1. In the upper-right corner of GitHub, select your profile photo, then click **Your organizations**.  
2. Next to the organization, click **Settings**.  
3. In the "Access" section of the sidebar, click **Organization roles**, then click **Role assignments**.  
4. Optionally, to filter by role assignments for users, click the **Users** tab. To filter by role assignments for teams, click the **Teams** tab.  
5. To view role assignments, to the right of the user or team, click **NUMBER roles**.  

#### Delete an organization role:  
1. In the upper-right corner of GitHub, select your profile photo, then click **Your organizations**.  
2. Next to the organization, click **Settings**.  
3. In the "Access" section of the sidebar, click **Organization roles**, then click **Role assignments**.  
4. Optionally, to filter by role assignments for users, click the **Users** tab. To filter by role assignments for teams, click the **Teams** tab.  
5. To delete a role, to the right of the role, click **NUMBER roles**. Then click **Remove**.  
6. In the pop-up window, click **Remove**.  


## Set up a Heroku App:  

### To create a Heroku application, we first need a Heroku account.  

#### Creating a Heroku account:  
1. Visit [Heroku's Signup Page](https://signup.heroku.com/).  
2. Fill in the required details (name, email, password, etc.).  
3. Verify your email address via the confirmation link sent to your inbox.  
4. Log in to the Heroku dashboard at [https://dashboard.heroku.com/](https://dashboard.heroku.com/).  

#### Install the Heroku CLI:  
- Download the Heroku CLI from the [Heroku CLI Download Page](https://devcenter.heroku.com/articles/heroku-cli).  

OR  

Install it based on your operating system:  
- macOS: Use Homebrew:  
  ```bash
  brew tap heroku/brew && brew install heroku
  ```
- Ubuntu/Debian: Use Snap:  
  ```bash
  sudo snap install --classic heroku
  ```
- Windows: Download and run the installer from the Heroku CLI page.  

#### Verify the installation:  
```bash
heroku --version
```

#### Login to the Heroku CLI:  
Log in to your Heroku account:  
```bash
heroku login
```  
This will open a browser window for you to log in.  

#### Create a Heroku Application:  
In your Rails project directory, create a new Heroku app:  
```bash
heroku create <app-name>
```  
> **NOTE**: If you don’t provide `<app-name>`, Heroku will generate a random name for your app.  

#### Change the Stack:  
The application requires Git to be installed in the Heroku environment for functionality like cloning the repository to local.  

- The Heroku application stack will automatically be set to `heroku-24`, but this stack does not have Git in it.  
- To install Git, change the stack to `heroku-22` where Git is already included using the command:  
  ```bash
  heroku stack:set heroku-22 --app <your-app-name>
  ```  
- To ensure that Git is installed, execute the command:  
  ```bash
  heroku run "git --version"
  ```
## Connecting the database to Heroku App

Once the application is created on Heroku, we need to connect the database to the application.

All apps on Heroku use the PostgreSQL database. For Ruby/Rails apps to do so, they must include the `pg` gem. However, we don't want to use this gem while developing, since we're using SQLite for that.  
Make sure that the `Gemfile` has the following two configurations:

```ruby
group :production do
    gem 'pg' # for Heroku deployment
end

group :development, :test do
    gem 'sqlite3'
end
```

Run `bundle install` to download the dependencies.  
Once the gem is installed, the PostgreSQL database plan needs to be attached as an add-on to the application. The database can be added on through the Heroku CLI or Heroku interface.

### Heroku CLI:

For the current load, Heroku’s `essential-0` plan is sufficient. The Essential-0 plan for Heroku Postgres is a production-grade database plan that offers 1GB of storage and a connection limit of 20.  
Run the following command to add the `essential-0` plan to your Heroku app:

```bash
heroku addons:create heroku-postgresql:essential-0
```

This creates a more robust database suitable for production use with increased storage and performance.

### Heroku Interface:

1. **Log In to the Heroku Dashboard**
   - Go to Heroku Dashboard.
   - Log in with your Heroku credentials.
2. **Select your application that we created earlier**
   - Locate and click on your application in the list of apps on the dashboard.
3. **Navigate to the Resources Tab**
   - Once on your app's page, click the **Resources** tab in the top menu.
   - This tab shows all the add-ons currently attached to your app.
4. **Search for the Add-on**
   - In the Add-ons section, type the name of the add-on you want to attach, such as Heroku Postgres.
   - Select Heroku Postgres from the dropdown list.
5. **Select the Plan**
   - A pop-up will appear asking you to choose a plan. Select `Essential-0` (or your desired plan).
   - Confirm your choice by clicking the Submit or Provision button.
6. **Verify the Add-on**
   - After provisioning, the new add-on will appear in the Add-ons section of the Resources tab.
   - You can click on the add-on’s name to open its management dashboard for further configuration and monitoring.

**NOTE:** The provisioning might take some time, so wait for a few minutes or check the progress on Heroku Dashboard.  

Heroku will automatically set the `DATABASE_URL` environment variable for your app once the add-on is attached.  
To verify that the environment variable is setup, run the command:

```bash
heroku config
```

Look for an entry like this:

```
DATABASE_URL: postgres://username:password@hostname:port/dbname
```

To verify on Heroku interface, navigate to the **Settings** tab and click **Reveal Config Vars**. You should see the key `DATABASE_URL` with the correct URL value. (Check the **Edit Config Vars** section to know more.)  

Once the database is attached to the application, we need to configure it for production. To do this, add the following part in `config/database.yml`:

```yaml
production:
    <<: *default
    database: <%= ENV['DATABASE_URL'] %>
```

## Set Config Variable in Heroku

You can manage config variables via Heroku CLI or through the interface.

#### Using the Heroku CLI:
The `heroku config` commands of the Heroku CLI make it easy to manage your app’s config vars.

- To view current config values:

```bash
heroku config
```

This command shows all current config values. You can also query specific values:

```bash
heroku config:get GITHUB_USERNAME
```

- To set a config variable, use:

```bash
heroku config:set GITHUB_USERNAME=joesmith
```

- To remove a config variable:

```bash
heroku config:unset GITHUB_USERNAME
```

#### Through the Heroku Dashboard Interface:
You can edit config vars from your app’s **Settings** tab in the Heroku Dashboard.

#### Currently, we have the following variables:
- **GITHUB_TEMPLATE_REPO_URL**: `philipritchey/autograded-assignment-template`  
  [This is the template based on which the professor will create the assignment.]
- **GITHUB_COURSE_ORGANIZATION**: `AutograderFrontend`  
  (The way code is setup, keep the same organization name even if you are creating a new one.)
- **ASSIGNMENTS_BASE_PATH**: `/app/assignment-repos/`  
  [This is the base path where the assignments will be cloned.]
- **GITHUB_AUTOGRADER_CORE_REPO**: `autograder-core`

---

## Deploying the Application:

Before deploying the application, there are certain prerequisites:

### A Procfile:
1. If the Procfile is not present, create a file named “Procfile” with no extension.
2. Generate a puma config file if it does not exist using the command:

```bash
bundle exec puma --config config/puma.rb
```

3. Ensure that the Procfile contains the following line that executes the Puma web server:

```plaintext
web: bundle exec puma -C config/puma.rb
```

### Add a Secret Key Base:
Generate and add the secret key base to the application:

```bash
heroku config:set SECRET_KEY_BASE=$(rails secret)
```

### Deployment:

Follow these steps to deploy the application:

1. In your project directory, execute the command `heroku login` to connect to Heroku.
2. Add Heroku as a remote to your Git repository:

```bash
heroku git:remote -a <heroku-app-name>
```

3. Verify that Heroku is added to the remote by executing:

```bash
git remote
```

4. Push your changes to Heroku:

```bash
git push heroku main
```

## Post Deployment:

Once the changes are pushed to `heroku main`, complete the following post-deployment tasks:

1. **Migrations**  
   Run database migrations:

```bash
heroku run rails db:migrate
```

2. **Seed the Database**  
   If needed, seed the database:

```bash
heroku run rails db:seed
```

3. **Restart Dynos**  
   Restart Heroku dynos:

```bash
heroku restart
```

4. **Verify the App**  
   Verify that the app is running correctly:

```bash
heroku open
```

## Connect the Application with GitHub OAuth:

### Get OAuth Credentials:
Create an OAuth app:

1. Go to your GitHub account settings.
2. Navigate to **Developer settings** > **OAuth apps** > **New OAuth App**.
3. Provide the following details:
   - **Application name**: Your app’s name.
   - **Homepage URL**: The full URL to your app (e.g., `https://your-heroku-app.herokuapp.com`).
   - **Authorization callback URL**: `https://your-heroku-app.herokuapp.com/auth/github/callback`.

4. Click **Register application**.  

After registering, you'll receive a `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET`. Add these as environment variables in Heroku.

## Troubleshooting:

If some functionality is not working correctly on the deployed application, check the Heroku logs to find the root cause:

```bash
heroku logs --tail
```

# Setting up a Development Environment

## Step-0: Clone our project repository from [here](https://github.com/tamu-edu-students/csce-606-autograder-frontend).

### Installing the necessary software packages:
The Ruby version used for the development of our application is `3.3.2`. If your Ruby version is different, we recommend matching ours to avoid any conflicts with dependencies. You may follow the steps given [here](https://github.com/tamu-edu-students/hw-ruby-intro) for installing Ruby.

- If `rails` is not present already, to install it, do this:  
  ```bash
  gem install rails
  ```

- If `bundler` is not present already, to install it, do this:  
  ```bash
  gem install bundler
  ```

- If Heroku Command Line (CLI) tool is not present already, to install it, follow the instructions [here](https://devcenter.heroku.com/articles/heroku-cli#install-with-ubuntu-debian-apt-get).

- Check the `ruby`, `rails`, `bundler` and `heroku CLI` versions using the following:  
  ```bash
  ruby -v && rails -v && bundle -v && heroku -v
  ```

- Install `pkg-config` using this command:  
  ```bash
  sudo apt-get update && sudo apt-get install pkg-config
  ```

## Running migrations and creating the database table for development:
The migration files are already present under the `db/migrate` folder. So, no need to create any new migration files.

To apply the migration and create the database table for development, simply run:  
```bash
rails db:migrate
```

## Installation of Gemfiles
Next, let us install the necessary gems:  
All the gems needed are already present in the `Gemfile`. So, no need to add other gems.

To install all the Gem files, simply run:  
```bash
bundle install
```

## Setting up OAuth Application
Now, we need to create and register an OAuth app under your personal account or under any organization you have administrative access to. Here, you should open it under the organization.

**Currently, GitHub only allows for a single callback URL, so a second OAuth Application should be made to work with the development environment.**

1. In the upper-right corner of any page on GitHub, click your profile photo, then click **Settings**.
2. In the left sidebar, click **Developer settings**.
3. In the left sidebar, click **OAuth apps**.
4. Click **New OAuth App**. (If you haven't created an app before, this button will say, "Register a new application.")
5. In **Application name**, type the name of your app.
6. In **Homepage URL**, type the full URL to your local app's website:  
   ```
   http://127.0.0.1:3000/
   ```
7. In **Authorization callback URL**, type the callback URL of your local app.  
   For example:  
   ```
   http://127.0.0.1:3000/auth/github/callback
   ```
   **NOTE**: Ensure that the callback URL is configured in `routes.rb`.
8. If your OAuth app will use the device flow to identify and authorize users, click **Enable Device Flow**. For more information about the device flow, see [Authorizing OAuth apps] (https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/authorizing-oauth-apps#device-flow).

After registering the OAuth, you will get a `GITHUB_CLIENT_ID`, and you will need to generate a `GITHUB_CLIENT_SECRET`.

## How to run the application locally during development:
1. Attach these two lines to `config/local_env.yml`:
   ```yaml
   GITHUB_CLIENT_ID: "<GITHUB_CLIENT_ID_OAUTH>"
   GITHUB_CLIENT_SECRET: "<GITHUB_CLIENT_SECRET_OAUTH>"
   ```

2. Now run `rails server` on your terminal, and visit `http://127.0.0.1:3000/`, to visit the homepage of the local version of the application.

**Caution**:  
Do not push the `local_env.yml` file containing the additions of `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` information to the main repository (this should already be added to your `.gitignore`). These two values were included in the `local_env.yml` file just to allow you to run `rails server` and test the app during development.

## Verification of Routes and Controller Actions (Optional)
You may survey the application routes currently present to get a better idea of which controller action gets called when a certain URI is fetched:

- **Run Rails Routes Command**: Use the following command in your terminal to list all defined routes:  
  ```bash
  rails routes
  ```
## Models and Controllers (Optional)
It is also a good idea for you to get acquainted with the models and controllers present within our application before you start the development. A brief introduction is provided as follows:

### Models
- **ApplicationRecord**:  
  Base class for all models.  
  Provides shared functionality for ActiveRecord models.

- **Assignment**:  
  Represents assignments in the application.

- **Permission**:  
  Represents permissions associated with users or assignments.  
  Used for managing access control.

- **TestGrouping**:  
  Represents groupings of tests within assignments.  
  Used for organizing related tests.

- **Test**:  
  Represents individual tests associated with assignments or groupings.

- **User**:  
  Represents an application user.

### Controllers
- **ApplicationController**:  
  Base controller for all other controllers.  
  Handles shared functionality such as authentication and error handling.

- **AssignmentsController**:  
  Manages operations related to assignments.  
  Includes actions for viewing assignments, updating users assigned to an assignment, searching assignments, managing directory structures.

- **PagesController**:  
  Manages redirection to Assignments page for logged-in users.  
  Includes actions for redirecting to assignments for a logged-in user.

- **SessionsController**:  
  Manages user sessions.  
  Includes actions for logging in via GitHub, handling login failures, and logging out.  
  Verifies organizational membership during login.

- **TestGroupingsController**:  
  Manages groupings of tests.  
  Includes actions for creating and deleting test groupings.

- **TestsController**:  
  Manages individual tests.  
  Includes actions for configuring test metadata.

- **UsersController**:  
  Handles user-related operations.  
  Includes actions for viewing users, managing user assignments.

# Setting up a Testing Environment

Our application employs a robust testing framework comprising the following tools:

- [**RSpec**](https://github.com/rspec/rspec-rails): For developing unit tests.
- [**Cucumber**](https://github.com/rspec/rspec-rails): For acceptance testing.
- [**Capybara**](https://github.com/rspec/rspec-rails): Facilitates automated front-end testing.
- [**Selenium**](https://github.com/rspec/rspec-rails)/[**Chrome**](https://developer.chrome.com/docs/chromedriver/get-started): Used as a JavaScript driver for some tests.
- [**WebMock**](https://developer.chrome.com/docs/chromedriver/get-started): Stubs HTTP requests in our test suite.
- [**SimpleCov**](https://developer.chrome.com/docs/chromedriver/get-started): Measures both line and branch coverage to ensure > 90% test coverage.
- [**RuboCop**](https://github.com/rubocop/rubocop): Static code analysis and code formatting.

## File Organization
- **RSpec tests** are located under the [`/spec`](https://github.com/tamu-edu-students/csce-606-autograder-frontend/tree/main/spec) directory.
- **Cucumber feature and step files** are located under the [`/features`](https://github.com/tamu-edu-students/csce-606-autograder-frontend/tree/main/features) directory.

## Step 1: Install Chromium WebDriver

To allow Capybara to use the Chrome driver, install it using the following command:

```bash
sudo apt install chromium-chromedriver
```

## Step 2: Run the Tests

To execute the test suite, use the following command:

```bash
bundle exec rspec && bundle exec cucumber
```

# Contact the Development Team 

For any inquiries, concerns, or feedback related to the development, testing, deployment, or usage of this application, please reach out to our team. You may also create a [GitHub Issue](https://github.com/tamu-edu-students/csce-606-autograder-frontend/issues/new).

## Team Contact Information  

- **Md Hasan Al Banna**: [mdhasanalbanna@tamu.edu](mailto:mdhasanalbanna@tamu.edu)  
- **Riddhi Ghate**: [riddhighate.07@tamu.edu](mailto:riddhighate.07@tamu.edu)  
- **Ryan Gonzalez**: [gonzalezpear@tamu.edu](mailto:gonzalezpear@tamu.edu)  
- **Qinyao Hou**: [yaoya2618@tamu.edu](mailto:yaoya2618@tamu.edu)  
- **Saksham Mehta**: [saksham19@tamu.edu](mailto:saksham19@tamu.edu)  
- **Mainak Sarkar**: [masarkar@tamu.edu](mailto:masarkar@tamu.edu)  
- **Max Smith**: [maxsmith271346@tamu.edu](mailto:maxsmith271346@tamu.edu)  

