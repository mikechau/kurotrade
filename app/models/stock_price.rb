class StockPrice < ActiveRecord::Base
  attr_accessible :close_price, :date, :symbol
end
