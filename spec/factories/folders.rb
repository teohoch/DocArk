FactoryBot.define do
  factory :folder do


    name {Faker::Pokemon.name}
    association :created_by, factory: :user
    updated_by {created_by}

    trait :is_deep do
      transient do
        ancestors 0
      end
      before(:create) do |folder, evaluator|
        puts folder.name
        unless evaluator.ancestors == 0
          folder.parent_folder = create(:folder, :is_deep, ancestors: (evaluator.ancestors - 1))
        end
      end
    end
    trait :has_children do
      transient do
        family_tree []
      end
      after(:create) do |folder, evaluator|
        evaluator.family_tree.each do |branch|
          if branch[:type] == 1
            branch[:contents] ||= []
            if branch.has_key? :name
              create(:folder, :has_children, name: branch[:name], family_tree: branch[:contents], parent_folder: folder, created_by: folder.created_by)
            else
              create(:folder, :has_children, family_tree: branch[:contents], parent_folder: folder, created_by: folder.created_by)
            end
          else
            if branch.has_key? :name
              create(:file, name: branch[:name], parent_folder: folder, created_by: folder.created_by)
            else
              create(:file, parent_folder: folder, created_by: folder.created_by)
            end
          end
        end
      end
    end
  end
end
