class CreateBlobs < ActiveRecord::Migration[7.1]
  def change
    # Disable auto-generated id and define custom primary key
    create_table :blobs, id: false do |t|
      t.string :id, primary_key: true    # Define id as a string and primary key
      t.integer :size                    # Size of the blob in bytes
      t.string :storage_type             # Type of storage used (e.g., 's3', 'database', 'local', 'ftp')

      t.timestamps
    end
  end
end
