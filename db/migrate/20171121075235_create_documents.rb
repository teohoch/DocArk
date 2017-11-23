class CreateDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :documents do |t|
      t.string :name

      t.references :parent_folder, foreign_key: {to_table: :folders}
      t.references :created_by, foreign_key: {to_table: :users}
      t.references :updated_by, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
