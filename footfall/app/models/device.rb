class Device < ApplicationRecord

  include Filterable

  has_paper_trail

  belongs_to :device_group, optional: true

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
  scope :ordered_by_device_id, -> { order(:device_id) }
  scope :with_device_id, ->(value) { where('lower(device_id) like lower(?)', "%#{value}%")}
  scope :with_device_group_id, ->(value) { where(device_group_id: value) }

  # METHODS
  def self.new_device
    settings = Settings.current
    Device.new(
      battery_threshold_red:    settings.default_battery_threshold_red,
      battery_threshold_amber:  settings.default_battery_threshold_amber,
      footfall_threshold_red:   settings.default_footfall_threshold_red,
      footfall_threshold_amber: settings.default_footfall_threshold_amber
    )
  end

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
