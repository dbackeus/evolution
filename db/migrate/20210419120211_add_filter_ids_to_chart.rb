class AddFilterIdsToChart < ActiveRecord::Migration[6.1]
  def change
    add_column :charts, :filter_ids, :bigint, array: true, null: false, default: []
  end
end
