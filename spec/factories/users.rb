FactoryBot.define do
  factory :user do
    first_name {Faker::Name.first_name}
    last_name {Faker::DrWho.specie}
    name {"#{first_name} #{last_name}"}
    email {Faker::Internet.email(first_name)}
    image 'https://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/photo.jpg'
    provider 'google_oauth2'
    uid {Faker::Number.number(21)}
  end
end