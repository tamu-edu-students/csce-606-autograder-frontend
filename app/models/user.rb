class User < ActiveRecord::Base
    has_many :permissions, dependent: :destroy
    has_many :assignments, through: :permissions

    def self.find_or_create_by_auth_hash(auth_hash)
        user = where(provider: auth_hash.provider, uid: auth_hash.uid).first_or_initialize
        user.name = auth_hash.info.name
        user.email = auth_hash.info.email
        user.role = auth_hash.info.role
        user.save!
        user
    end
end
