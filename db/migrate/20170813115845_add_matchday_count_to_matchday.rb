class AddMatchdayCountToMatchday < ActiveRecord::Migration
  def change
    add_column :matchdays, :matchday_count, :integer
  end
end
