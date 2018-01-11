class SampleNameChangeColumnType < ActiveRecord::Migration
  def change
  change_column :fixtures, :hteam, 'text using hteam::text'
  change_column :fixtures, :ateam, 'text using ateam::text'
end
end
