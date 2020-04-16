require 'rails_helper'

RSpec.describe Settings, type: :model do
  it 'has a valid factory' do
    expect(
      FactoryBot.build(:default_settings)
    ).to be_valid
  end

  # VALIDATION
  describe 'A valid record' do
    it 'has a default_footfall_threshold_amber value' do
      expect(
        FactoryBot.build(:default_settings, default_footfall_threshold_amber: nil)
      ).not_to be_valid
    end

    it 'has a default_footfall_threshold_amber value between 1 and 65,535' do
      expect(
        FactoryBot.build(:default_settings, default_footfall_threshold_amber:     0)
      ).not_to be_valid
      expect(
        FactoryBot.build(:default_settings, default_footfall_threshold_amber:     1)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_footfall_threshold_amber: 65535)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_footfall_threshold_amber: 65536)
      ).not_to be_valid
    end

    it 'has a default_footfall_threshold_red value' do
      expect(
        FactoryBot.build(:default_settings, default_footfall_threshold_red: nil)
      ).not_to be_valid
    end

    it 'has a default_footfall_threshold_red value between 1 and 65,535' do
      expect(
        FactoryBot.build(:default_settings, default_footfall_threshold_red:     0)
      ).not_to be_valid
      expect(
        FactoryBot.build(:default_settings, default_footfall_threshold_red:     1)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_footfall_threshold_red: 65535)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_footfall_threshold_red: 65536)
      ).not_to be_valid
    end

    it 'has a default_battery_threshold_amber value' do
      expect(
        FactoryBot.build(:default_settings, default_battery_threshold_amber: nil)
      ).not_to be_valid
    end

    it 'has a default_battery_threshold_amber value between 1 and 99' do
      expect(
        FactoryBot.build(:default_settings, default_battery_threshold_amber:   0)
      ).not_to be_valid
      expect(
        FactoryBot.build(:default_settings, default_battery_threshold_amber:   1)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_battery_threshold_amber:  99)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_battery_threshold_amber: 100)
      ).not_to be_valid
    end

    it 'has a default_battery_threshold_red value' do
      expect(
        FactoryBot.build(:default_settings, default_battery_threshold_red: nil)
      ).not_to be_valid
    end

    it 'has a default_battery_threshold_red value between 1 and 99' do
      expect(
        FactoryBot.build(:default_settings, default_battery_threshold_red:   0)
      ).not_to be_valid
      expect(
        FactoryBot.build(:default_settings, default_battery_threshold_red:   1)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_battery_threshold_red:  99)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_battery_threshold_red: 100)
      ).not_to be_valid
    end
  end

  # METHODS

  describe 'self.current' do
    context 'with at least one database entry' do
      before do
        @a = FactoryBot.create(:default_settings)
        @b = FactoryBot.create(:default_settings)
      end
      it 'returns the most recent settings' do
        expect(Settings.current).to eq(@b)
      end
    end
    context 'with no database entry' do
      it 'returns default settings' do
        expect(Settings.current.id).to be_nil
      end
    end
  end

end
