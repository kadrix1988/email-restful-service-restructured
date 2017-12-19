class Conversation < ApplicationRecord
	has_many :messages
	has_many :user_conversations
	has_many :user_conversation_origins
end
