class AddFnameToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :fname, :string
  end
end
