# Require necessary libraries
require 'net/http'   # Provides HTTP request methods
require 'uri'        # Provides URI parsing and handling
require 'openssl'    # Provides OpenSSL for HMAC
require 'base64'     # Provides Base64 encoding/decoding
require 'digest'     # Provides SHA256 hashing
require 'cgi'        # Provides CGI escaping/unescaping

module Storage
  class S3Storage < BaseStorage
    def initialize(bucket_name:, s3_endpoint:, access_key_id:, secret_access_key:, region: 'us-east-1')
      @bucket_name = bucket_name
      @s3_endpoint = s3_endpoint
      @access_key_id = access_key_id
      @secret_access_key = secret_access_key
      @region = region
    end

    # Store a blob in the S3 bucket
    def store_blob(blob, data)
      uri = build_s3_uri(blob.id)
      request = Net::HTTP::Put.new(uri)
      request.body = data
      content_type = 'application/octet-stream'
      request['Content-Type'] = content_type

      # Set necessary headers for signing
      headers = { 'host' => uri.host, 'content-type' => content_type }
      Storage::Aws4Signer.sign_v4('PUT', uri, @region, headers, @access_key_id, @secret_access_key, data)

      # Apply headers to the request
      headers.each { |key, value| request[key] = value }

      response = execute_request(uri, request)
      raise "Failed to store blob in S3: #{response.body}" unless response.is_a?(Net::HTTPSuccess)
    end

    # Retrieve a blob from the S3 bucket
    def retrieve_blob(blob_id)
      uri = build_s3_uri(blob_id)
      request = Net::HTTP::Get.new(uri)

      # Set necessary headers for signing
      headers = { 'host' => uri.host }
      Storage::Aws4Signer.sign_v4('GET', uri, @region, headers, @access_key_id, @secret_access_key)

      # Apply headers to the request
      headers.each { |key, value| request[key] = value }

      response = execute_request(uri, request)
      response.is_a?(Net::HTTPSuccess) ? response.body : nil
    end

    private

    # Build the S3 URI for a given blob ID
    def build_s3_uri(blob_id)
      URI("#{@s3_endpoint}/#{@bucket_name}/#{CGI.escape(blob_id)}.bin")
    end

    # Execute an HTTP request
    def execute_request(uri, request)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end
    end
  end
end
