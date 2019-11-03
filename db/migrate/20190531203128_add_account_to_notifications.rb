class AddAccountToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :account_id, :integer
    add_index  :notifications, :account_id
  end
end
