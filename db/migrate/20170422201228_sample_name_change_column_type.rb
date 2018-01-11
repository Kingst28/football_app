class SampleNameChangeColumnType < ActiveRecord::Migration
  def change
    change_column(:fixtures, :hteam, USING :hteam::integer)
    change_column(:fixtures, :ateam, USING :ateam::integer)
end
end
