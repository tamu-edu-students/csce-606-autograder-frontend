namespace :tests do
    desc "Run Cucumber and RSpec tests"
    task :run do
        sh "bundle exec cucumber"
        sh "bundle exec rspec"
    end
end
