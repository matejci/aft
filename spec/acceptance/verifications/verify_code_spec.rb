# frozen_string_literal: true

require 'acceptance_helper'
require 'support/twilio_mock'

resource 'Verification: Verify Code' do
  include_context 'authenticated request'

  let(:user) { create(:user) }

  with_options scope: :verification, required: true do
    parameter :email, 'email associated with account'
    parameter :phone, 'phone number associated with account'
    parameter :code, 'code that was sent to email/phone'
  end

  route '/verification/verify_code.json', 'verify code' do
    post 'verify code' do
      context 'email code' do
        let(:code) { user.email_verification.code }

        before do
          Verifications::SendEmailService.new(
            verification: user.build_email_verification(email: user.email)
          ).call
        end

        context 'email' do
          let(:email) { user.email }

          example_request '200' do
            expect(status).to eq 200
            expect(parsed_response['status']).to eq 'success'
            expect(parsed_response['password_verification_token']).to eq(
              user.password_verification_token
            )
          end

          context 'invalid code' do
            let(:code) { '0000' }

            example_request '422' do
              expect(status).to eq 422
              expect(parsed_response['status']).to eq 'error'
              expect(parsed_response['message']).to eq 'Code does not match'
            end
          end

          context 'expired code' do
            before { user.email_verification.set(expires_at: 1.second.ago) }

            example_request '422' do
              expect(status).to eq 422
              expect(parsed_response['status']).to eq 'error'
              expect(parsed_response['message']).to eq 'verification expired'
            end
          end

          context 'incomplete user' do
            before { user.set(completed_signup: false) }

            example_request '422: incomplete user' do
              expect(status).to eq 422
              expect(parsed_response['message']).to eq 'account not found'
            end

            context 'with current_user' do
              before { prepare_user_session(user) }

              example_request '200: with access token' do
                expect(status).to eq 200
              end
            end
          end
        end
      end

      context 'sms code' do
        include_context 'twilio mock'

        let(:code) { user.phone_verification.code }

        before do
          Verifications::SendSmsService.new(
            verification: user.build_phone_verification(phone: user.phone)
          ).call
        end

        context 'phone' do
          let(:phone) { user.phone }

          example_request '200' do
            expect(status).to eq 200
            expect(parsed_response['status']).to eq 'success'
            expect(parsed_response['password_verification_token']).to eq(
              user.password_verification_token
            )
          end
        end
      end

      context 'no verification' do
        let(:email) { user.email }

        example_request '422' do
          expect(status).to eq 422
          expect(parsed_response['status']).to eq 'error'
          expect(parsed_response['message']).to eq 'no verification found'
        end
      end
    end
  end
end
