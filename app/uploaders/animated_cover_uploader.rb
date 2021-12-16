# frozen_string_literal: true

class AnimatedCoverUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :aws if Rails.env.in?(%w[development production])

  def store_dir
    "#{mounted_as}/#{model.id}"
  end

  def extension_whitelist
    %w[mp4 mov]
  end
end
