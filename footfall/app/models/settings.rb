class Settings < ApplicationRecord

  has_paper_trail

  validates :default_footfall_threshold_amber, numericality: {
    only_integer: true, greater_than: 0, less_than: 65536
  }

  validates :default_footfall_threshold_red, numericality: {
    only_integer: true, greater_than: 0, less_than: 65536
  }

  validates :default_battery_threshold_amber, numericality: {
    only_integer: true, greater_than: 0, less_than: 100
  }

  validates :default_battery_threshold_red, numericality: {
    only_integer: true, greater_than: 0, less_than: 100
  }

  def self.current
    Settings.last || Settings.new
  end

end
