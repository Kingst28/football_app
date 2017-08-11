class CreateBids < ActiveRecord::Migration
  def change
    create_table :bids do |t|
      t.integer :amount
      t.references :user, index: true
      t.references :player, index: true
      
      t.timestamps
    end
  end
end
