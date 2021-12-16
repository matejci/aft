# frozen_string_literal: true

require 'acceptance_helper'

resource 'Users' do
  include_context 'authenticated request', user_session: true

  explanation <<~EXPLANATION
    + `/users.json` will return 302(redirect) if non-admin session tries to access data
    + `400`: bad request
    + on /current/user/session.json
      + `creator_program_opted`: true == people who have attempted to sign up for creator program
      + `monetization_status_type`: enabled == people who are currently in the creator program receiving payments
  EXPLANATION

  route '/user/blocked_accounts/p/:page.json', 'get blocked accounts' do
    get 'get blocked accounts' do
      parameter :page, 'for pagination (default: 1)', example: 1

      context '200' do
        before { user.block!(create(:user, username: 'user_b')) }

        example_request '200' do
          expect(status).to eq 200
          expect(JSON.parse(response_body).first['username']).to eq 'user_b'
        end
      end

      context 'without user session' do
        before { header 'HTTP-ACCESS-TOKEN', nil }

        example_request '401' do
          expect(status).to eq 401
          expect(headers['HTTP-ACCESS-TOKEN']).to be_nil
          expect(response_body).to eq({ base: 'No user session' }.to_json)
        end
      end
    end
  end

  route '/users.json', 'get users' do
    get 'get users' do
      context '200' do
        before { user.set(admin_role: :admin) }

        example_request '200' do
          expect(status).to eq 200
          expect(parsed_response.map { |u| u['id'] }).to eq(User.all.map { |u| u.id.to_s })
        end
      end

      context '302' do
        example_request '302: non-admin user' do
          expect(status).to eq 302
        end
      end
    end
  end

  route '/users/:id.json', 'get user' do
    parameter :id, 'user id', required: true

    let(:id) { user.id }

    get 'get user' do
      context '200' do
        before { user.set(admin_role: :administrator) }

        example_request '200' do
          expect(status).to eq 200
        end
      end

      context '302' do
        example_request '302: non-admin user' do
          expect(status).to eq 302
        end
      end
    end
  end

  route '/users/:id.json', 'destroy user' do
    let(:id) { user.id }

    delete 'destoy user' do
      context '204' do
        before { user.set(admin_role: :admin) }

        example_request '204' do
          expect(status).to eq 204
        end
      end

      context '302' do
        example_request '302: non-admin user' do
          expect(status).to eq 302
        end
      end
    end
  end

  route '/user.json', 'update user' do
    before { create(:user_configuration, user: user) }

    include_user_attributes

    patch 'update user' do
      context 'update phone' do
        let(:new_phone) { '+1-9876543210' }

        example_request '200: new phone' do
          expect(status).to eq 200

          user.reload
          expect(user.phone).not_to eq new_phone
          expect(user.phone_verification.phone).to eq new_phone
        end
      end

      context 'verify new phone' do
        let(:phone_code) do
          UserUpdateService.new(user: user, params: { new_phone: '+1-1234567890' }).call
          user.phone_verification.code
        end

        example_request '200: phone code' do
          expect(status).to eq 200

          user.reload
          expect(user.phone).to eq '+1-1234567890'
          expect(user.phone_verified_at).to be_present
        end
      end

      context 'update email' do
        let(:new_email) { 'new@email.com' }

        example_request '200: new email' do
          expect(status).to eq 200

          user.reload
          expect(user.email).not_to eq new_email
          expect(user.email_verification.email).to eq new_email
        end
      end

      context 'verify new email' do
        let(:email_code) do
          UserUpdateService.new(user: user, params: { new_email: 'newnew@email.com' }).call
          user.email_verification.code
        end

        example_request '200: email code' do
          expect(status).to eq 200

          user.reload
          expect(user.email).to eq 'newnew@email.com'
          expect(user.email_verified_at).to be_present
        end
      end

      context 'unavailable email' do
        let(:other_user) { create(:user, email: 'existing@email.com') }
        let(:new_email) { other_user.email }

        example_request '422: unavailable email' do
          expect(status).to eq 422
          expect(parsed_response['new_email']).to be_present
        end
      end
    end
  end

  route '/current/user/session.json', 'validating current user session' do
    post 'validating current user session' do
      context '201' do
        before { create(:creator_program) }

        example_request '201' do
          expect(status).to eq 201
          expect(parsed_response['valid_account']).to eq true
          expect(parsed_response['account_errors']).to be_empty
          expect(parsed_response).to have_key 'creator_program_opted'
          expect(parsed_response).to have_key 'monetization_status_type'
        end
      end

      context '201: incomplete user' do
        before { user.set(completed_signup: false, display_name: nil) }
        before { create(:creator_program) }

        example_request '201: incomplete user' do
          expect(status).to eq 201
          expect(parsed_response['valid_account']).to eq false
          expect(parsed_response['account_errors']).to have_key('display_name')
        end
      end

      context '422' do
        before { header 'HTTP-ACCESS-TOKEN', nil }

        example_request '422' do
          expect(status).to eq 422
        end
      end
    end
  end

  route '/user/remove_account.json', 'remove account' do
    post 'remove account' do
      parameter :password, 'password for the account'

      context '200' do
        before do
          create(:post, user: user)
          create(:payout, user: user)
        end

        let(:password) { '123456' }

        example_request '200' do
          expect(status).to eq 200

          user.reload
          expect(user.deactivated?).to eq true
          expect(user.removal_requested_at).to be_present
          expect(user.removal_deactivation_at).to be_present
          expect(user.removal_ip_address).to be_present
          expect(user.removal_user_agent).to be_present
          expect(user.removal_reason).to eq :user_requested
          expect(user.sessions.all? { |session| !session.live? }).to eq true
          expect(user.posts.all? { |post| !post.active? }).to eq true
          expect(user.should_index?).to eq false

          new_user = User.new(username: user.username)
          new_user.valid?
          expect(new_user.errors[:username]).to include('Username is not available')

          DeleteAccountsService.new(date: user.removal_deactivation_at.to_date).call

          user.reload
          expect(user.deleted?).to eq true
          expect(user.should_index?).to eq false
          expect(User.valid.count).to eq 0

          new_user = User.new(username: user.username)
          new_user.valid?
          expect(new_user.errors).not_to include(:username)
        end
      end

      context '422' do
        example_request '422' do
          expect(status).to eq 422
          expect(parsed_response['errors']['password']).to be_present
          expect(user.deactivated?).to eq false
          expect(user.should_index?).to eq true
          expect(user.posts.all?(&:active?)).to eq true
        end
      end
    end
  end
end
