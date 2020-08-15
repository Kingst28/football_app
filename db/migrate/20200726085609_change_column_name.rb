class ChangeColumnName < ActiveRecord::Migration
  def change
    rename_column :notifications, :type, :status
  end
end
