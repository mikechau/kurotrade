class CreateStockTickers < ActiveRecord::Migration
  def change
    create_table :stock_tickers do |t|
      t.string :symbol
      t.string :name
      t.string :exchange

      t.timestamps
    end
  end
end
