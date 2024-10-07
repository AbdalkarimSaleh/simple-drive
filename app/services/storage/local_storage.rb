require 'fileutils'

module Storage
  class LocalStorage < BaseStorage
    def initialize(local_path: 'storage')
      @local_path = local_path
      FileUtils.mkdir_p(@local_path) unless Dir.exist?(@local_path)
    end

    # Store a blob as a local file
    def store_blob(blob, data)
      file_path = File.join(@local_path, "#{blob.id}.bin")
      File.open(file_path, 'wb') do |file|
        file.write(data)
      end
    end

    # Retrieve a blob from the local filesystem
    def retrieve_blob(blob_id)
      file_path = File.join(@local_path, "#{blob_id}.bin")
      File.exist?(file_path) ? File.read(file_path) : nil
    end
  end
end
