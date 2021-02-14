class AddTeamsheetToBids < ActiveRecord::Migration
  def change
    add_reference :bids, :teamsheet, index: true, foreign_key: true
  end
end
