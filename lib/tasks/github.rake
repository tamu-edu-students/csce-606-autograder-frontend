require "octokit"
require "optparse"

namespace :github do
  desc "Delete all assignment repositories in the GitHub organization"
  task :clean, [ :access_token, :exempt_repos ] do |t, args|
    options = {}
    opts = OptionParser.new do |opts|
      opts.banner = "Usage: rake github:clean -- [options]"
      opts.on("-a", "--access-token ACCESS_TOKEN", "GitHub personal access token") { |access_token|
        options[:access_token] = access_token
      }
      opts.on("-e", "--exempt-repos EXEMPT_REPOS", "List of comma-separated repositories to exempt") { |exempt_repos|
        options[:exempt_repos] = exempt_repos.split(",")
      }
    end

    args = opts.order!(ARGV) { }
    opts.parse!(args.to_a)

    if options[:access_token].nil?
        puts "Error: Access token is required. Use -a or --access-token to provide it."
        exit 1
    end
    # print in red
    puts "\e[31mWARNING: This task will delete all assignment repositories in the organization.\e[0m"
    puts "\e[31mAre you sure you want to delete all assignment repositories in the organization?\e[0m (y/n): "
    confirmation = STDIN.gets.chomp
    if confirmation != "y"
        puts "Aborted."
        exit
    end

    access_token = options[:access_token]
    exempt_repos = options[:exempt_repos] || []
    exempt_repos += [ "autograder-core" ]

    client = Octokit::Client.new(access_token: access_token)
    repos = client.organization_repositories("AutograderFrontend").reject { |repo| exempt_repos.include?(repo.name) }

    repos.each do |repo|
      client.delete_repository(repo.full_name)
      puts "Deleted repository: #{repo.full_name}"
    end

    puts "All repositories have been deleted."
    exit
  end
end
