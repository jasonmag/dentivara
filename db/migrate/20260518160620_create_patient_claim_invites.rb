class CreatePatientClaimInvites < ActiveRecord::Migration[8.0]
  def change
    create_table :patient_claim_invites do |t|
      t.references :patient, null: false, foreign_key: true
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :claimed_at

      t.timestamps
    end

    add_index :patient_claim_invites, :token_digest, unique: true
    add_index :patient_claim_invites, :expires_at
  end
end
