class AddCusipToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :cusip, :string
  end
end
