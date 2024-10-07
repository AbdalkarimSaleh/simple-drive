# app/models/blob.rb
class Blob < ApplicationRecord
    # Associations
    has_one :blob_storage, dependent: :destroy
  
    # Validations
    validates :id, presence: true, uniqueness: true
    validates :size, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :storage_type, presence: true
  
    # Define the primary key as :id (since it's a custom primary key)
    self.primary_key = 'id'
  end
  