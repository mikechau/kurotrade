class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :group_id
      t.string :trade_id
      t.string :stock_symbol
      t.date :trade_date
      t.date :settle_date
      t.integer :quantity
      t.float :price
      t.float :commission
      t.float :fees
      t.float :interest
      t.float :total_value
      t.string :description
      t.string :broker

      t.timestamps
    end
  end
end
