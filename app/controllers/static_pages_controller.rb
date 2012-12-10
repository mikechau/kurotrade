require 'csv'
require 'date'
require 'open-uri'

class StaticPagesController < ApplicationController

	def index
	end

	def balance_exp
		@transactions_initial = Transaction.order(:trade_date)
		@transactions = @transactions_initial.where(:user_id => 1)
	end

  def mock_dashboard

    transactions = Transaction.where(:group_id => 1)
    transactions = transactions.order(:trade_date)

    # transactions_initial = Transaction.order(:trade_date)
    # transactions = transactions_initial.where(:group_id => 1)

    # collect tickers into array
    tickers = []
    tickers_list = transactions.uniq {|t| t[:stock_symbol] && t[:trade_date]}
    tickers_list.each do |ticker|
      if ticker[:stock_symbol] != 'Cash'
      tickers << ticker[:stock_symbol]
      end
    end

    ### Mechanize Populate DB ###################################
    market_data = MarketData.order(:market_date)
    agent = Mechanize.new

    tickers.each do |symbol|
      page = agent.get("http://finance.yahoo.com/q/hp?s=#{symbol}+Historical+Prices")
      dl_csv = page.link_with(:text => 'Download to Spreadsheet').href
      #puts "Begin: #{symbol}"
      # check if the ticker exists in the DB
      CSV.new(open(dl_csv), :headers => :first_row).each_with_index do |row, idx|
        last_market_date = market_data.select {|m| m[:ticker] == symbol}.last
      
        #if market_data.any? {|m| m[:market_date] == row.to_hash['Date'] && m[:ticker] == symbol && m[:close_price] == row.to_hash['Close']} == nil
        if last_market_date[:market_date] < Date.parse(row.to_hash['Date']) || last_market_date[:market_date] == nil
          puts "Adding #{symbol} :: #{row}"
          add_market_data = MarketData.new
          add_market_data.update_attributes(
            :market_date => row.to_hash['Date'],
            :ticker => symbol,
            :close_price => row.to_hash['Close'],
            :adj_close => row.to_hash['Adj Close']
          )
        elsif last_market_date[:market_date] >= Date.parse(row.to_hash['Date'])
          break
        else
          puts "#{idx} :: #{symbol} :: ERROR"
        end
      end

    end
    ###########################################################

    ## Collect Current Market Prices ##########################
    # ticker_string = ''
    # plus = '+'
    # @recent_data = []

    # tickers.each_with_index do |ticker, idx|
    #   ticker_string = ticker_string.concat(ticker.to_s)
    #   if idx < tickers.count-1
    #     ticker_string = ticker_string+plus
    #   end
    # end

    # url = "http://finance.yahoo.com/d/quotes.csv?s=#{ticker_string}&f=sd1t1l1"

    # CSV.new(open(url)).each_with_index do |line,idx|
    #   ticker = line[0]
    #   current = Hash.new
    #   current[:name] = line[0]
    #   current[:info] = {:trade_date => line[1], :trade_time => line[2], :trade_price => line[3]}
    #   @recent_data << current
    # end

  ###########################################################

    ## NAV CALC ###############################################
    # select only group transactions

    market_db = MarketData.all

    ##### EMPTY ARRAYS #####

    open_positions = []
    trades_array = []
    sells_log = []
    cash_changes = []

    transactions.each_with_index do |trade, idx|
      if trade[:action_type] == 'Buy' 

        # shovel transactions hash into trades_array
        trades_array << {:date => trade[:trade_date], :desc => 'BUY', :ticker => trade[:stock_symbol], :price => trade[:price], :qty => trade[:quantity], :commission => trade[:commission], :order => 1}

        # check if buy exists in open_positions array, if not add to array
        if open_positions.any? {|o| o[:ticker] == trade[:stock_symbol] && o[:price] == trade[:price] && o[:qty] > 0 && o[:date] == trade[:trade_date] && o[:mark] != true}
          matching_positions = open_positions.select {|o| o[:ticker] == trade[:stock_symbol] && o[:price] == trade[:price] && o[:mark] != true}
          last_index = (matching_positions.count) - 1
          matching_positions[last_index][:qty] += trade[:qty]
        else
          open_positions << {:date => trade[:trade_date], :ticker => trade[:stock_symbol], :price => trade[:price], :qty => trade[:quantity], :log => 'BUY', :commission => trade[:commission]}
          if open_positions.any? {|o| o[:ticker] == trade[:stock_symbol] && o[:price] == trade[:price] && o[:date] < trade[:trade_date]}
            matching_positions = open_positions.select {|o| o[:ticker] == trade[:stock_symbol] && o[:price] == trade[:price] && o[:date] < trade[:trade_date]}
            last_index = (matching_positions.count) - 1
            add_previous_qty = matching_positions[last_index][:qty]
            last_position = (open_positions.count) - 1
            open_positions[last_position][:qty] += add_previous_qty
          end
        end

      ###
      unique_prices = transactions.select {|o| o[:stock_symbol] == trade[:stock_symbol]}.uniq {|t| t[:price]}
      if unique_prices != nil
        unique_prices.each do |uq|
          check_positions = open_positions.select {|o| o[:ticker] == trade[:stock_symbol] && o[:price] == uq[:price]}
          check_pos_count = (check_positions.count) -1
          check_positions.each_with_index do |pos, idx|
            if idx < check_pos_count
              pos[:mark] = true
            end
          end
        end
      end
      ###
  ############################################################

    ############# SELL CHECK    
    elsif trade[:action_type] == 'Sell'

      if open_positions.any? {|o| o[:ticker] == trade[:stock_symbol] && o[:qty] > 0 && o[:mark] != true}
        ops = open_positions.select {|o| o[:ticker] == trade[:stock_symbol] && o[:qty] > 0 && o[:mark] != true}
        qty_sold = trade[:quantity] *-1
        ops.each do |op|
          if qty_sold > 0 && qty_sold >= op[:qty]
            remainder = qty_sold - op[:qty]
            op_decrease = qty_sold - remainder
            qty_subtracted = op[:qty] - op_decrease
            open_positions << {:date => trade[:trade_date], :ticker => trade[:stock_symbol], :price => op[:price], :qty => qty_subtracted, :sold => op_decrease, :log => 'SELL', :commission => trade[:commission]}
            sells_log << {:date => trade[:trade_date], :desc => 'SELL', :ticker => trade[:stock_symbol], :price => op[:price], :qty => op_decrease, :sell_price => trade[:price], :commission => trade[:commission], :order => 2}
            qty_sold = remainder
          elsif qty_sold > 0 && qty_sold < op[:qty]
            qty_subtracted = op[:qty] - qty_sold
            open_positions << {:date => trade[:trade_date], :ticker => trade[:stock_symbol], :price => op[:price], :qty => qty_subtracted, :sold => qty_sold, :sell_price => trade[:price], :commission => trade[:commission], :order => 2}
            break
          else
            puts "ERROR with qty_sold if: op: #{op} || Trade: #{trade} || Sold: #{qty_sold}"
          end
        end
      end

      ######
      unique_prices = transactions.select {|o| o[:stock_symbol] == trade[:stock_symbol]}.uniq {|t| t[:price]}
      if unique_prices != nil
        unique_prices.each do |uq|
          check_positions = open_positions.select {|o| o[:ticker] == trade[:stock_symbol] && o[:price] == uq[:price]}
          check_pos_count = check_positions.count - 1
          check_positions.each_with_index do |pos, idx|
            if idx < check_pos_count
              pos[:mark] = true
            end
          end
        end
      end
      #####

      ############################################################

      elsif trade[:action_type] == 'Credit Interest' || trade[:action_type] == 'Dividend'
          cash_changes << {:date => trade[:trade_date], :desc => trade[:action_type].upcase, :total => trade[:total_value], :order => 3}
      elsif trade[:action_type] == 'Cash Adjustment' || trade[:action_type] == 'Check'
          cash_changes << {:date => trade[:trade_date], :desc => 'WITHDRAWAL', :total => trade[:total_value], :order => 3}
      elsif trade[:action_type] == 'Journal'
          cash_changes << {:date => trade[:trade_date], :desc => 'DEPOSIT', :total => trade[:total_value], :order => 3}
      else
        puts 'ERROR: ACTION TYPE!'
        puts "error: #{trade[:action_type]}"
      end # if loop
    end # index each loop

    ################################
    ### Establish open position log
    op_log = []
    market_log = []

    op_buy_log = []
    op_buy = open_positions.select {|o| o[:log] == 'BUY'}
    op_buy.each do |op|
      op_buy_log << {:date => op[:date], :desc => 'POS', :ticker => op[:ticker], :price => op[:price], :qty => op[:qty], :commission => op[:commission]}
      op_log << {:date => op[:date], :ticker => op[:ticker], :price => op[:price], :qty => op[:qty], :commission => op[:commission]}
    end

    op_sell_log = []
    op_sell = open_positions.select {|o| o[:log] == 'SELL'}
    op_sell.each do |op|
      op_sell_log << {:date => op[:date], :desc => 'POS', :ticker => op[:ticker], :price => op[:price], :qty => op[:qty], :commission => op[:commission]}
      op_log << {:date => op[:date], :ticker => op[:ticker], :price => op[:price], :qty => op[:qty], :commission => op[:commission]}
    end

    ###############################

    op_log.each_with_index do |op, idx|
      if op[:qty] > 0
        start_date = op[:date]
        if op_log.any? {|o| o[:ticker] == op[:ticker] && o[:price] == op[:price] && o[:date] >= op[:date] && o[:qty] == 0 && o[:mark] != true}
          end_day = op_log.find {|o| o[:ticker] == op[:ticker] && o[:price] == op[:price] && o[:date] >= op[:date] && o[:qty] == 0 && o[:mark] != true}
          find_mrkt = market_db.select {|o| o[:ticker] == op[:ticker] && o[:market_date] >= op[:date] && o[:market_date] < end_day[:date]}
          find_mrkt.each do |mkt|
            #puts "#{idx} :: #{mkt[:date]} | #{mkt[:ticker]} | Mrkt Price: #{mkt[:eod_price]} | Book: #{op[:price]} | Qty: #{op[:qty]}"
            market_log << {:date => mkt[:market_date], :desc => 'MRKT', :ticker => mkt[:ticker], :price => mkt[:close_price], :qty => op[:qty], :book_price => op[:price], :commission => op[:commission], :order => 4}
          end
          end_day[:mark] = true
        else
          find_mrkt = market_db.select {|o| o[:ticker] == op[:ticker] && o[:market_date] >= op[:date]}
          find_mrkt.each do |mkt|
            #puts "#{idx} :: #{mkt[:date]} | #{mkt[:ticker]} | Mrkt Price: #{mkt[:eod_price]} | Book: #{op[:price]} | Qty: #{op[:qty]}"
            market_log << {:date => mkt[:market_date], :desc => 'MRKT', :ticker => mkt[:ticker], :price => mkt[:close_price], :qty => op[:qty], :book_price => op[:price], :commission => op[:commission], :order => 4}
          end
        end
      end
    end
    ################################

    ##################################################
    # add logs if not nil and general clean up
    if sells_log != nil
      trades_array += sells_log
    end

    if cash_changes != nil
      trades_array += cash_changes
    end

    if market_log != nil
      market_log.uniq!
      trades_array += market_log
    end

    trades_array.sort_by! { |t| [t[:date], t[:order]] }

    negative_sells = trades_array.select {|t| t[:desc] == 'SELL'}
    negative_sells.each do |trade|
      trade[:qty] *=-1
    end
    ##################################################

    ##### SET VARIABLES #####
    @nav_units = @nav_units ||= 0
    @cash_balance = 0.0
    @stock_balance = 0.0
    @total_value = @total_value ||= 0
    @nav_per_unit = @nav_per_unit ||= 0
    initial_npu = 0.0
    @net_asset_value = @net_asset_value ||= 0
    @return_nav = 0.0

    trades_count = trades_array.count
    @portfolio = []
    trades_array.each_with_index do |trade, idx|
      if trade[:commission] == nil
        trade[:commision] = 0.0
      end

      trade[:date] = trade[:date].to_time.to_i*1000 #convert to integer for charts

      if trade[:desc] == 'DEPOSIT' && idx == 0
        @nav_units = 1000.0
        @cash_balance += trade[:total]
        @total_value = @cash_balance + @stock_balance
        initial_npu = @total_value / @nav_units
        @nav_per_unit = initial_npu
        @net_asset_value = @nav_per_unit * @nav_units

        @portfolio << {:date => trade[:date], :nav => @net_asset_value, :nav_units => @nav_units, :nav_per_unit => @nav_per_unit, :cash => @cash_balance, :stock => @stock_balance, :total => @total_value, :return => 0.0}
      elsif trade[:desc] == 'BUY'
        book_value = (trade[:qty] * trade[:price] * -1) + trade[:commission]
        @cash_balance += book_value
        @stock_balance += (book_value * -1)
        @total_value = @cash_balance + @stock_balance
        @nav_per_unit = @total_value / @nav_units
        @net_asset_value = @nav_per_unit * @nav_units
        @return_nav = ((@nav_per_unit - initial_npu) / initial_npu) * 100

        @portfolio << {:date => trade[:date], :nav => @net_asset_value, :nav_units => @nav_units, :nav_per_unit => @nav_per_unit, :cash => @cash_balance, :stock => @stock_balance, :total => @total_value, :return => @return_nav}
      elsif trade[:desc] == 'SELL'
        sell_value = (trade[:qty] * trade[:sell_price] * -1) + trade[:commission]
        @cash_balance += sell_value
        @stock_balance += (trade[:price] * trade[:qty])
        @total_value = @cash_balance + @stock_balance
        @nav_per_unit = @total_value / @nav_units
        @net_asset_value = @nav_per_unit * @nav_units
        @return_nav = ((@nav_per_unit - initial_npu) / initial_npu) * 100
        @portfolio << {:date => trade[:date], :nav => @net_asset_value, :nav_units => @nav_units, :nav_per_unit => @nav_per_unit, :cash => @cash_balance, :stock => @stock_balance, :total => @total_value, :return => @return_nav}
      elsif trade[:desc] == 'MRKT'
        book_value = (trade[:book_price] * trade[:qty] * -1) + trade[:commission]
        mrkt_value = trade[:qty] * trade[:price]
        mrkt_difference = (mrkt_value - book_value.abs)
        market_stock_balance = @stock_balance + mrkt_difference
        @total_value = @cash_balance + market_stock_balance
        @nav_per_unit = @total_value / @nav_units
        @net_asset_value = @nav_per_unit * @nav_units
        @return_nav = ((@nav_per_unit - initial_npu) / initial_npu) * 100
        @portfolio << {:date => trade[:date], :nav => @net_asset_value, :nav_units => @nav_units, :nav_per_unit => @nav_per_unit, :cash => @cash_balance, :stock => @stock_balance, :total => @total_value, :return => @return_nav}
      elsif trade[:desc] == 'CREDIT INTEREST' || trade[:desc] == 'DIVIDEND'
        @cash_balance += trade[:total]
        @total_value = @cash_balance + @stock_balance
        @nav_per_unit = @total_value / @nav_units
        @net_asset_value = @nav_per_unit * @nav_units
        @return_nav = ((@nav_per_unit - initial_npu) / initial_npu) * 100
        @portfolio << {:date => trade[:date], :nav => @net_asset_value, :nav_units => @nav_units, :nav_per_unit => @nav_per_unit, :cash => @cash_balance, :stock => @stock_balance, :total => @total_value, :return => @return_nav}
      elsif trade[:desc] == 'WITHDRAWAL'
        @cash_balance += trade[:total]
        @total_value = @cash_balance + @stock_balance
        @nav_units = @nav_units - ( (-trade[:total]) / ( (@cash_balance + @stock_balance - trade[:total]) / @nav_units ) )
        @nav_per_unit = @total_value / @nav_units
        @net_asset_value = @nav_per_unit * @nav_units
        @return_nav = ((@nav_per_unit - initial_npu) / initial_npu) * 100
        @portfolio << {:date => trade[:date], :nav => @net_asset_value, :nav_units => @nav_units, :nav_per_unit => @nav_per_unit, :cash => @cash_balance, :stock => @stock_balance, :total => @total_value, :return => @return_nav}
      elsif trade[:desc] == 'DEPOSIT' && idx > 0
        @cash_balance += trade[:total]
        @total_value = @cash_balance + @stock_balance
        @nav_units = @nav_units + ( (trade[:total]) / ( (@cash_balance + @stock_balance - trade[:total]) / @nav_units ) ) 
        @nav_per_unit = @total_value / @nav_units
        @net_asset_value = @nav_per_unit * @nav_units
        @return_nav = ((@nav_per_unit - initial_npu) / initial_npu) * 100
        @portfolio << {:date => trade[:date], :nav => @net_asset_value, :nav_units => @nav_units, :nav_per_unit => @nav_per_unit, :cash => @cash_balance, :stock => @stock_balance, :total => @total_value, :return => @return_nav}
      else
        puts "NAV CALC ERROR: #{idx} :: #{trade}"
      end
    end

    @portfolio = @portfolio.reverse.uniq {|x| x[:date]}.reverse #clean up data points
    @display_op = open_positions.select {|o| o[:mark] != true && o[:qty] > 0}.sort {|x, y| x[:date] <=> y[:date]}

    @display_op.each_with_index do |op, idx|

      url = "http://finance.yahoo.com/d/quotes.csv?s=#{op[:ticker]}&f=sd1t1l1"
      CSV.new(open(url)).each do |line|
        current = []
        current << {:trade_date => line[1], :trade_time => line[2], :trade_price => line[3].to_f}
        @display_op[idx][:market] = current
      end

      book_value = op[:price] * op[:qty] + (op[:commission]*-1)
      op[:book_value] = book_value.to_f
    end


  end # def end

  def about
  end

  def contact
  end

  def testing
  end

######################
end #class end