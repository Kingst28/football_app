class AddTakenToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :taken, :string
  end
end
