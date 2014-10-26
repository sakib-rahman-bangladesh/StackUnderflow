class User < ActiveRecord::Base

  has_many :questions
  has_many :answers
  has_many :comments
  has_many :votes
  has_many :attachments
  has_many :identities

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
      :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:facebook, :twitter, :vkontakte, :github]

  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { in: 3..32 }, format: { with: /\A[\w\d_]+\z/, message: "allows only latin letters, numbers, and underscore." }

  mount_uploader :avatar, AvatarUploader

  def to_param
    username
  end

  def self.find_for_oauth(auth)
    identity = Identity.find_by(provider: auth.provider, uid: auth.uid)
    return identity.user if identity

    username = "#{auth.provider}_#{auth.uid}"
    email = (auth.respond_to?(:info) && !auth.info[:email].nil? && !auth.info[:email].empty?) ? auth.info[:email] : "#{username}@stackunderflow.dev"

    user = User.find_by(email: email)
    
    unless user
      password = Devise.friendly_token
      user = User.create(email: email, username: username, password: password)
    end
    user.identities.create(provider: auth.provider, uid: auth.uid)
    user
  end
end
