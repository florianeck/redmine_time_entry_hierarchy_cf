FactoryBot.define do

  factory :time_entry do
    hours { 1 }
    activity_id { 1 }
    user_id { 1 }
    spent_on { Time.now.to_date }
  end

end