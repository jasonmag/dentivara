class AddDentalChartingAndProfileFieldsToPatients < ActiveRecord::Migration[8.0]
  def change
    add_column :patients, :dental_chart, :text
    add_column :patients, :chief_complaint, :text
    add_column :patients, :known_allergies, :text
    add_column :patients, :current_medications, :text
    add_column :patients, :medical_conditions, :text
    add_column :patients, :last_dental_visit_on, :date

    add_column :patients, :address_line1, :string
    add_column :patients, :address_line2, :string
    add_column :patients, :city, :string
    add_column :patients, :state, :string
    add_column :patients, :postal_code, :string
    add_column :patients, :preferred_contact_method, :string

    add_column :patients, :insurance_provider, :string
    add_column :patients, :insurance_policy_number, :string
  end
end
