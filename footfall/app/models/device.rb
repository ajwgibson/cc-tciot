class Device < ApplicationRecord

  include Filterable

  has_paper_trail

  # CALLBACKS
  before_save :reorder_thresholds

  # VALIDATION
  validates :device_id, presence: true, uniqueness: true

  validates :footfall_threshold_amber, numericality: {
    only_integer: true, greater_than: 0, less_than: 65536
  }

  validates :footfall_threshold_red, numericality: {
    only_integer: true, greater_than: 0, less_than: 65536
  }

  validates :battery_threshold_amber, numericality: {
    only_integer: true, greater_than: 0, less_than: 100
  }

  validates :battery_threshold_red, numericality: {
    only_integer: true, greater_than: 0, less_than: 100
  }

  # SCOPES
  scope :with_device_id, ->(value) { where('lower(device_id) like lower(?)', "%#{value}%")}

  # METHODS
  def location_as_string
    "#{latitude}, #{longitude}" unless latitude.blank? || longitude.blank?
  end

  private

  def reorder_thresholds
    if self.battery_threshold_amber < self.battery_threshold_red
      self.battery_threshold_red, self.battery_threshold_amber =
        self.battery_threshold_amber, self.battery_threshold_red
    end

    if self.footfall_threshold_amber > self.footfall_threshold_red
      self.footfall_threshold_red, self.footfall_threshold_amber =
        self.footfall_threshold_amber, self.footfall_threshold_red
    end
  end

end
