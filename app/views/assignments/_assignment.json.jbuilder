json.extract! assignment, :id, :assignment_name, :repository_name, :repository_url, :created_at, :updated_at
json.url assignment_url(assignment, format: :json)
