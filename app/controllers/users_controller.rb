class UsersController < ApplicationController
    before_action :require_login
    def index
        @users = User.all
    end

    def show
        @user = User.find(params[:id])
        @assignments = Assignment.all
    end

    def update_assignments
        @user = User.find(params[:id])
        @assignments = Assignment.all
        new_assignment_ids = (params[:assignment_ids] || []).map(&:to_i)
        old_assignment_ids = @user.assignment_ids


        assignments_to_remove = old_assignment_ids - new_assignment_ids
        @user.assignments.delete(Assignment.where(id: assignments_to_remove))

        # Add new assignments
        @user.assignment_ids = new_assignment_ids

        if @user.save
            # Update GitHub permissions
            begin
                update_github_permissions(@user, new_assignment_ids, old_assignment_ids)
                flash[:notice] = "Assignments updated successfully."
                redirect_to users_path
            rescue Octokit::Error => e
                Rails.logger.error "Failed to update GitHub permissions: #{e.message}"
                flash[:alert] = "Failed to update assignments. Please try again."
                @assignments = Assignment.all
                render :show
            end
        else
            @assignments ||= []
            flash.now[:alert] = "Failed to update assignments. Please try again."
            render :show
        end
    end

      private

      def update_github_permissions(user, new_assignment_ids, old_assignment_ids)
        access_token = session[:github_token]
        client = Octokit::Client.new(access_token: access_token)
        org_name = "AutograderFrontend"

        # All assignments that need to be updated
        all_assignments = Assignment.where(id: new_assignment_ids | old_assignment_ids)


        all_assignments.each do |assignment|
          repo_identifier = "#{org_name}/#{assignment.repository_name}"
          permission = new_assignment_ids.include?(assignment.id) ? "push" : "pull"

          begin
            client.add_collaborator(repo_identifier, user.name, permission: permission)
            Rails.logger.info "Updated collaborator #{user.name} on #{repo_identifier} with #{permission} access"
          rescue Octokit::Error => e
            Rails.logger.error "Failed to update collaborator #{user.name} on #{repo_identifier}: #{e.message}"
            raise
          end
        end
      end
end
