class ChangeDataTypeForMarketData < ActiveRecord::Migration
  def up
    change_table :market_data do |t|
      t.change :adj_close, :float
    end
  end

  def down
    change_table :market_data do |t|
      t.change :adj_close, :string
    end
  end
end