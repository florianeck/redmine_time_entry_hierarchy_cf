FactoryBot.define do

  factory :project do
    name "my project"

    after(:create) do |prj, _|
      create(:time_entry_activity, project: prj, name: "activity for project #{prj.id}")
    end
  end

  factory :time_entry_activity do

  end

end