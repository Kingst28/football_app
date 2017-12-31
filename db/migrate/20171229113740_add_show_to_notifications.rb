class AddShowToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :show, :string
  end
end
