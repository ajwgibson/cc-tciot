FactoryBot.define do
  factory :settings do
  end

  factory :default_settings, parent: :settings do
    default_footfall_threshold_amber  {  50 }
    default_footfall_threshold_red    { 100 }
    default_battery_threshold_amber   {  50 }
    default_battery_threshold_red     {  30 }
  end
end
