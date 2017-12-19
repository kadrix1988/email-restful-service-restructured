class MessagesController < ApplicationController

  before_action :authenticate_user!
  before_action :retrieve_logged_in_user
  before_action :allowed_action_params, :prepare_for_message_actions, only: [:perform_action]
  before_action :allowed_show_params, :prepare_for_message_views, only: [:show_conversations]
  before_action :allowed_create_params, only: [:start_conversation]
  before_action :allowed_delete_params, :prepare_for_conversation_deletion, only: [:delete_conversation]

  before_action :allowed_save_draft_params, :prepare_for_save_as_draft, only: [:save_as_draft]
  before_action :allowed_publish_draft_params, :prepare_for_publish_draft, only: [:publish_draft_to_users]
  before_action :allowed_discard_draft_params, :prepare_for_discard_draft, only: [:discard_draft]

  def show_conversations
    # filter and show conversations
    render :json => prepare_view_message_data(params[:view]).to_json
  end

  def save_as_draft
    if @conversation.nil?
      @conversation = Conversation.create(:subject => params[:subject])
      UserConversationBox.create(:user_id => @user.id, :conversation_id => @conversation, :prefix => '')
    end
    if @message.nil?
      create_message(@conversation, params[:body], params[:recipients], params[:history], params[:action], false)
      UserConversationBox.create(:user_id => @user.id, :conversation_id => @conversation, :prefix => @prefix)
    else
      @message.conversation.update_attributes(:subject => params[:subject])
      @message.update_attributes(:body => params[:body],:recipients => params[:recipients])
    end
    respond_with(true, "Saved as draft")
  end

  def publish_draft_to_users
    @message.conversation.update_attributes(:subject => params[:subject])
    @message.update_attribute(
      :body => params[:body], 
      :recipients => params[:recipients], 
      :published_at => Time.now)
    publish_to_users(@message, @message.conversation, @new_users, @old_users, @prefix)
    respond_with(true, "Sent message to - #{@message.recipients}")
  end

  def discard_draft
    # just delete message object
    # conversation can be deleted or left to be deleted using a cron
    @message.destroy
    respond_with(true, "Discarded message")
  end

  # pending prepare
  def start_conversation
    # create a conversation object
    # create a message object
    # create user_conversations for all recipients
    # create user_conversation_boxes for all recipients
    new_conversation = Conversation.create(:subject => params[:subject])
    new_message = create_message(@message.conversation, params[:body], params[:recipients], {})
    publish_to_users(new_message, new_conversation, @to_users, [], '')
    respond_with(true, "Started a conversation with - #{new_message.recipients}")
  end

  def perform_action
    # identify new recipient email-ids
    # create a message object
    # create user_conversations for all
    # create user_conversation_boxes for new recipients with subject_prefix - `Fwd:` OR `Re:`

    new_message = create_message(@message.conversation, params[:body], @to_users.map(&:email), @history, params[:action])
    publish_to_users(new_message, @message.conversation, @new_to_users, @old_to_users, @new_to_users_subject_prefix)
    respond_with(true, "Performed action - #{params[:action]} conversation - #{@ucb.prefix} #{@message.conversation.subject}")
  end

  def delete_conversation
    # update user_conversation_boxes by settign is_deleted to true for logged_in user
    UserConversation.where(
        "conversation_id = ? AND user_id = ?", @conversation.id, @user.id
      ).update_all(:is_deleted => true)
    respond_with(true, "Moved conversation - #{@ucb.prefix} #{@conversation.subject} to Trash")
  end

