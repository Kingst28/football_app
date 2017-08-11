class SampleNameChangeColumnType < ActiveRecord::Migration
  def change
    change_column(:fixtures, :hteam, :integer)
    change_column(:fixtures, :ateam, :integer)
end
end
