class CreateProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.string :status
      t.string :key

      t.timestamps
    end

    add_index :projects, :key, unique: true
  end
end
