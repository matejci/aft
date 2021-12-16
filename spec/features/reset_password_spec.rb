# frozen_string_literal: true

require 'rails_helper'

feature 'Reset password' do
  let(:user) { create(:user) }

  background do
    clear_emails
    SendPasswordTokenService.new(email: user.email).call
    open_email(user.email)
    current_email.click_link 'Reset password'
  end

  scenario 'with valid passwords' do
    fill_in 'New Password', with: 'test1234'
    fill_in 'Confirm Password', with: 'test1234'
    click_button 'Save'

    expect(page).to have_content('Password has been updated successfully')
    expect(user.reload.authenticate('test1234')).to be true
    click_link 'Done'
  end

  scenario 'with blank passwords' do
    click_button 'Save'

    expect(page).to have_content('Please choose a password')
  end

  scenario 'with non-matching passwords' do
    fill_in 'New Password', with: 'test1234'
    fill_in 'Confirm Password', with: '4321test'
    click_button 'Save'

    expect(page).to have_content("doesn't match")
  end
end
