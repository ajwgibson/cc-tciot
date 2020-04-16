# frozen_string_literal: true

class SettingsController < ApplicationController
  authorize_resource :settings

  def show
    @title    = 'System settings'
    @settings = Settings.current
  end

  def edit
    @title    = 'Edit system settings'
    @settings = Settings.current
  end

  def update
    @settings = Settings.current
    @settings.assign_attributes settings_params
    if @settings.save
      redirect_to({ action: 'show' }, notice: 'System settings updated successfully')
    else
      @title = 'Edit system settings'
      render :edit
    end
  end

  private

  def settings_params
    params
      .require(:settings)
      .permit(
        :default_footfall_threshold_amber,
        :default_footfall_threshold_red,
        :default_battery_threshold_amber,
        :default_battery_threshold_red
      )
  end
end
