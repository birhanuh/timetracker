require 'rails_helper'

describe 'accounts' do
  let!(:account) { create(:account_with_schema) }
  let(:user) { account.owner }

  before do    
    set_subdomain(account.subdomain)
    sign_user_in(user)
  end
 
  describe 'when account exists' do
    before(:each) do
      click_link('company-logo-link')     
    end
    it 'allows account to be edited' do
      click_link I18n.t('button.edit')       
      
      fill_in 'Industry', with: 'Lorem'
      fill_in 'Phone number', with: '12345678910'
      fill_in 'Email', with: 'test@test.com'

      within('.account_country') do 
        select_generic('Finland', from: 'account_country')
      end 

      submit_form
      expect(page).to have_text 'Lorem'
      expect(page).to have_text '12345678910'
      expect(page).to have_text 'FI'
    end  

    xit 'allows account to be deleted' do
      click_link I18n.t('button.delete')
      
      expect(page).to have_text I18n.t('invoices.destroy.confirmation_msg')     
     
      sleep 2
      
      within('.modal-footer') do 
        click_link I18n.t('button.delete')
      end 
        
      expect(page).to have_text I18n.t('invoices.destroy.success_delete')
      expect(page).to_not have_text @invoice.date_of_an_invoice
      expect(page).to_not have_text @invoice.customer     
    end  
  end  

end