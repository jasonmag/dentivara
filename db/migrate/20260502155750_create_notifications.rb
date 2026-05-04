class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :patient, null: false, foreign_key: true
      t.string :channel
      t.string :category
      t.datetime :scheduled_for
      t.datetime :sent_at
      t.string :status
      t.text :message

      t.timestamps
    end
  end
end
