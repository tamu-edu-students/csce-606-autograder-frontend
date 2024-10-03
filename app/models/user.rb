class User < ActiveRecord::Base
  has_and_belongs_to_many :assignments
  def self.find_or_create_by_auth_hash(auth_hash)
      user = where(provider: auth_hash.provider, uid: auth_hash.uid).first_or_initialize
      user.name = auth_hash.info.name
      user.email = auth_hash.info.email
      user.save!
      user
    end
end
