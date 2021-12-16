# frozen_string_literal: true

class MediaThumbnailUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  process :store_dimensions

  # Choose what kind of storage to use for this uploader:
  storage :aws if Rails.env.in?(%w[development production])

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{mounted_as}/#{model.id}"
  end

  version :thumb do
    process resize_to_fill: [360, 640]
  end

  version :standard do
    process resize_to_fill: [720, 1280]
  end

  version :original_thumb do
    process resize_to_fit: [400, 400]
  end

  private

  def store_dimensions
    return unless file && model

    dimensions = ::MiniMagick::Image.open(file.file)[:dimensions]
    model.media_thumbnail_dimensions = { width: dimensions[0], height: dimensions[1] }
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_whitelist
  #   %w(jpg jpeg png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
end
