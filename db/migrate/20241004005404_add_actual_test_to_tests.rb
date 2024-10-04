class AddActualTestToTests < ActiveRecord::Migration[7.2]
  def change
    add_column :tests, :actual_test, :text
  end
end
