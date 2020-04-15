class DeviceGroup < ApplicationRecord

  include Filterable

  has_paper_trail

  validates :name, presence: true, uniqueness: true

  scope :with_name, ->(value) { where('lower(name) like lower(?)', "%#{value}%")}
end
