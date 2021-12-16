# frozen_string_literal: true

module Aws
  class TranscodeService
    PRESETS = {
      P1: '1619018779123-jvbcv1', # 888x1920 192Kbps
      P2: '1619018842284-nwhi0g', # 722x1560 192Kbps
      P3: '1619018894626-zo48jy', # 586x1266 192Kbps
      P4: '1619018984121-wbwhei', # 500x1080 192Kbps
      P5: '1619019035315-eussv5', # 500x1080 128Kbps
      P6: '1619019078619-53lqb2', # 410x886 128Kbps
      P7: '1619019125119-860jpt'  # 294x634 128Kbps
    }.freeze

    def initialize(file:, pipeline_name: "#{ENV['HEROKU_ENV']}_pipeline")
      raise 'No file given' if file.blank?

      @file = file
      @pipeline_name = pipeline_name
    end

    def call
      transcode_media_file unless Rails.env.test?
    end

    private

    attr_reader :file, :pipeline_name

    def transcode_media_file
      transcoder = Aws::ElasticTranscoder::Client.new(access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                                                      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
                                                      region: 'us-west-1')
      pipeline = transcoder.list_pipelines.pipelines.select { |ppl| ppl.name == pipeline_name }

      raise 'No active pipeline' if pipeline.blank?

      pipeline_id = pipeline.first.id
      outputs = []

      PRESETS.each do |k, val|
        outputs << {
          key: "#{file}_#{k}",
          preset_id: val,
          segment_duration: '5.0',
          thumbnail_pattern: ''
        }
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
