# frozen_string_literal: true

class PhoneFormatValidator < ActiveModel::EachValidator
  REGEX = /\A\+[0-9]{1,3}-[0-9]{4,14}\z/.freeze

  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, options[:message] || :invalid_phone) unless value.match?(REGEX)
  end
end
