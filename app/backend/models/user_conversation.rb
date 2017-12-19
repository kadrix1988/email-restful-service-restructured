class UserConversation < ApplicationRecord
	belongs_to :user
	belongs_to :message
	belongs_to :conversation
end
