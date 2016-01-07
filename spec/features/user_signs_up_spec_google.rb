require 'spec_helper'
require 'rails_helper'
require_relative '../support/feature_test_helper'

RSpec.describe "User Signs Up", type: :feature do
  before do
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google]
  end

  scenario 'starts session' do
    authenticate_with_google

    expect(page).to have_content('Please fill out a few more details.')
  end

  scenario 'completing registration information' do
    authenticate_with_google
    fill_in_user_details

    expect(page).to have_content('Email confirmation sent')
  end

  scenario 'fill out registration information incorrectly' do
    authenticate_with_google
    fill_in "What's your phone number?", with: '5555555556'
    click_button 'Confirm Email'

    expect(page).to have_content("First name can't be blank")
  end

  scenario 'confirming registration with email' do
    authenticate_with_google
    fill_in_user_details

    confirmation_token = User.last.confirm_token
    confirm_url =
      "http://localhost:3000/users/#{confirmation_token}/confirm_email"
    expect(open_last_email).to have_body_text(confirm_url)

    visit confirm_url
    expect(page).to have_content('Find A Host')
  end

  scenario 'register, sign out, sign back in' do
    register_new_user
    click_link 'Sign Out'
    click_link 'Google'

    expect(page).to have_content('Find A Host')
  end

  scenario 'google fails' do
    OmniAuth.config.mock_auth[:google] = :invalid_credentials

    authenticate_with_google

    expect(page).to have_content('Sign In')
  end
end