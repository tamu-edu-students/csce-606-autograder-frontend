# Autograder Frontend for CSCE 120 Autograder Core-Compatible Repos

Links
- [Code Climate](https://codeclimate.com/github/tamu-edu-students/csce-606-autograder-frontend)
- [Heroku Deployment](https://csce-606-autograder-frontend-9219bed98016.herokuapp.com/)
- [GitHub Projects](https://github.com/orgs/tamu-edu-students/projects/67/views/2)
- [Team Working Agreement](https://github.com/tamu-edu-students/csce-606-autograder-frontend/blob/main/team_working_agreement.md)

---

# Setting up a Deployment

## Prerequisites:
- Heroku Account  
- GitHub Organization  
- GitHub OAuth Credentials  

This application will streamline the process of creating auto-graded assignments by providing a GUI to generate new assignment GitHub repositories and interactively create new tests. All the GitHub repositories need to be created under the organization for the course.

## Creating the Organization:  
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


## Setting up Heroku App:  

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

---

# Test Documentation

Our application employs a robust testing framework comprising the following tools:

- **RSpec**: For developing unit tests.
- **Cucumber**: For acceptance testing.
- **Capybara**: Facilitates automated front-end testing.
- **Selenium/Chrome**: Used as a JavaScript driver for some tests.
- **WebMock**: Stubs HTTP requests in our test suite.
- **SimpleCov**: Measures both line and branch coverage to ensure > 90% test coverage.

## File Organization
- **RSpec tests** are located under the `/spec` directory.
- **Cucumber feature and step files** are located under the `/features` directory.

---

## Step 1: Install Chromium WebDriver

To allow Capybara to use the Chrome driver, install it using the following command:

```bash
sudo apt install chromium-chromedriver
```

---

## Step 2: Run the Tests

To execute the test suite, use the following command:

```bash
bundle exec rspec && bundle exec cucumber
```

