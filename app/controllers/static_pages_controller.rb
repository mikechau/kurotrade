require 'csv'
require 'date'
require 'open-uri'
require 'tempfile'

class StaticPagesController < ApplicationController

	def index
	end

	def balance_exp
		@transactions_initial = Transaction.order(:trade_date)
		@transactions = @transactions_initial.where(:user_id => 1)
	end

  def mock_dashboard
    # select only group transactions
    transactions_initial = Transaction.order(:trade_date)
    @transactions = transactions_initial.where(:group_id => 1)

    # collect tickers into array
    tickers = []

    @transactions.group(:stock_symbol).each do |t|
      if t.stock_symbol != 'Cash'
      tickers << t.stock_symbol
      end
    end

    #### Mechanize Populate DB ###################################
    # market_data = MarketData.all
    # agent = Mechanize.new

    # tickers.each do |symbol|
    #   page = agent.get("http://finance.yahoo.com/q/hp?s=#{symbol}+Historical+Prices")
    #   dl_csv = page.link_with(:text => 'Download to Spreadsheet').href
    #   csv_data = open(dl_csv)

    #   csv_count = csv_data.count -1 #remove the header
    #   md_count = market_data.select {|m| m[:ticker] == symbol}.count

    #   # check if the ticker exists in the DB
    #   if market_data.any? {|m| m[:ticker] == symbol} == nil || csv_count > md_count
    #     CSV.new(csv_data, :headers => :first_row).each do |row|
    #       if market_data.find {|m| m[:market_date] == row.to_hash['Date'] && m[:ticker] == symbol && m[:close_price] == row.to_hash['Close']} == nil
    #         puts row
    #         add_market_data = MarketData.new
    #         add_market_data.update_attributes(
    #           :market_date => row.to_hash['Date'],
    #           :ticker => symbol,
    #           :close_price => row.to_hash['Close'],
    #           :adj_close => row.to_hash['Adj Close']
    #         )
    #       end
    #     end
    #   elsif csv_count == md_count
    #     #do nothing
    #   else
    #     #do nothing
    #   end
    # end
    ############################################################

    ### Collect Current Market Prices ##########################
    ticker_string = ''
    plus = '+'
    @recent_data = []

    tickers.each_with_index do |ticker, idx|
      ticker_string = ticker_string.concat(ticker.to_s)
      if idx < tickers.count-1
        ticker_string = ticker_string+plus
      end
    end

    url = "http://finance.yahoo.com/d/quotes.csv?s=#{ticker_string}&f=sd1t1l1"

    CSV.new(open(url)).each_with_index do |line,idx|
      ticker = line[0]
      current = Hash.new
      current[:name] = line[0]
      current[:info] = {:trade_date => line[1], :trade_time => line[2], :trade_price => line[3]}
      @recent_data << current
    end

    ############################################################



  end

end