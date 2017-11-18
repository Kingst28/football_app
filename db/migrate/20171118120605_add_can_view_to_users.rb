class AddCanViewToUsers < ActiveRecord::Migration
  def change
    add_column :users, :canView, :string
  end
end
