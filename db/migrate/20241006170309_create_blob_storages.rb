class CreateBlobStorages < ActiveRecord::Migration[7.1]
  def change
    create_table :blob_storages do |t|
      t.string :blob_id, null: false    # Foreign key referencing blobs table
      t.binary :data, null: false       # Binary data of the blob

      t.timestamps
    end

    add_index :blob_storages, :blob_id, unique: true # Ensure blob_id is unique
    add_foreign_key :blob_storages, :blobs, column: :blob_id, primary_key: :id, on_delete: :cascade
  end
end
