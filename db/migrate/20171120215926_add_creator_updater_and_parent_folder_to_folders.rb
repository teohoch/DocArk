class AddCreatorUpdaterAndParentFolderToFolders < ActiveRecord::Migration[5.1]
  def change
    add_reference :folders, :created_by, foreign_key: {to_table: :users}
    add_reference :folders, :updated_by, foreign_key: {to_table: :users}
    add_reference :folders, :parent_folder, foreign_key: {to_table: :folders}
  end
end
