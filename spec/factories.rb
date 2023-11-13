FactoryBot.define do
  factory :reward do
    uid { 'MyString' }
    referral
    claimed { false }
    claim_uid { 'MyString' }
    source { 'MyString' }
    points { 100 }
  end

  factory(:api_user) do
    name { Faker::Internet.name }
    token { Faker::Internet.password }
  end

  factory(:referral_code) do
    wallet { Eth::Address.new(Faker::Blockchain::Ethereum.address).checksummed }
    device_id { Faker::Internet.password.upcase }
    code { Faker::Internet.password.first(6).upcase }
  end

  factory(:referral) do
    referral_code
    wallet { Eth::Address.new(Faker::Blockchain::Ethereum.address).checksummed }
    device_id { Faker::Internet.password.upcase }
  end
end
