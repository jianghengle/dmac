class AddStatusIndexToProject < ActiveRecord::Migration[5.0]
  def change
  	add_index :projects, :status
  end
end
