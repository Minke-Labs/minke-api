Rails.application.routes.draw do
  namespace 'api' do
    namespace 'v1' do
      resources :referral_codes, only: [:create]
      resources :referrals, only: [:create, :show]
    end
  end
end
