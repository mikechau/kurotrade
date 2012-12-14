class CreateBetaUsers < ActiveRecord::Migration
  def change
    create_table :beta_users do |t|
      t.string :name
      t.string :email
      t.string :category

      t.timestamps
    end
  end
end
