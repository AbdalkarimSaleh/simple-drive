require 'net/ftp'

module Storage
  class FtpStorage < BaseStorage
    def initialize(host:, user:, password:, base_directory: '/')
      @host = host
      @user = user
      @password = password
      @base_directory = base_directory
    end

    # Store a blob in the FTP server
    def store_blob(blob, data)
      filename = "#{blob.id}.bin"
      connect_ftp do |ftp|
        # Change to the base directory if specified
        ftp.chdir(@base_directory) if @base_directory.present?
        # Write the file to the FTP server
        ftp.storbinary("STOR #{filename}", StringIO.new(data))
      end
    end

    # Retrieve a blob from the FTP server
    def retrieve_blob(blob_id)
      filename = "#{blob_id}.bin"
      file_data = nil
      connect_ftp do |ftp|
        ftp.chdir(@base_directory) if @base_directory.present?
        # Retrieve the file content
        ftp.retrbinary("RETR #{filename}", 1024) do |block|
          file_data ||= ''
          file_data += block
        end
      end
      file_data
    end

    private

    # Establish an FTP connection
    def connect_ftp
        Net::FTP.open(@host) do |ftp|
          puts "Connecting to FTP server #{@host}..."
          ftp.passive = true # Use passive mode for FTP connection
          ftp.login(@user, @password)
          puts "Logged in to FTP server as #{@user}"
          yield ftp if block_given?
        rescue Net::FTPConnectionError => e
          puts "Failed to connect to FTP server: #{e.message}"
        rescue Net::FTPPermError => e
          puts "Permission error: #{e.message}"
        rescue Net::FTPReplyError => e
          puts "Reply error: #{e.message}"
        rescue StandardError => e
          puts "General FTP error: #{e.message}"
        ensure
          ftp.close if ftp && !ftp.closed?
        end
      end
  end
end
