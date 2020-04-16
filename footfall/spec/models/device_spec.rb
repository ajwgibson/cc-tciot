require 'rails_helper'

RSpec.describe Device, type: :model do
  describe 'Device' do
    it 'has a valid default factory' do
      expect(FactoryBot.build(:default_device)).to be_valid
    end
  end

  # VALIDATION
  describe 'A valid device' do
    it 'has a device id' do
      expect(FactoryBot.build(:default_device, device_id: nil)).not_to be_valid
    end

    it 'has a unique id' do
      FactoryBot.create(:default_device, device_id: 'xxx')
      expect(FactoryBot.build(:default_device, device_id: 'xxx')).not_to be_valid
    end

    it 'has a footfall_threshold_amber value' do
      expect(FactoryBot.build(:default_device, footfall_threshold_amber: nil)).not_to be_valid
    end

    it 'has a footfall_threshold_amber value between 1 and 65,535' do
      expect(FactoryBot.build(:default_device, footfall_threshold_amber:     0)).not_to be_valid
      expect(FactoryBot.build(:default_device, footfall_threshold_amber:     1)).to     be_valid
      expect(FactoryBot.build(:default_device, footfall_threshold_amber: 65535)).to     be_valid
      expect(FactoryBot.build(:default_device, footfall_threshold_amber: 65536)).not_to be_valid
    end

    it 'has a footfall_threshold_red value' do
      expect(FactoryBot.build(:default_device, footfall_threshold_red: nil)).not_to be_valid
    end

    it 'has a footfall_threshold_red value between 1 and 65,535' do
      expect(FactoryBot.build(:default_device, footfall_threshold_red:     0)).not_to be_valid
      expect(FactoryBot.build(:default_device, footfall_threshold_red:     1)).to     be_valid
      expect(FactoryBot.build(:default_device, footfall_threshold_red: 65535)).to     be_valid
      expect(FactoryBot.build(:default_device, footfall_threshold_red: 65536)).not_to be_valid
    end

    it 'has a battery_threshold_amber value' do
      expect(FactoryBot.build(:default_device, battery_threshold_amber: nil)).not_to be_valid
    end

    it 'has a battery_threshold_amber value between 1 and 99' do
      expect(FactoryBot.build(:default_device, battery_threshold_amber:   0)).not_to be_valid
      expect(FactoryBot.build(:default_device, battery_threshold_amber:   1)).to     be_valid
      expect(FactoryBot.build(:default_device, battery_threshold_amber:  99)).to     be_valid
      expect(FactoryBot.build(:default_device, battery_threshold_amber: 100)).not_to be_valid
    end

    it 'has a battery_threshold_red value' do
      expect(FactoryBot.build(:default_device, battery_threshold_red: nil)).not_to be_valid
    end

    it 'has a battery_threshold_red value between 1 and 99' do
      expect(FactoryBot.build(:default_device, battery_threshold_red:   0)).not_to be_valid
      expect(FactoryBot.build(:default_device, battery_threshold_red:   1)).to     be_valid
      expect(FactoryBot.build(:default_device, battery_threshold_red:  99)).to     be_valid
      expect(FactoryBot.build(:default_device, battery_threshold_red: 100)).not_to be_valid
    end
  end

  # CALLBACKS
  describe '#before_save' do
    it 'swaps the battery_threshold_red and battery_threshold_amber values if necessary' do
      device = FactoryBot.create(
        :default_device,
        battery_threshold_red: 2,
        battery_threshold_amber: 1
      )
      device.reload
      expect(device.battery_threshold_red).to eq(1)
      expect(device.battery_threshold_amber).to eq(2)
    end

    it 'swaps the footfall_threshold_red and footfall_threshold_amber values if necessary' do
      device = FactoryBot.create(
        :default_device,
        footfall_threshold_red: 1,
        footfall_threshold_amber: 2
      )
      device.reload
      expect(device.footfall_threshold_red).to eq(2)
      expect(device.footfall_threshold_amber).to eq(1)
    end
  end

  # SCOPES
  describe 'scope:ordered_by_device_id' do
    before(:each) do
      @c = FactoryBot.create(:default_device, device_id: 'c')
      @a = FactoryBot.create(:default_device, device_id: 'a')
      @b = FactoryBot.create(:default_device, device_id: 'b')
    end
    it 'orders the records by device_id' do
      expect(Device.ordered_by_device_id).to eq([@a, @b, @c])
    end
  end

  describe 'scope:with_device_id' do
    before(:each) do
      @a = FactoryBot.create(:default_device, device_id: 'x')
      @b = FactoryBot.create(:default_device, device_id: 'y')
      @c = FactoryBot.create(:default_device, device_id: 'aXa')
    end
    it 'includes records where the device id contains the value regardless of case' do
      filtered = Device.with_device_id('x')
      expect(filtered).to     include(@a, @c)
      expect(filtered).not_to include(@b)
    end
  end

  describe 'scope:with_device_group_id' do
    let(:device_group) { FactoryBot.create(:default_device_group) }
    before(:each) do
      @a = FactoryBot.create(:default_device, device_group: nil)
      @b = FactoryBot.create(:default_device, device_group: device_group)
    end
    it 'includes records where the device belongs to the group' do
      filtered = Device.with_device_group_id(device_group.id)
      expect(filtered).to     include(@b)
      expect(filtered).not_to include(@a)
    end
  end

  # METHODS
  describe 'self.new_device' do
    before(:each) do
      FactoryBot.create(:default_settings)
    end
    it 'initializes a device using system settings for defaults' do
      device = Device.new_device
      settings = Settings.current
      expect(device.battery_threshold_red).to eq(settings.default_battery_threshold_red)
      expect(device.battery_threshold_amber).to eq(settings.default_battery_threshold_amber)
      expect(device.footfall_threshold_red).to eq(settings.default_footfall_threshold_red)
      expect(device.footfall_threshold_amber).to eq(settings.default_footfall_threshold_amber)
    end
  end

  describe '#location_as_string' do
    it 'returns latitude and longitude' do
      device = FactoryBot.build(:default_device, latitude: 1.23, longitude: -9.87)
      expect(device.location_as_string).to eq('1.23, -9.87')
    end
    it 'returns nil if latitude is nil' do
      device = FactoryBot.build(:default_device, latitude: nil, longitude: -9.87)
      expect(device.location_as_string).to be_nil
    end
    it 'returns nil if longitude is nil' do
      device = FactoryBot.build(:default_device, latitude: 1.23, longitude: nil)
      expect(device.location_as_string).to be_nil
    end
  end
end
