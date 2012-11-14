class Transaction < ActiveRecord::Base
  attr_accessible :broker, :commission, :description, :fees, :group_id, :interest, :price, :quantity, :settle_date, :stock_symbol, :total_value, :trade_date, :trade_id

  belongs_to :group
end
