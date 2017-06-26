class ChangeFieldNameOnControl < ActiveRecord::Migration[5.0]
  def change
  	rename_column :controls, :group, :group_name
  end
end
