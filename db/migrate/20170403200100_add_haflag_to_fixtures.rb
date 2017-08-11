class AddHaflagToFixtures < ActiveRecord::Migration
  def change
    add_column :fixtures, :haflag, :string
  end
end
