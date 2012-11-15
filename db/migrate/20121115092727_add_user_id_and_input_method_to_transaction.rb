class AddUserIdAndInputMethodToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :user_id, :integer
    add_column :transactions, :input_method, :string
  end
end
