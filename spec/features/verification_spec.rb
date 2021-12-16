# frozen_string_literal: true

require 'rails_helper'

feature 'Verification' do
  scenario 'verify email' do
    visit email_verification_url(token: 'any_token')
    expect(page).to have_content('Link invalid')
  end
end
