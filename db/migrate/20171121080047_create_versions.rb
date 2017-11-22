class CreateVersions < ActiveRecord::Migration[5.1]
  def change
    create_table :versions do |t|
      t.integer :version
      t.integer :size
      t.references :document, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :current

      t.string :access_url
      t.datetime :expiration_date

      t.datetime :created_at, null: false
    end
  end
end
