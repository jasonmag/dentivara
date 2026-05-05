class CreateIntakeFormSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :intake_form_submissions do |t|
      t.references :patient, foreign_key: true
      t.references :submitted_by_user, foreign_key: { to_table: :users }
      t.string :source, null: false, default: "online"
      t.string :status, null: false, default: "submitted"
      t.json :payload, null: false, default: {}
      t.datetime :reviewed_at

      t.timestamps
    end

    add_index :intake_form_submissions, :status
    add_index :intake_form_submissions, :source
  end
end
