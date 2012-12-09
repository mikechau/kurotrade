class CreateMarketData < ActiveRecord::Migration
  def change
    create_table :market_data do |t|
      t.date :market_date
      t.string :ticker
      t.float :close_price
      t.float :adj_close

      t.timestamps
    end
  end
end
