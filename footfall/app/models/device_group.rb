class DeviceGroup < ApplicationRecord

  include Filterable

  has_paper_trail

  has_many :devices, dependent: :nullify

  validates :name, presence: true, uniqueness: true

  scope :ordered_by_name, -> { order(:name) }
  scope :with_name, ->(value) { where('lower(name) like lower(?)', "%#{value}%")}

  def device_count
    devices.count
  end
end
