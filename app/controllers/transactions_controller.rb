require 'csv'
class TransactionsController < ApplicationController
  # GET /transactions
  # GET /transactions.json
  def index
    @transactions = Transaction.all

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

  def scottrade_csv_parser #end_1
    if request.post? && params[:file].present? #end_2
      infile = params[:file].tempfile

      Transaction.delete_all

      CSV.foreach(infile, :headers => true, :col_sep => ',') do |row| #end_3

        txn = Transaction.new

        txn.update_attributes(
          :stock_symbol => row.to_hash["Symbol"], #Row 1
          :quantity => row.to_hash["Quantity"], #Row 2
          :price => row.to_hash["Price"], #Row 3
          :action_type => row.to_hash["ActionNameUS"], #Row 4
          :trade_date => row.to_hash["TradeDate"], #Row 5
          :settle_date => row.to_hash["SettledDate"], #Row 6
          :interest => row.to_hash["Interest"], #Row 7
          :total_value => row.to_hash["Amount"], #Row 8
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
      end #end_3
      redirect_to transactions_url
    else
      redirect_to new_transaction_url, notice: 'ERROR: Try Again!'
    end #end_2

    #*** Some sort of validation to make sure Transaction is updated
  end #end_1

end
