# frozen_string_literal: true

require 'acceptance_helper'

resource 'Creator Program' do
  explanation <<~DOCS
    +  `creator_program_opted` attribute can take 3 values: true, false, nil
    + when 'nil' it means that user hasn't opted yet
  DOCS

  include_context 'authenticated request', user_session: true

  route '/creator_program/status.json', 'Status' do
    get 'get details about creator program' do
      context 'success' do
        before { create(:creator_program) }

        example_request '200' do
          expect(status).to eq 200
          parsed_response = JSON.parse(response_body)
          expect(parsed_response).to include('active', 'threshold', 'currently_taken')
        end
      end
    end
  end

  route '/creator_program/opt_in.json', 'opt-in' do
    post 'opt-in for creator program' do
      with_options scope: :creator_program do
        parameter :opt_in, required: true
      end

      let(:opt_in) { true }

      context 'active creator program' do
        before { create(:creator_program) }

        example '200' do
          do_request
          expect(status).to eq 200
          expect(response_body).to be_empty
        end
      end

      context 'inactive creator program' do
        before { create(:creator_program, active: false) }

        example_request '400' do
          expect(status).to eq 400
          expect(JSON.parse(response_body)).to include('error')
        end
      end
    end
  end
end