private

  def publish_to_users(message, conversation, new_users, old_users, prefix)
    UserConversation.create(
      (new_users+old_users).map{|u| 
        {
          "user": u, 
          "message": message, 
          "conversation": conversation
        }
      })
    UserConversationBox.create(
      new_users.map{|u| 
        {
          "user": u, 
          "conversation": conversation,
          "prefix": prefix
        }
      })
    UserConversationBox.where(
        "conversation_id = ? AND user_id IN (?)", conversation.id, old_users.map(&:id)
      ).update_all(:is_read => false)
  end

  def create_message(conversation, body, recipients, history, origin, publish = false)
    Message.create(
      :body => body, 
      :user => @user,
      :origin => origin,
      :recipients => recipients,
      :published_at => publish ? Time.now : nil,
      :conversation => conversation,
      :history => history)
  end

  def allowed_show_params
    params.permit[:view]
  end

  def allowed_create_params
    params.permit(:subject, :body, :recipients)
  end

  def allowed_delete_params
    params.permit(:conversation_id)
  end

  def allowed_action_params
    params.permit(:message_id, :body, :recipients, :action)
  end

  def allowed_save_draft_params
    params.permit(:message_id, :conversation_id, :subject, :body, :recipients, :history, :action)
  end
  
  def allowed_publish_draft_params
    params.permit(:message_id, :subject, :body, :recipients, :action)
  end

  def respond_with(success, message)
    render :json => {"success": success, "message": message} and return
  end

  def prepare_for_message_actions
    unless (params[:recipients].is_a?(Array) && params[:recipients].any?)
      respond_with(false, "No recipients added")
    end

    respond_with(false, "Unknown action #{params[:action]}") if ['forward', 'reply'].include?(params[:action])
    @new_to_users_subject_prefix = params[:action].eql?('forward') ? 'Fwd:' : 'Re:'
    @message = Message.find_by_id(params[:message_id].to_i)
    respond_with(false, "Unknown message. Cannot perform action - #{params[:action]}") if @message.nil?
    respond_with(false, "Not a message recipient to respond") if @message.recipients.include?(@user.email)

    email_addresses = params[:recipients]
    @to_users = User.where("email IN (?)", email_addresses)

    unknown_email_addresses = email_addresses - @to_users.map(&:email)
    respond_with(false, "Unknown email addresses #{unknown_email_addresses.join(', ')}") if unknown_email_addresses.any?

    @new_to_users = @to_users.select{|u|!@message.recipients.include?(u.email)}
    @old_to_users = @to_users.select{|u| @message.recipients.include?(u.email)}

    @ucb = UserConversationBox.find_by_user_id_and_conversation_id(@user.id, @message.conversation.id)

    @history = {:user => @message.user_id,
      :body => @message.body, 
      :published_at => @message.published_at,
      :history => @message.history}
  end

  def prepare_for_message_views
    where_clause = ''
    puts "??? #{params[:view]}"
    case params[:view]
    when 'inbox'
      where_clause = "messages.user_id = #{@user.id} AND user_conversations.is_deleted=0"
    when 'sent'
      where_clause = "messages.user_id = #{@user.id} AND "
      where_clause += "messages.published_at IS NOT NULL AND "
      where_clause += "user_conversations.is_deleted=0"
    when 'trash'
      where_clause = "messages.user_id = #{@user.id} AND "
      where_clause += "messages.published_at IS NULL AND "
      where_clause += "user_conversations.is_deleted=0"
    when 'draft'
      where_clause = "messages.user_id = #{@user.id} AND user_conversations.is_deleted=1"
    else
      respond_with(false, "Unknown view request")
    end
    @conversations = UserConversation.includes(:conversation)
                        .joins(:message)
                        .where(where_clause)
                        .map(&:conversation).uniq
  end

  def prepare_view_message_data(view)
    subject_prefixes = {}
    UserConversationBox
      .where(
        "conversation_id = (?) AND user_id = ?", 
        @conversations.map(&:id), 
        @user.id
      ).map{|ucb| 
        subject_prefixes[ucb.conversation_id] = ucb.prefix
      }
    arr_conversations = []
    @conversations.map{|c|
      h = Hash.new
      h[:subject] = "#{subject_prefixes[c.id]}#{c.subject}"
      h[:messages] = c.messages.select{|m|
          m.user_id == @user.id
        }.as_json(:only => [:id, :body, :recipients, :published_at])
      arr_conversations.push(h)
    }
    data = Hash.new
    data[view.to_sym] = arr_conversations
  end

  def retrieve_logged_in_user
    @user = User.find_by_id(session['warden.user.user.key'].first)
  end

  def prepare_for_conversation_deletion
    @conversation = Conversation.find_by_id(params[:conversation_id].to_i)
    respond_with(false, "Unknown conversation. Cannot perform action - Move to Trash") if @conversation.nil?
    @ucb = UserConversationBox.find_by_user_id_and_conversation_id(@user.id, @conversation.id)
    respond_with(false, "Unknown conversation box. This is an unexpected state. Skipping action - Move to Trash") if @ucb.nil?
  end

  def prepare_for_save_as_draft
    respond_with(false, "Unknown action #{params[:action]}") if ['', 'forward', 'reply'].include?(params[:action])
    @conversation = Conversation.find_by_id(params[:conversation_id].to_i)
    @prefix = params[:action].eql?('forward') ? 'Fwd:' : 'Re:'
    @message = Message.find_by_id(params[:message_id].to_i)
  end

  def prepare_for_publish_draft
    unless (params[:recipients].is_a?(Array) && params[:recipients].any?)
      respond_with(false, "No recipients added")
    end
    respond_with(false, "Unknown action #{params[:action]}") if ['forward', 'reply'].include?(params[:action])
    @message = Message.find_by_id(params[:message_id].to_i)
    respond_with(false, "Unknown message. Cannot perform action - #{params[:action]}") if @message.nil?
    respond_with(false, "Not the owner of the message") if @message.user.id.eql?(@user.id)

    @prefix = ''
    if @message.origin.eql?('forward')
      @prefix = 'Fwd:'
    elsif @message.origin.eql?('reply')
      @prefix = 'Re:'
    end

    email_addresses = params[:recipients]
    @to_users = User.where("email IN (?)", email_addresses)

    unknown_email_addresses = email_addresses - @to_users.map(&:email)
    respond_with(false, "Unknown email addresses #{unknown_email_addresses.join(', ')}") if unknown_email_addresses.any?

    @new_to_users = @to_users.select{|u|!@message.recipients.include?(u.email)}
    @old_to_users = @to_users.select{|u| @message.recipients.include?(u.email)}
  end

  def allowed_discard_draft_params
    params.permit(:message_id)
  end

  def prepare_discard_draft
    @message = Message.find_by_id(params[:message_id].to_i)
    respond_with(false, "Unknown message. Cannot perform action - Discard") if @message.nil?
    respond_with(false, "Not the owner of the message") if @message.user.id.eql?(@user.id)
  end
end
