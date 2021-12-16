# frozen_string_literal: true

class PhoneVerification < Verification
  field :phone, type: String
  field :twilio_sids, type: Array, default: []

  private

  def set_verifying_new
    self.verifying_new = user.phone != phone
  end
end
