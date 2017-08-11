class AddBudgetToUsers < ActiveRecord::Migration
  def change
    add_column :users, :budget, :integer , :default => 1000000 
  end
end
