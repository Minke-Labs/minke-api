FactoryBot.define do
  factory(:api_user) do
    name { Faker::Internet.name }
    token { Faker::Internet.password }
  end
end