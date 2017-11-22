FactoryBot.define do
  factory :document do
    name {Faker::File.file_name}
    association :created_by, factory: :user
    updated_by {created_by}
    transient do
      versions 1
    end

    after(:create) do |document, evaluator|
      evaluator.versions.times do |i|
        create(:version,version: i+1, document: document, current: i==(evaluator.versions-1))
      end
    end
  end
end
