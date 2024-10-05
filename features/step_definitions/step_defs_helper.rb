# step_defs_helper.rb
module StepDefsHelper
  def path_to(page_name)
    case page_name
    when 'Manage Users' then manage_users_path
    when 'Assignments' then assignments_path
    else
      raise "No path defined for page '#{page_name}'"
    end
  end
end
