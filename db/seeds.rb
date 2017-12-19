# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


User.create(:name => 'user1', :email => 'user1@nk.com', :password => 'abcDEF1@', :password_confirmation => 'abcDEF1@')
User.create(:name => 'user2', :email => 'user2@nk.com', :password => 'abcDEF1@', :password_confirmation => 'abcDEF1@')
User.create(:name => 'user3', :email => 'user3@nk.com', :password => 'abcDEF1@', :password_confirmation => 'abcDEF1@')
User.create(:name => 'user4', :email => 'user4@nk.com', :password => 'abcDEF1@', :password_confirmation => 'abcDEF1@')
User.create(:name => 'user5', :email => 'user5@nk.com', :password => 'abcDEF1@', :password_confirmation => 'abcDEF1@')
User.create(:name => 'user6', :email => 'user6@nk.com', :password => 'abcDEF1@', :password_confirmation => 'abcDEF1@')
User.create(:name => 'user7', :email => 'user7@nk.com', :password => 'abcDEF1@', :password_confirmation => 'abcDEF1@')
User.create(:name => 'user8', :email => 'user8@nk.com', :password => 'abcDEF1@', :password_confirmation => 'abcDEF1@')
User.create(:name => 'user9', :email => 'user9@nk.com', :password => 'abcDEF1@', :password_confirmation => 'abcDEF1@')
User.create(:name => 'user10', :email => 'user10@nk.com', :password => 'abcDEF1@', :password_confirmation => 'abcDEF1@')

Conversation.create(:subject => 'Conversation 1')
Conversation.create(:subject => 'Conversation 2')
Conversation.create(:subject => 'Conversation 3')
Conversation.create(:subject => 'Conversation 4')
Conversation.create(:subject => 'Conversation 5')


Message.create(:body => 'hello sample text', :recipients => ['user1@nk.com', 'user2@nk.com', 'user3@nk.com'], :user_id => 2, :history => {:user => 'sharukh khan <sharukh123@gmail.com> wrote', :body => 'Says hi to India', :published_at => Time.now, :history => {}}, :conversation_id => 1)
Message.create(:body => 'hello sample text', :recipients => ['user1@nk.com', 'user4@nk.com', 'user3@nk.com'], :user_id => 3, :history => {:user => 'sharukh khan <sharukh123@gmail.com> wrote', :body => 'Says hi to India', :published_at => Time.now, :history => {}}, :conversation_id => 2)
    
UserConversation.create(:user_id => 2, :conversation_id => 1, :message_id => 2)
