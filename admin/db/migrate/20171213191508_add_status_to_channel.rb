class AddStatusToChannel < ActiveRecord::Migration[5.0]
  def change
  	add_column :channels, :status, :string
  end
end
