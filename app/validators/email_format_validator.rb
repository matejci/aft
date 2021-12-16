class EmailFormatValidator < ActiveModel::EachValidator
  REGEX = /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\z/i

  def validate_each(record, attribute, value)
    return unless value.present?

    unless value.match(REGEX)
      record.errors[attribute] << (options[:message] || 'invalid email address')
    end
  end
end
