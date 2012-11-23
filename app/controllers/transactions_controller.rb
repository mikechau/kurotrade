require 'csv'
require 'date'
class TransactionsController < ApplicationController
  # GET /transactions
  # GET /transactions.json
  def index
    @transactions = Transaction.order(:trade_date)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @transactions }
    end
  end

  # GET /transactions/1
  # GET /transactions/1.json
  def show
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @transaction }
    end
  end

  # GET /transactions/new
  # GET /transactions/new.json
  def new
    @transaction = Transaction.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @transaction }
    end
  end

  # GET /transactions/1/edit
  def edit
    @transaction = Transaction.find(params[:id])
  end

  # POST /transactions
  # POST /transactions.json
  def create
    @transaction = Transaction.new(params[:transaction])

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to @transaction, notice: 'Transaction was successfully created.' }
        format.json { render json: @transaction, status: :created, location: @transaction }
      else
        format.html { render action: "new" }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /transactions/1
  # PUT /transactions/1.json
  def update
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      if @transaction.update_attributes(params[:transaction])
        format.html { redirect_to @transaction, notice: 'Transaction was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.json
  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to transactions_url }
      format.json { head :no_content }
    end
  end


# def convert_to_date(str)
#   # 1/12/2012 - initial
#   # 2012/12/1 - conversion
#   if str != nil
#     date_array = str.split("/")
#     converted_date = Date.parse(("#{date_array[2]}/#{date_array[0]}/#{date_array[1]}").to_s)
#     return converted_date
#   else
#     return 'N/A'
#   end
# end

  #CSV PARSING
  def scottrade_csv_parser #start_1
    if request.post? && params[:file].present? #start_2
      infile = params[:file].tempfile

      Transaction.delete_all

      CSV.foreach(infile, :headers => true, :col_sep => ';') do |row| #start_3

        txn = Transaction.new

        #binding.pry

        if row.to_hash["Symbol"] != nil || row.to_hash["Quantity"] != nil || row.to_hash["Price"] != nil || row.to_hash["ActionNameUS"] || row.to_hash["TradeDate"] != nil || row.to_hash["SettledDate"] != nil || row.to_hash["Interest"] != nil || row.to_hash["Amount"] != nil || row.to_hash["Commission"] != nil || row.to_hash["Fees"] != nil || row.to_hash["CUISP"] != nil || row.to_hash["Description"] != nil || row.to_hash["ActionId"] != nil || row.to_hash["TradeNumber"] != nil || row.to_hash["RecordType"] != nil
            
            txn.update_attributes(
              :stock_symbol => row.to_hash["Symbol"], #Row 1
              :quantity => row.to_hash["Quantity"], #Row 2
              :price => row.to_hash["Price"], #Row 3
              :action_type => row.to_hash["ActionNameUS"], #Row 4
              :trade_date => Transaction.convert_to_date(row.to_hash["TradeDate"]),
              :settle_date => Transaction.convert_to_date(row.to_hash["SettledDate"]), #Row 6
              :interest => row.to_hash["Interest"], #Row 7
              :total_value => row.to_hash["Amount"].gsub(",", ""), #Row 8
              :commission => row.to_hash["Commission"], #Row 9
              :fees => row.to_hash["Fees"], #Row 10
              :cusip => row.to_hash["CUISP"], #Row 11
              :description => row.to_hash["Description"], #Row 12
              :action_id => row.to_hash["ActionId"], #Row 13
              :trade_id => row.to_hash["TradeNumber"], #Row 14
              :record_type => row.to_hash["RecordType"], #Row 15
              :broker => "Scottrade", #Manual / Future Drop Down menu?
              :input_method => "CSV", #2 options CSV or MANUAL
              :group_id => "1", #a test, set by page->cookie?
              :user_id => "1" #a test, set by user.id->cookie?
            )
        end
      end #end_3
      redirect_to transactions_url
    else
      redirect_to new_transaction_url, notice: 'Error: Select a File!'
    end #end_2

    #*** Some sort of validation to make sure Transaction is updated
  end #end_1

end
