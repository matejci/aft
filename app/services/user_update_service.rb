# frozen_string_literal: true

class UserUpdateService
  include ServiceErrorHandling

  ATTRS = %i[email_code phone_code new_email new_phone].freeze

  def initialize(user:, params:)
    @user = user
    @params = params
  end

  def call
    super { sign_up }
  end

  private

  attr_reader :user, :params, *ATTRS

  def sign_up
    user.attributes = params.except(*ATTRS)
    params.slice(*ATTRS).each { |k, v| instance_variable_set("@#{k}", v) }

    user.valid?
    validate_attrs
    raise InstanceError, user.errors if user.errors.any?

    before_save
    user.save(validate: false)
    # upsert_sendgrid_contact

    complete_signup

    { success: true, user: user }
  end

  def before_save
    # NOTE: order matters
    update_verified_statuses
    send_codes
    user.completed_signup = true if user.finished_signup?
  end

  def complete_signup
    return unless user.completed_signup && user.previous_changes.include?(:completed_signup)

    user.claim_invitation
    user.reindex # make user searchable
    user.follow_takko # auto-follow takko account
  end

  def send_codes
    %i[email phone].each do |field|
      next unless (updated = updated_field(field))

      SendCodeService.new(user: user, "#{field}": updated).call
    end
  end

  def updated_field(field)
    return send("new_#{field}") if send("new_#{field}")
    return user.send(field) if user.changes.include?(field) && !user.send("#{field}_verified_at")
  end

  def update_verified_statuses
    %i[email phone].each do |field|
      if user.send("#{field}_changed?")
        user.send("#{field}_verified_at=", nil)
      elsif send("#{field}_code")
        verification = user.send("#{field}_verification")
        user.send("#{field}=", verification.send(field)) if verification.verifying_new?
        user.send("#{field}_verified_at=", Time.current)
        user.send("#{field}_verification=", nil)
      end
    end
  end

  def validate_attrs
    CodeValidatorService.new(user: user, email_code: email_code, phone_code: phone_code).call
    FieldValidatorService.new(user: user, email: new_email, field_name: :new_email).call if new_email
    FieldValidatorService.new(user: user, phone: new_phone, field_name: :new_phone).call if new_phone
  end

  def upsert_sendgrid_contact
    SendgridAutomation::UpsertContactJob.perform_later(user.id.to_s)
  end
end
