class DateFormatValidator < ActiveModel::EachValidator
  DATE_FORMAT = '%Y-%m-%d'.freeze

  def validate_each(record, attribute, value)
    return unless value.present?

    if !value.is_a?(String) && record.has_attribute_before_type_cast?(attribute)
      value = record.attributes_before_type_cast[attribute.to_s]
    end

    if value.is_a?(String)
      begin
        record[attribute] = Date.strptime(value, DATE_FORMAT)
      rescue Date::Error
        record.errors[attribute] << (options[:message] || "should be formatted #{DATE_FORMAT}")
      end
    end
  end
end
