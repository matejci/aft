# frozen_string_literal: true

class EmailVerification < Verification
  field :email, type: String

  private

  def set_verifying_new
    self.verifying_new = user.email != email
  end
end
