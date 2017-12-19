class CreateUserConversations < ActiveRecord::Migration[5.1]
  def change
    create_table :user_conversations do |t|
      t.references :user, foreign_key: true, null: false
      t.references :conversation, foreign_key: true, null: false
      t.references :message, foreign_key: true, null: false
      t.boolean :is_deleted, default: false
      t.timestamps
    end
  end
end
