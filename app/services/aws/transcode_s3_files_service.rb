# frozen_string_literal: true

module Aws
  class TranscodeS3FilesService
    PRESETS = {
      P1: '1619018779123-jvbcv1', # 888x1920 192Kbps
      P2: '1619018842284-nwhi0g', # 722x1560 192Kbps
      P3: '1619018894626-zo48jy', # 586x1266 192Kbps
      P4: '1619018984121-wbwhei', # 500x1080 192Kbps
      P5: '1619019035315-eussv5', # 500x1080 128Kbps
      P6: '1619019078619-53lqb2', # 410x886 128Kbps
      P7: '1619019125119-860jpt'  # 294x634 128Kbps
    }.freeze

    def initialize(pipeline_name: "#{ENV['HEROKU_ENV']}_pipeline", input_bucket_prefix: 'media_file')
      @pipeline_name = pipeline_name
      @input_bucket_prefix = input_bucket_prefix
    end

    def call
      transcode_media_files
    rescue StandardError => e
      Rails.logger.error("TRANSCODE ERROR: #{e.message}")
      raise e.message
    end

    private

    attr_reader :pipeline_name, :input_bucket_prefix

    # rubocop: disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def transcode_media_files
      transcoder = Aws::ElasticTranscoder::Client.new(connection_hash)
      s3 = Aws::S3::Client.new(connection_hash)

      pipeline = transcoder.list_pipelines.pipelines.select { |ppl| ppl.name == pipeline_name }

      raise 'No active pipeline' if pipeline.blank?

      pipeline_id = pipeline.first.id
      input_bucket = pipeline.first.input_bucket

      list_objects = s3.list_objects_v2({ bucket: input_bucket, prefix: input_bucket_prefix })

      raise 'No S3 objects' if list_objects.blank?

      file_urls = list_objects.contents.map(&:key)
      next_token = list_objects.next_continuation_token

      loop do
        results = fetch_objects(s3, input_bucket, next_token)
        file_urls << results.contents.map(&:key)
        file_urls.flatten!
        next_token = results.next_continuation_token

        break unless results.is_truncated
      end

      file_urls.each_with_index do |file, ind|
        create_job(transcoder, pipeline_id, file)
        sleep 1 if (ind % 2).zero?
      end
    end
    # rubocop: enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def fetch_objects(s3_client, input_bucket, next_token)
      s3_client.list_objects_v2({ bucket: input_bucket, continuation_token: next_token, prefix: 'media_file' })
    end

    def connection_hash
      {
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        region: 'us-west-1'
      }
    end

    def create_job(transcoder, pipeline_id, file)
      outputs = []

      PRESETS.each do |k, val|
        output = {
          key: "#{file}_#{k}",
          preset_id: val,
          segment_duration: '5.0',
          thumbnail_pattern: ''
        }

        outputs << output
      end

      transcoder.create_job({ pipeline_id: pipeline_id,
                              input: { key: file,
                                       frame_rate: 'auto',
                                       resolution: 'auto',
                                       aspect_ratio: 'auto',
                                       container: 'auto' },
                              outputs: outputs,
                              playlists: [{ name: "#{file}_playlist",
                                            format: 'HLSv3',
                                            output_keys: outputs.pluck(:key) }] })
    end
  end
end
