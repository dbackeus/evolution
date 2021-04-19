class CreateFilters < ActiveRecord::Migration[6.1]
  def change
    create_table :filters do |t|
      t.belongs_to :account, null: false, foreign_key: true
      t.string :name, null: false
      t.text :sql, null: false

      t.timestamps
    end
  end
end
