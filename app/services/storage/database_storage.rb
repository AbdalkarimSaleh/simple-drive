module Storage
    class DatabaseStorage < BaseStorage
      def store_blob(blob, data)
        BlobStorage.create!(blob_id: blob.id, data: data)
      end
  
      def retrieve_blob(blob_id)
        storage_record = BlobStorage.find_by(blob_id: blob_id)
        storage_record&.decoded_data
      end
    end
  end
  