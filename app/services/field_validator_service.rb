# frozen_string_literal: true

class FieldValidatorService
  def initialize(user:, email: nil, phone: nil, field_name: nil)
    @user = user
    @email = email
    @phone = phone
    @field_name = field_name
  end

  def call
    validate_field
  end

  private

  attr_reader :user, :email, :phone, :field_name

  def validate_field
    %i[email phone].each do |field|
      next unless (error = check_error(field))

      user.errors.add(field_name || field, error)
    end
  end

  def check_error(field)
    return unless (value = send(field))

    if value.blank?
      'is required'
    elsif User.valid.not(id: user).where("#{field}": value).exists?
      'is already taken'
    elsif !valid_format?(field, value)
      'is invalid'
    end
  end

  def valid_format?(field, value)
    regex = case field
            when :email
              EmailFormatValidator::REGEX
            when :phone
              PhoneFormatValidator::REGEX
    end

    value.match(regex)
  end
end
