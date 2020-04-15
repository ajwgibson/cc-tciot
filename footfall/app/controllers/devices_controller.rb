# frozen_string_literal: true

class DevicesController < ApplicationController
  load_and_authorize_resource

  def index
    @filter = get_filter
    @title = 'Devices'
    @devices = Device.filter(@filter).order(:device_id)
    @devices = @devices.page(params[:page])
    set_filter @filter
  end

  def clear_filter
    set_filter nil
    redirect_to devices_path
  end

  def show
    @title = 'Device details'
  end

  def new
    @device = Device.new
    @title = 'New device'
    @cancel_path = devices_path
    render :edit
  end

  def create
    @device = Device.new device_params
    if @device.save
      redirect_to(device_path(@device), notice: 'Device was created successfully')
    else
      @title       = 'New device'
      @cancel_path = devices_path
      render :edit
    end
  end

  def edit
    @title = 'Edit device details'
    @cancel_path = device_path(@device)
  end

  def update
    if @device.update device_params
      redirect_to device_path(@device), notice: 'Device was updated successfully'
    else
      @title       = 'Edit device details'
      @cancel_path = device_path(@device)
      render :edit
    end
  end

  def destroy
    @device.destroy
    redirect_to devices_path, notice: 'Device was deleted'
  end

  private

  def device_params
    params
      .require(:device)
      .permit(
        :device_id,
        :latitude,
        :longitude,
        :footfall_threshold_red,
        :footfall_threshold_amber,
        :battery_threshold_red,
        :battery_threshold_amber,
        :notes
      )
  end

  def get_filter
    filter =
      params
      .permit(
        :order_by,
        :with_device_id
      ).to_h
    filter = session[:filter_devices].symbolize_keys! if filter.empty? && session.key?(:filter_devices)
    filter[:order_by] = 'device_id' unless filter.key?(:order_by)
    filter.delete_if { |_key, value| value.blank? }
  end

  def set_filter(filter)
    session[:filter_devices] = filter unless filter.nil?
    session.delete(:filter_devices) if filter.nil?
  end
end