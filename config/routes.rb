Rails.application.routes.draw do
	mount_devise_token_auth_for 'User', at: 'auth'
  match 'message/new' => 'messages#start_conversation', :via => [:post]
  match 'message/action' => 'messages#perform_action', :via => [:post]
  match 'messages/show' => 'messages#show_conversations', :via => [:get]
end
