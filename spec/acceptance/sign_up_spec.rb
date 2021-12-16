# frozen_string_literal: true

require 'acceptance_helper'
require 'support/twilio_mock'

resource 'Sign Up' do
  include_context 'authenticated request'
  include_context 'twilio mock'
  include ActionDispatch::TestProcess::FixtureFile

  explanation <<~EXPLANATION
    + required fields for valid user account
        + birthdate, username, display_name, password, (email or phone)
        + verified email if email provided
        + verified phone if phone provided
    + note **
        + user params should be scoped to user `{ user: { first_name: 'John', last_name: 'Doe'} }`
        + server will accept unscoped `multipart_form` fields (background_image, profile_image)
        + parameters that are not part of `url` are regular params (not uri params)
  EXPLANATION

  route '/users.json', 'first step: create user' do
    post 'create user' do
      include_user_attributes

      context '201' do
        let(:phone) { '+1-1234567890' }

        before { expect(twilio_client).to receive_message_chain('messages.create') }

        example_request '201' do
          expect(status).to eq 201
          expect(parsed_response['phone']).to eq phone
          expect(parsed_response['id']).to be_present
          expect(parsed_response['access_token']).to be_present

          phone_verification = User.last.phone_verification
          expect(phone_verification.code).to be_present
          expect(phone_verification.attempts).not_to be_empty
        end
      end

      context '400' do
        example_request '400' do
          expect(status).to eq 400
          expect(parsed_response['error']).to match(/param is missing or the value is empty: user/)
        end
      end

      context '422' do
        let(:phone) { '' }

        example_request '422' do
          expect(status).to eq 422
        end
      end
    end
  end

  route '/user.json', 'following steps: update user' do
    include_user_attributes

    patch 'update user' do
      before do
        prepare_user_session(user)
        create(:user_configuration, user: user)
      end

      context 'phone sign up' do
        let(:user) do
          expect(twilio_client).to receive_message_chain('messages.create')
          UserUpdateService.new(user: User.new, params: { phone: '+1-1234567890' }).call[:user]
        end

        context '200' do
          let(:phone_code) { user.phone_verification.code }

          example_request '200: phone code' do
            expect(status).to eq 200
            expect(User.last.phone_verified_at).to be_present
            expect(parsed_response['completed_signup']).to eq false
            expect(parsed_response['account_errors']).not_to be_empty
          end

          context '422' do
            before { user.phone_verification.update(expires_at: 1.second.ago) }

            example_request '422: expired phone code(after 2 minutes)' do
              expect(status).to eq 422
              expect(parsed_response['phone_code']).to eq ['verification expired']
            end
          end
        end

        context '422' do
          let(:phone_code) { '' }

          example_request '422: blank code' do
            expect(status).to eq 422
            expect(parsed_response['phone_code']).to eq ["code can't be blank"]
          end
        end

        context '422' do
          let(:phone_code) { '0000' }

          example_request '422: wrong code' do
            expect(status).to eq 422
            expect(parsed_response['phone_code']).to eq ['Code does not match']
          end
        end
      end

      context 'email sign up' do
        let(:user) do
          expect(VerificationMailer).to receive_message_chain('with.send_code.deliver_now')
          UserUpdateService.new(user: User.new, params: { email: 'test@email.com' }).call[:user]
        end

        context '200' do
          let(:email_code) { user.email_verification.code }
          let(:birthdate) { '2000-01-05' }
          let(:first_name) { 'Jan' }
          let(:last_name) { 'Five' }
          let(:display_name) { 'Jan Five' }
          let(:username) { '2000_five' }
          let(:password) { 'five12345' }
          let(:profile_image) { fixture_file_upload('public/takko.png') }
          let(:background_image) { fixture_file_upload('public/takko.png') }

          example_request '200' do
            expect(status).to eq 200

            user = User.last
            expect(user.dob.strftime).to eq birthdate
            expect(user.authenticate(password)).to be true
            expect(parsed_response['first_name']).to eq first_name
            expect(parsed_response['last_name']).to eq last_name
            expect(parsed_response['display_name']).to eq display_name
            expect(parsed_response['username']).to eq username
            expect(parsed_response['profile_thumb_url']).to be_present
            expect(parsed_response['background_image_url']).to be_present
            expect(parsed_response['completed_signup']).to be true
            expect(parsed_response['account_errors']).to be_empty
          end
        end

        context '422' do
          let(:email) { 'wrong.format' }
          let(:email_code) { '' }
          let(:birthdate) { '2021-01-01' }
          let(:first_name) { 'nadkfjsdlkfjsldkfjalsdjsfdsflsdjflsdkjfsleijflsk' }
          let(:last_name) { 'nadkfjsdlkfjsldkfjalsdjsfdsflsdjflsdkjfsleijflsk' }
          let(:display_name) { '' }
          let(:username) { '' }
          let(:password) do
            '123456789112345678921234567893123456789412345678951234567896123456'
          end

          example_request '422' do
            expect(status).to eq 422
            expect(parsed_response['birthdate']).to be_present
            expect(parsed_response['first_name']).to be_present
            expect(parsed_response['last_name']).to be_present
            expect(parsed_response['display_name']).to be_present
            expect(parsed_response['username']).to be_present
            expect(parsed_response['password']).to be_present
          end
        end
      end
    end
  end
end
