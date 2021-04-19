class AddStartDateToCharts < ActiveRecord::Migration[6.1]
  def change
    add_column :charts, :start_date, :date
  end
end
