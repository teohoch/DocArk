FactoryBot.define do
  factory :version do
    version 1
    association :document, version: 0
    user {document.created_by}
    current true
  end
end
