# frozen_string_literal: true

require 'acceptance_helper'
require 'support/twilio_mock'

resource 'Verification: Send Code' do
  include_context 'authenticated request'
  include_context 'twilio mock'

  let(:user) { create(:user) }

  with_options scope: :verification, required: true do
    parameter :email, 'email associated with account'
    parameter :phone, 'phone number associated with account'
  end

  route '/verification/send_code.json', 'send code' do
    post 'send verification' do
      context 'email' do
        let(:email) { user.email }

        example_request '200' do
          expect(status).to eq 200
          expect(parsed_response['status']).to eq 'success'
          expect(parsed_response['message']).to eq "code sent to #{email}"
        end

        context 'incomplete user' do
          before { user.set(completed_signup: false) }

          example_request '422' do
            expect(status).to eq 422
            expect(parsed_response['message']).to eq 'account not found'
          end

          context 'with current_user' do
            before { prepare_user_session(user) }

            example_request '200' do
              expect(status).to eq 200
              expect(parsed_response['message']).to eq "code sent to #{email}"
            end
          end
        end

        context 'no account (email)' do
          let(:email) { 'no@user.com' }

          example_request '422: no account' do
            expect(status).to eq 422
            expect(parsed_response['message']).to eq 'account not found'
          end
        end
      end

      context 'sms code' do
        context 'valid request' do
          before do
            @text_count = 0

            expect(twilio_client).to receive_message_chain('messages.create') do
              @text_count += 1
              twilio_message
            end
          end

          context 'phone' do
            let(:phone) { user.phone }

            example_request '200' do
              expect(status).to eq 200
              expect(@text_count).to eq 1
              expect(parsed_response['status']).to eq 'success'
              expect(parsed_response['message']).to eq "code sent to #{phone}"
            end
          end
        end

        context 'too many requests' do
          let(:phone) { user.phone }

          before do
            user.build_phone_verification.update!(
              phone: phone,
              code: '0000',
              expires_at: 2.minutes.after,
              attempts: [2.minutes.ago, 1.minute.ago, 30.seconds.ago]
            )

            expect(twilio_client).not_to receive(:messages)
          end

          example_request '422' do
            expect(status).to eq 422
            expect(parsed_response['status']).to eq 'error'
            expect(parsed_response['message']).to eq(
              'You are sending too many requests. Wait a bit and try again'
            )
          end
        end
      end

      context 'non-existing account' do
        context 'no account (phone)' do
          let(:phone) { '+123-4567890' }

          example_request '422: no account (phone)' do
            expect(status).to eq 422
            expect(parsed_response['status']).to eq 'error'
            expect(parsed_response['message']).to eq 'account not found'
          end
        end

        context 'no account (email)' do
          let(:email) { 'no_user@email.com' }

          example_request '422: no account (email)' do
            expect(status).to eq 422
            expect(parsed_response['message']).to eq 'account not found'
          end
        end
      end

      context 'no method' do
        let(:phone) { nil }

        example_request '422: no method' do
          expect(status).to eq 422
          expect(parsed_response['status']).to eq 'error'
          expect(parsed_response['message']).to eq 'please provide either email or phone'
        end
      end

      context 'invalid method' do
        let(:email) { user.email }
        let(:phone) { user.phone }

        example_request '422: invalid method' do
          expect(status).to eq 422
          expect(parsed_response['status']).to eq 'error'
          expect(parsed_response['message']).to eq 'please provide either email or phone'
        end
      end

      example_request '400: missing params' do
        expect(status).to eq 400
      end
    end
  end
end
