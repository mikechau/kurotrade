class AddAdjCloseToMarketDataAsFloat < ActiveRecord::Migration
  def change
    add_column :market_data, :adj_close, :float
  end
end
