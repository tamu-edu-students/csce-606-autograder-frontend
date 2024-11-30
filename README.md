# Autograder Frontend for CSCE 120 Autograder Core-Compatible Repos

Links
- [Code Climate](https://codeclimate.com/github/tamu-edu-students/csce-606-autograder-frontend)
- [Heroku Deployment](https://csce-606-autograder-frontend-9219bed98016.herokuapp.com/)
- [GitHub Projects](https://github.com/orgs/tamu-edu-students/projects/67/views/2)
- [Team Working Agreement](https://github.com/tamu-edu-students/csce-606-autograder-frontend/blob/main/team_working_agreement.md)


# Test Documentation

Our application employs a robust testing framework comprising the following tools:

- **RSpec**: For developing unit tests.
- **Cucumber**: For acceptance testing.
- **Capybara**: Facilitates automated front-end testing.
- **Selenium/Chrome**: Used as a JavaScript driver for some tests.
- **WebMock**: Stubs HTTP requests in our test suite.
- **SimpleCov**: Measures both line and branch coverage to ensure > 90% test coverage.

## File Organization
- **RSpec tests** are located under the `/spec/` directory.
- **Cucumber feature and step files** are located under the `/features/` directory.

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

