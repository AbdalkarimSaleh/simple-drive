module V1
  class BlobsController < ApplicationController
    before_action :authenticate

    # POST /v1/blobs
    def create
      decoded_data = decode_base64_data(blob_params[:data])
      return head :unprocessable_entity if decoded_data.nil?

      # Use the environment-configured storage type as the initial storage type
      blob = Blob.new(id: blob_params[:id], size: decoded_data.bytesize, storage_type: ENV['STORAGE_TYPE'])
      blob.created_at = Time.current

      if blob.save
        storage_service(blob.storage_type).store_blob(blob, decoded_data)
        head :created
      else
        head :unprocessable_entity
      end
    end

    # GET /v1/blobs/:id
    def show
      blob = Blob.find_by(id: params[:id])
      if blob
        stored_data = storage_service(blob.storage_type).retrieve_blob(blob.id)
        if stored_data
          render json: { id: blob.id, data: Base64.encode64(stored_data), size: blob.size, created_at: blob.created_at.utc }
        else
          render json: { error: 'Blob data not found' }, status: :not_found
        end
      else
        render json: { error: 'Blob not found' }, status: :not_found
      end
    end

    private

    def decode_base64_data(encoded_data)
      Base64.decode64(encoded_data)
    rescue ArgumentError
      nil
    end

    # Dynamically choose the storage service based on the provided storage type
    def storage_service(storage_type)
      StorageService.new(storage_type)
    end

    def blob_params
      params.permit(:id, :data)
    end
  end
end
