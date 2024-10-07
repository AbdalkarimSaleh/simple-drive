require 'openssl'
require 'base64'
require 'digest'
require 'uri'
require 'cgi'
require 'time'

module Storage
  module Aws4Signer
  SIGN_V4_ALGORITHM = 'AWS4-HMAC-SHA256'.freeze

  # Return HMAC-SHA256 digest of given key and data
  def self.hmac_hash(key, data)
    OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), key, data)
  end

  # Return SHA256 hash of the content
  def self.sha256_hash(content)
    Digest::SHA256.hexdigest(content)
  end

  # Get scope string
  def self.get_scope(date, region, service_name)
    "#{date.strftime('%Y%m%d')}/#{region}/#{service_name}/aws4_request"
  end

  # Get canonical headers and signed headers
  def self.get_canonical_headers(headers)
    ordered_headers = headers.sort_by { |key, _| key.downcase }
    canonical_headers = ordered_headers.map { |k, v| "#{k.downcase}:#{v.strip}" }.join("\n") + "\n"
    signed_headers = ordered_headers.map { |k, _| k.downcase }.join(';')
    [canonical_headers, signed_headers]
  end

  # Get canonical query string
  def self.get_canonical_query_string(query)
    return '' if query.nil? || query.empty?

    query.split('&').map { |param| param.split('=').map { |v| CGI.escape(v) }.join('=') }.sort.join('&')
  end

  # Get canonical request hash
  def self.get_canonical_request(http_method, uri, headers, payload)
    canonical_uri = uri.path.empty? ? '/' : uri.path
    canonical_querystring = get_canonical_query_string(uri.query)
    canonical_headers, signed_headers = get_canonical_headers(headers)
    payload_hash = sha256_hash(payload || '')

    canonical_request = [
      http_method,
      canonical_uri,
      canonical_querystring,
      canonical_headers,
      signed_headers,
      payload_hash
    ].join("\n")

    [sha256_hash(canonical_request), signed_headers]
  end

  # Get string-to-sign
  def self.get_string_to_sign(date, scope, canonical_request_hash)
    [
      SIGN_V4_ALGORITHM,
      date.utc.strftime('%Y%m%dT%H%M%SZ'),
      scope,
      canonical_request_hash
    ].join("\n")
  end

  # Generate the signing key using AWS Signature Version 4
  def self.get_signing_key(secret_key, date, region, service_name)
    date_key = hmac_hash("AWS4" + secret_key, date.strftime('%Y%m%d'))
    region_key = hmac_hash(date_key, region)
    service_key = hmac_hash(region_key, service_name)
    hmac_hash(service_key, 'aws4_request')
  end

  # Get signature
  def self.get_signature(signing_key, string_to_sign)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), signing_key, string_to_sign)
  end

  # Build the Authorization header
  def self.get_authorization_header(access_key, scope, signed_headers, signature)
    "#{SIGN_V4_ALGORITHM} Credential=#{access_key}/#{scope}, SignedHeaders=#{signed_headers}, Signature=#{signature}"
  end

  # Sign the request using AWS Signature Version 4
  def self.sign_v4(http_method, uri, region, headers, access_key, secret_key, payload = '')
    date = Time.now.utc
    scope = get_scope(date, region, 's3')

    # Step 1: Create the canonical request
    canonical_request_hash, signed_headers = get_canonical_request(http_method, uri, headers, payload)

    # Step 2: Create the string to sign
    string_to_sign = get_string_to_sign(date, scope, canonical_request_hash)

    # Step 3: Calculate the signing key and signature
    signing_key = get_signing_key(secret_key, date, region, 's3')
    signature = get_signature(signing_key, string_to_sign)

    # Step 4: Generate the authorization header
    headers['Authorization'] = get_authorization_header(access_key, scope, signed_headers, signature)
    headers['x-amz-date'] = date.utc.strftime('%Y%m%dT%H%M%SZ')

    headers
  end
end
end
