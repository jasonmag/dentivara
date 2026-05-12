class CreateDocumentTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :document_templates do |t|
      t.string :name, null: false
      t.string :kind, null: false
      t.text :header_text
      t.text :body_template
      t.text :footer_text
      t.string :digital_signature_name
      t.string :digital_signature_title
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :document_templates, [:kind, :active]
  end
end
