require 'rails_helper'

describe 'account creation' do
  let(:subdomain) { FactoryGirl.generate(:subdomain) }
  before(:each) { sign_up(subdomain) }

  it 'allows user to create account' do
    expect(page.current_url).to include(subdomain)
    expect(Account.all.count).to eq(1)
  end

  it 'allows access of subdomain' do
    visit root_url(subdomain: subdomain)
    expect(page.current_url).to include(subdomain)
  end

  it 'allows account followup creation' do
    subdomain2 = "#{subdomain}2"
    sign_up(subdomain2)
    expect(page.current_url).to include(subdomain2)
    expect(Account.all.count).to eq(2)
  end

  it 'does not allow account creation on subdomain' do
    user = create(:user)
    subdomain = Account.first.subdomain
    sign_user_in(user, subdomain: subdomain)
    expect { visit new_account_url(subdomain: subdomain) }.to raise_error ActionController::RoutingError
  end

  describe 'confirmation email' do
    before do
      open_email 'birhanu@example.com'
      expect(current_email).to have_body_text("You can confirm your account email through the link below:")
    end

    context 'when clicking confirmation link in email' do
      before :each do
        visit_in_email 'Confirm my account'
      end

      it "shows confirmation message" do
        expect(page).to have_content('Your account was successfully confirmed')
      end

      it "confirms user" do
        user = User.find_for_authentication(email: 'birhanu@example.com')
        expect(user).to be_confirmed
      end
    end
  end

  def sign_up(subdomain)
    visit root_url(subdomain: false)
    click_link 'Create Account'

    reset_mailer

    #binding.pry #inserts a breakpoint here
    fill_in 'First name', with: 'Birhanu'
    fill_in 'Second name', with: 'Hailemariam'
    fill_in 'Email', with: 'birhanu@example.com'
    within('.account_owner_password') do
      fill_in 'Password', with: 'pw'
    end
    fill_in 'Password confirmation', with: 'pw'
    fill_in 'Subdomain', with: subdomain
    click_button 'Create Account'

    expect(page).to have_text I18n.t('devise.registrations.signed_up_but_unconfirmed')
  end
end


