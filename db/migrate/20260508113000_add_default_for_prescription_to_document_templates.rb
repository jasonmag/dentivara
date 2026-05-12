class AddDefaultForPrescriptionToDocumentTemplates < ActiveRecord::Migration[8.0]
  def change
    add_column :document_templates, :default_for_prescription, :boolean, default: false, null: false
    add_index :document_templates, [:kind, :default_for_prescription], name: "idx_doc_templates_kind_default"
  end
end
