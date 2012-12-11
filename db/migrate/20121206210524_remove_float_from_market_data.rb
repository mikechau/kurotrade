class RemoveFloatFromMarketData < ActiveRecord::Migration
  def up
    remove_column :market_data, :float
  end

  def down
    add_column :market_data, :float, :string
  end
end
