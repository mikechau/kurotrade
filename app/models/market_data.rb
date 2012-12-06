class MarketData < ActiveRecord::Base
  attr_accessible :adj_close, :close_price, :float, :market_date, :ticker
end
