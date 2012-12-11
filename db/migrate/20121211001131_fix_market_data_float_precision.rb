class FixMarketDataFloatPrecision < ActiveRecord::Migration
  def change
    remove_column :market_data, :adj_close
  end

end
