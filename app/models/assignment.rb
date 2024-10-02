class Assignment < ActiveRecord::Base
    validates :repository_name, uniqueness: true
    validates :assignment_name, :repository_name, presence: true
end