require 'aws-sdk-s3'

class S3Representation
  def initialize(filename, bucket_name='il258',path='grupo5')
    @bucket_name = bucket_name
    @path = path
    @filename = filename
  end

  def get_presigned_url
    signer = Aws::S3::Presigner.new
    signer.presigned_url(:get_object, bucket: @bucket_name, key: "#{@path}/#{@filename}".to_s)
  end
end

