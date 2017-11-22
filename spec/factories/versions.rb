FactoryBot.define do
  factory :version do
    version 1
    association :document
    size {Faker::Number.between(0,1)}
    user {document.created_by}
    current true
  end
end
