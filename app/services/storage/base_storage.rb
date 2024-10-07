module Storage
    class BaseStorage
      def store_blob(blob)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
  
      def retrieve_blob(blob_id)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end
  end
  