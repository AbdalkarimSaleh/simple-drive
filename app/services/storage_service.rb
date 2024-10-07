class StorageService
    def initialize(storage_type)
      @storage_type = storage_type
    end
  
    # Store a blob using the appropriate storage service
    def store_blob(blob, data)
      storage_adapter.store_blob(blob, data)
    end
  
    # Retrieve a blob using the appropriate storage service
    def retrieve_blob(blob_id)
      storage_adapter.retrieve_blob(blob_id)
    end
  
    private
  
    # Determine the appropriate storage adapter based on the blob's storage type
    def storage_adapter
      case @storage_type
      when 's3'
        Storage::S3Storage.new(
          bucket_name: ENV['S3_BUCKET_NAME'],
          s3_endpoint: ENV['S3_ENDPOINT'],
          access_key_id: ENV['S3_ACCESS_KEY_ID'],
          secret_access_key: ENV['S3_SECRET_ACCESS_KEY'],
          region: ENV['S3_REGION']
        )
      when 'database'
        Storage::DatabaseStorage.new
      when 'local'
        Storage::LocalStorage.new(local_path: ENV['LOCAL_STORAGE_PATH'] || 'storage')
      when 'ftp'
        Storage::FtpStorage.new(
          host: ENV['FTP_HOST'],
          user: ENV['FTP_USER'],
          password: ENV['FTP_PASSWORD'],
          base_directory: '/'
        )
      else
        raise "Unknown storage type: #{@storage_type}"
      end
    end
  end
  