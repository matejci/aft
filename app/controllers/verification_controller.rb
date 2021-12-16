# frozen_string_literal: true

class VerificationController < ApplicationController
  before_action :set_user, except: :verify_email

  def verify_email
    respond_to :html
    render :invalid_link # for verification emails that have been sent out
  end

  def send_code
    respond_to :json

    # TODO: what if user is initiating new request (new_phone)

    send_code = SendCodeService.new(**verification_params.except(:code).merge(user: @user).to_h.symbolize_keys).call

    if send_code[:success]
      render json: { status: 'success', message: send_code[:message] }
    else
      render json: { status: 'error', message: send_code[:message] }, status: :unprocessable_entity
    end
  end

  def verify_code
    respond_to :json

    verify_code = Verifications::VerifyCodeService.new(**verification_params.merge(user: @user).to_h.symbolize_keys).call

    if verify_code[:success]
      verification = verify_code[:verification]
      response = { status: 'success', verifying_new: verification.verifying_new? }

      !verification.verifying_new? &&
        response[:password_token] = GeneratePasswordTokenService.new(user: verification.user).call

      render json: response
    else
      render json: { status: 'error', message: verify_code[:message] }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    methods = verification_params.slice(:email, :phone).to_h.filter { |_k, v| v.present? }
    if methods.length == 1
      @user = @current_user || User.find_with(methods.values.first)
      error = 'account not found' if @user.nil?
    else
      error = 'please provide either email or phone'
    end

    render json: { status: 'error', message: error }, status: :unprocessable_entity if error
  end

  def verification_params
    params.require(:verification).permit(:email, :phone, :code)
  end
end
