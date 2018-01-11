class SampleNameChangeColumnType < ActiveRecord::Migration
  def change
    change_column(:fixtures, :hteam, :integer) USING :hteam::integer
    change_column(:fixtures, :ateam, :integer) USING :hteam::integer
end
end
