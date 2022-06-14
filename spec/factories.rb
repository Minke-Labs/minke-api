FactoryBot.define do
  factory(:api_user) do
    name { Faker::Internet.name }
    token { Faker::Internet.password }
  end

  factory(:referral_code) do
    wallet { Faker::Blockchain::Ethereum.address }
    device_id { Faker::Internet.password.upcase }
    code { Faker::Internet.password.first(6).upcase }
  end

  factory(:referral) do
    referral_code
    wallet { Faker::Blockchain::Ethereum.address }
    device_id { Faker::Internet.password.upcase }
  end
end