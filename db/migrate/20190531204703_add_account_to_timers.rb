class AddAccountToTimers < ActiveRecord::Migration
  def change
    add_column :timers, :account_id, :integer
    add_index  :timers, :account_id
  end
end
