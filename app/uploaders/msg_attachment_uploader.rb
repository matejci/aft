# frozen_string_literal: true

class MsgAttachmentUploader < CarrierWave::Uploader::Base
  # include CarrierWave::MiniMagick

  storage :aws

  def store_dir
    "#{mounted_as}/#{model.id}"
  end

  def extension_whitelist
    %w[jpg jpeg gif png svg txt doc docx xls xlsx pdf]
  end
end
