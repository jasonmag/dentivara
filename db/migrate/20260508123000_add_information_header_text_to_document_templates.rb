class AddInformationHeaderTextToDocumentTemplates < ActiveRecord::Migration[8.0]
  def change
    add_column :document_templates, :information_header_text, :text
  end
end
