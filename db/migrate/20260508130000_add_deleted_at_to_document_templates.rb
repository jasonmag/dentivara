class AddDeletedAtToDocumentTemplates < ActiveRecord::Migration[8.0]
  def change
    add_column :document_templates, :deleted_at, :datetime
    add_index :document_templates, :deleted_at
    add_index :document_templates, [:kind, :active, :deleted_at], name: "idx_doc_templates_kind_active_deleted_at"
  end
end
