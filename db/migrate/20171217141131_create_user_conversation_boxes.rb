class CreateUserConversationBoxes < ActiveRecord::Migration[5.1]
  def change
    create_table :user_conversation_boxes do |t|
      t.string :prefix
      t.boolean :is_read, default: false
      t.references :conversation, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false
      t.timestamps
    end
  end
end
