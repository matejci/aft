# frozen_string_literal: true

require 'acceptance_helper'

resource 'Reset Password' do
  include_context 'authenticated request'

  let(:user) { create(:user) }

  route '/reset_password/send_email.json', 'send reset password email' do
    parameter :email, 'account email', required: true

    post 'send reset password email' do
      context 'existing account' do
        let(:email) { user.email }

        example_request '201' do
          expect(status).to eq 201
          expect(parsed_response['success']).to eq "email sent to #{email}"
        end
      end

      context 'non-existing account' do
        let(:email) { 'no-user@email.com' }

        example_request '422: no account' do
          expect(status).to eq 422
          expect(parsed_response['email']).to include 'account not found'
        end
      end

      example_request '422: missing email' do
        expect(status).to eq 422
        expect(parsed_response['email']).to include "can't be blank"
      end
    end
  end

  route '/reset_password.json', 'reset password' do
    with_options scope: :user, required: true do
      parameter :new_password, 'new password'
      parameter :new_password_confirmation, 'new password confirmation'
      parameter :password_token, 'password token that was generated after code verification'
    end

    post 'reset password' do
      context 'with token' do
        before { GeneratePasswordTokenService.new(user: user).call }

        let(:password_token) { user.password_verification_token }

        example_request '422' do
          expect(status).to eq 422
          expect(parsed_response['new_password']).to include 'Please choose a password'
        end

        context 'valid' do
          let(:new_password) { 'test123' }
          let(:new_password_confirmation) { 'test123' }

          example_request '200' do
            expect(status).to eq 200
            expect(parsed_response['status']).to eq 'success'
            expect(user.reload.authenticate(new_password)).to be true
          end
        end
      end

      context 'invalid token' do
        let(:password_token) { 'invalid_token' }

        example_request '422' do
          expect(status).to eq 422
          expect(parsed_response['status']).to eq 'error'
          expect(parsed_response['message']).to eq 'invalid token'
        end
      end
    end
  end
end
