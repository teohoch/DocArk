class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :registerable,
         :rememberable,
         :trackable,
         #:validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]
  has_many :folders_created, :class_name => 'Folder', :foreign_key => 'created_by_id'
  has_many :folders_updated, :class_name => 'Folder', :foreign_key => 'updated_by_id'

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first
    user ||= User.create(name: data['name'],
                         email: data['email'],
                         first_name: data['first_name'],
                         last_name: data['last_name'],
                         image: data.image,
                         provider: access_token.provider,
                         uid: access_token.uid)
    user
  end
end
