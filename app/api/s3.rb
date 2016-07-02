module API
  class S3
    class << self
      def resource
        @resource ||= Aws::S3::Resource.new({
          region: ENV['AWS_REGION'] || 'us-east-1'
        })
      end

      def bucket
        resource.bucket(ENV['AWS_S3_BUCKET'])
      end
    end
  end
end
