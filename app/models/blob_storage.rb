class BlobStorage < ApplicationRecord
    # Associations
    belongs_to :blob, primary_key: :id, foreign_key: :blob_id
  
    # Validations
    validates :blob_id, presence: true
    validates :data, presence: true
  
    # Before saving, ensure that data is stored as Base64 encoded string
    before_save :encode_data
  
    # Return the data as a Base64 decoded string
    def decoded_data
      Base64.decode64(self.data)
    end
  
    private
  
    # Encode the binary data into Base64 format before saving
    def encode_data
      if self.data.encoding != Encoding::ASCII_8BIT
        self.data = Base64.encode64(self.data.force_encoding("ASCII-8BIT"))
      else
        self.data = Base64.encode64(self.data)
      end
    end
  end
  