class Message < ApplicationRecord
	belongs_to :user
	belongs_to :conversation
	has_many :user_conversations
	serialize :history, Hash
	serialize :recipients, Array
end
