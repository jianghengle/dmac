class AddMetaDataToProject < ActiveRecord::Migration[5.0]
  def change
  	add_column :projects, :meta_data, :string
  end
end
