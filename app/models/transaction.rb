class Transaction < ActiveRecord::Base
  attr_accessible :broker, :commission, :description, :fees, :group_id, :interest, :price, :quantity, :settle_date, :stock_symbol, :total_value, :trade_date, :trade_id, :action_type, :cusip, :action_id, :record_type, :input_method, :user_id

  belongs_to :group

  def self.convert_to_date(str)
  # 1/12/2012 - initial
  # 2012/12/1 - conversion
  	if str != nil
    	date_array = str.split("/")
    	converted_date = Date.parse(("#{date_array[2]}/#{date_array[0]}/#{date_array[1]}").to_s)
    	return converted_date
  	else
    	return 'N/A'
  	end
	end

	# def scottrade_csv_parser(file)

 #  	CSV.foreach(file, :headers => true, :col_sep => ',') do |row|

 #  		Transaction.delete_all

 #    		txn = Transaction.new

 #    		txn.update_attributes(
	# 	    	:stock_symbol => row.to_hash["Symbol"], #Row 1
	# 	    	:quantity => row.to_hash["Quantity"], #Row 2
	# 	    	:price => row.to_hash["Price"], #Row 3
	# 	    	:action_type => row.to_hash["ActionNameUS"], #Row 4
	# 	    	:trade_date => row.to_hash["TradeDate"], #Row 5
	# 	    	:settle_date => row.to_hash["SettledDate"], #Row 6
	# 		    :interest => row.to_hash["Interest"], #Row 7
	# 		    :total_value => row.to_hash["Amount"], #Row 8
	# 		    :commission => row.to_hash["Commission"], #Row 9
	# 		    :fees => row.to_hash["Fees"], #Row 10
	# 		   	:cusip => row.to_hash["CUISP"], #Row 11
	# 		    :description => row.to_hash["Description"], #Row 12
	# 		    :action_id => row.to_hash["ActionId"], #Row 13
	# 		    :trade_id => row.to_hash["TradeNumber"], #Row 14
	# 		    :record_type => row.to_hash["RecordType"], #Row 15
	# 		   	:broker => "Scottrade", #Manual / Future Drop Down menu?
	# 		   	:input_method => "CSV", #2 options CSV or MANUAL
	# 		   	:group_id => "1", #a test, set by page->cookie?
	# 		   	:user_id => "1" #a test, set by user.id->cookie?
	# 		  )
	# 	end
 #  end

end


# => Transaction(id: integer, group_id: integer, trade_id: string, stock_symbol: string, trade_date: date, settle_date: date, quantity: integer, price: float, commission: float, fees: float, interest: float, total_value: float, description: string, broker: string, created_at: datetime, updated_at: datetime, action_type: string, action_id: integer, record_type: string) 

	    # :tax_fk => row.to_hash["TaxLotNumber"],
	    # :position_fk => row.to_hash["CUSIP"],
	    # :txn_type => row.to_hash["ActionNameUS"],
	    # :stock_symbol => row.to_hash["Symbol"],
	    # :company => "n/a",
	    # :trade_date => row.to_hash["TradeDate"],
	    # :settle_date => row.to_hash["SettledD te"],
	    # :quantity => row.to_hash["Quantity"],
	    # :unit_value => row.to_hash["Price"],
	    # :commission => row.to_hash["Commission"],
	    # :fees => row.to_hash["Fees"],
	    # :interest => row.to_hash["Interest"],
	    # :total_value => row.to_hash["Amount"],
	    # :description => row.to_hash["Description"],
	    # :broker => row.to_hash["ScotTrade"]