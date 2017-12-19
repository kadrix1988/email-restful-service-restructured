class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.text :body
      t.timestamp :published_at
      t.references :user, foreign_key: true, null: false
      t.references :conversation, foreign_key: true, null: false
      t.blob :history
      t.text :recipients
      t.string :origin
      t.timestamps
    end
  end
end
