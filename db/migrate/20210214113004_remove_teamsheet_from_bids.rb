class RemoveTeamsheetFromBids < ActiveRecord::Migration
  def change
    remove_reference :bids, :teamsheet, index: true, foreign_key: true
  end
end
