class AddFieldToProject < ActiveRecord::Migration[5.0]
  def change
  	add_column :projects, :auto_history, :boolean
  end
end
