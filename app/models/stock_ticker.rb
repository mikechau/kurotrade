class StockTicker < ActiveRecord::Base
  attr_accessible :exchange, :name, :symbol
end
