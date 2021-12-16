# frozen_string_literal: true

class UsernameFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank? || value.match?(/\A\w{4,30}\Z/)

    record.errors[attribute] << 'only 4-30 characters of numbers/letters are allowed'
  end
end
