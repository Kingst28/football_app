class SampleNameChangeColumnType < ActiveRecord::Migration
  def change
  change_column :fixtures, :hteam, :text
  change_column :fixtures, :ateam, :text
end
end
