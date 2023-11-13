Rails.application.routes.draw do
  namespace 'api' do
    namespace 'v1' do
      resources :referral_codes, only: [:create]
      resources :referrals, only: [:create, :show]
      resources :rewards, only: [:index]
      resources :disabled_wallet, only: [:index]
      post '/rewards/claim', to: 'rewards#claim', as: 'rewards_claim'
    end
  end
end
