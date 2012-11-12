class CreateStockPrices < ActiveRecord::Migration
  def change
    create_table :stock_prices do |t|
      t.string :symbol
      t.date :date
      t.float :close_price

      t.timestamps
    end
  end
end
