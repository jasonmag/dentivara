class AddSurfaceMarksToDentalChartEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :dental_chart_entries, :surface_marks, :json, default: [], null: false
  end
end
