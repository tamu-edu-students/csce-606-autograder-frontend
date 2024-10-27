# app/controllers/concerns/collaborator_permissions.rb
module CollaboratorPermissions
    extend ActiveSupport::Concern

    def update_collaborator_permissions(client, repo_identifier, user, permission)
      case permission.role
      when "no_permission", nil
        remove_collaborator(client, repo_identifier, user)
      when "read_write", "read"
        add_collaborator(client, repo_identifier, user, permission.role)
      else
        Rails.logger.error "Unknown permission role: #{permission.role} for user #{user.name}"
      end
    end

    def remove_collaborator(client, repo_identifier, user)
      client.remove_collaborator(repo_identifier, user.name)
      Rails.logger.info "Removed collaborator #{user.name} from #{repo_identifier} due to 'none' permission"
    rescue Octokit::Error => e
      Rails.logger.error "Failed to remove collaborator #{user.name} from #{repo_identifier}: #{e.message}"
      raise
    end

    def add_collaborator(client, repo_identifier, user, role)
      github_permission = (role == "read_write") ? "push" : "pull"
      client.add_collaborator(repo_identifier, user.name, permission: github_permission)
      Rails.logger.info "Updated collaborator #{user.name} on #{repo_identifier} with #{github_permission} access"
    rescue Octokit::Error => e
      Rails.logger.error "Failed to update collaborator #{user.name} on #{repo_identifier}: #{e.message}"
      raise
    end
end
