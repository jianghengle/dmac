class CreateControls < ActiveRecord::Migration[5.0]
  def change
    create_table :controls do |t|
      t.references :project, foreign_key: true
      t.string :email
      t.string :role

      t.timestamps
    end

    add_index :controls, :email
  end
end
