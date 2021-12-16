# frozen_string_literal: true

class DigitsValidator < ActiveModel::EachValidator
  MESSAGES = %i[not_a_number not_an_integer too_long too_short wrong_length].freeze

  def validate_each(record, attribute, value)
    return if value.blank?

    @record = record
    @attribute = attribute

    digits_validate :numericality, only_integer: true
    digits_validate :length, options[:length]

    return unless record.errors.include?(attribute)

    errors = []
    args = {}

    record.errors.details[attribute].delete_if do |detail|
      next unless MESSAGES.include? detail[:error]

      errors.push delete_error(detail)
      args.merge! detail
      true
    end

    record.errors.add(attribute, get_message(errors), **args) if errors.any?
  end

  private

  def delete_error(detail)
    error = detail.delete(:error)
    delete_message(error, detail)
    error
  end

  def delete_message(error, detail)
    message = @record.errors.generate_message(@attribute, error, detail)
    @record.errors.messages[@attribute] = @record.errors.messages[@attribute].reject { |item| item == message }
  end

  def digits_validate(type, options)
    return if options.blank?

    validator = ActiveModel::Validations.const_get "#{type.capitalize}Validator"
    @record.validates_with validator, attributes: @attribute, **options
  end

  def get_message(errors)
    if (errors & %i[not_a_number not_an_integer]).any?
      :'digits.not_an_integer'
    elsif errors.include?(:wrong_length)
      :'digits.wrong_length'
    elsif errors.include?(:too_short)
      :'digits.too_short'
    elsif errors.include?(:too_long)
      :'digits.too_long'
    end
  end
end
