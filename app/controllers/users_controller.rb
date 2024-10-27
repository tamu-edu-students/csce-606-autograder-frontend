class UsersController < ApplicationController
    include CollaboratorPermissions
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

        all_assignment_ids = Assignment.pluck(:id)

        read_assignment_ids = (params[:read_assignment_ids] || []).map(&:to_i)
        write_assignment_ids = (params[:write_assignment_ids] || []).map(&:to_i)

        # Get assignment ids not in read or write
        none_assignment_ids = all_assignment_ids - (read_assignment_ids + write_assignment_ids)

        update_permissions(read_assignment_ids, "read")
        update_permissions(write_assignment_ids, "read_write")
        update_permissions(none_assignment_ids, "no_permission")

        handle_user_save
    end

      private

      def handle_user_save
        if @user.save
          # Update GitHub permissions
          begin
              update_github_permissions(@user)
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

      def update_permissions(assignment_ids, role)
        assignment_ids.each do |assignment_id|
          permission = Permission.find_or_initialize_by(user: @user, assignment_id: assignment_id)
          permission.update(role: role)
        end
      end

      def update_github_permissions(user)
        access_token = session[:github_token]
        client = Octokit::Client.new(access_token: access_token)
        org_name = "AutograderFrontend"
        @assignments = Assignment.all

        @assignments.each do |assignment|
          repo_identifier = "#{org_name}/#{assignment.repository_name}"
          permission = Permission.find_by(user: user, assignment: assignment)

          update_collaborator_permissions(client, repo_identifier, user, permission)
        end
      end
end
