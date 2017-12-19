class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User
	has_many :messages
	has_many :user_mailboxes
	has_many :user_conversations

	# before_save { self.email = email.downcase }
	# validates :name, presence: true, length: { maximum: 50 }
	# VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	# validates 	:email, 
	# 			presence: true, 
	# 			length: { maximum: 255 }, 
	# 			format: { with: VALID_EMAIL_REGEX },
	# 			uniqueness: { case_sensitive: false }

	# has_secure_password
end
