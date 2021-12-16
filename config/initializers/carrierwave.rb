
CarrierWave.configure do |config|
  config.storage    = :aws
  config.aws_bucket = ENV['S3_BUCKET_NAME'] # for AWS-side bucket access permissions config, see section below
  config.aws_acl    = 'public-read'

  # # Optionally define an asset host for configurations that are fronted by a
  # # content host, such as CloudFront.
  config.asset_host = ENV['CLOUDFRONT_URL']

  # The maximum period for authenticated_urls is only 7 days.
  config.aws_authenticated_url_expiration = 60 * 60 * 24 * 7

  # # Set custom options such as cache control to leverage browser caching.
  # # You can use either a static Hash or a Proc.
  # config.aws_attributes = -> { {
  #   expires: 1.week.from_now.httpdate,
  #   cache_control: 'max-age=604800'
  # } }

  config.aws_credentials = {
    access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    region:            'us-west-1', # Required
    stub_responses:    Rails.env.test? # Optional, avoid hitting S3 actual during tests
  }

  # Optional: Signing of download urls, e.g. for serving private content through
  # CloudFront. Be sure you have the `cloudfront-signer` gem installed and
  # configured:
  # config.aws_signer = -> (unsigned_url, options) do
  #   Aws::CF::Signer.sign_url(unsigned_url, options)
  # end
end

# CloudFront Policy
# {
#     "Version": "2012-10-17",
#     "Id": "PolicyForCloudFrontPrivateContent",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Principal": {
#                 "AWS": “*”
#             },
#             "Action": "s3:GetObject",
#             "Resource": "arn:aws:s3:::takko-localhost/*"
#         }
#     ]
# }
