# frozen_string_literal: true

class BackgroundImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :aws if Rails.env.in?(%w[development production])

  def store_dir
    "#{mounted_as}/#{model.id}"
  end

  def filename
    return if original_filename.blank?

    @filename ||= begin
      extname = File.extname(super)
      super.chomp(extname) + "_#{Time.current.to_i}" + extname
    end
  end
end
