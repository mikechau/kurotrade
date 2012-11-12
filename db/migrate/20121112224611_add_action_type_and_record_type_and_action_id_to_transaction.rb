class AddActionTypeAndRecordTypeAndActionIdToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :action_type, :string
    add_column :transactions, :action_id, :integer
    add_column :transactions, :record_type, :string
  end
end
