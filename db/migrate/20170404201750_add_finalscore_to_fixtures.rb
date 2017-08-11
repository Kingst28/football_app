class AddFinalscoreToFixtures < ActiveRecord::Migration
  def change
    add_column :fixtures, :finalscore, :string
  end
end
