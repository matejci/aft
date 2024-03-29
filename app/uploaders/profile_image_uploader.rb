# frozen_string_literal: true

class ProfileImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :aws

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  # def store_dir
  #   "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  # end

  def store_dir
    "#{mounted_as}/#{model.id}"
  end

  version :thumb do
    process resize_to_fill: [250, 250]
  end

  version :standard do
    process resize_to_fill: [1000, 1000]
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url(*_args)
    # For Rails 3.1+ asset pipeline compatibility:
    # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "grey_taco.jpg"].compact.join('_'))
    ActionController::Base.helpers.asset_path('fallback/profile_image.png') # temporarily - thumb only
  end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process resize_to_fit: [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_whitelist
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
  def filename
    return if original_filename.blank?

    @filename ||= begin
      extname = File.extname(super)
      super.chomp(extname) + "_#{Time.current.to_i}" + extname
    end
  end
end
