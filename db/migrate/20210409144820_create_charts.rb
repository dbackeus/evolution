class CreateCharts < ActiveRecord::Migration[6.1]
  def change
    create_table :charts do |t|
      t.belongs_to :account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :group_by
      t.string :repositories
      t.string :filters

      t.timestamps
    end
  end
end
