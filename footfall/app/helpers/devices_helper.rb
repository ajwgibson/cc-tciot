# frozen_string_literal: true

module DevicesHelper
  def device_battery_status(device)
    return '' unless device.battery.present?

    style = 'text-green'
    battery = 'fa-battery-full'

    if device.battery_amber?
      style = 'text-warning'
      battery = 'fa-battery-half'
    end

    if device.battery_red?
      style = 'text-danger'
      battery = 'fa-battery-empty'
    end

    content_tag(:span, class: [style]) do
      content_tag(:i, ' ', class: ['fas', battery]) +
      " #{device.battery}%"
    end
  end

  def device_footfall_status(device)
    return '' unless device.footfall.present?

    style = 'text-green'
    style = 'text-warning' if device.footfall_amber?
    style = 'text-danger' if device.footfall_red?

    content_tag(:span, class: [style]) do
      content_tag(:i, ' ', class: ['fas', 'fa-shoe-prints']) +
      " #{device.footfall}"
    end
  end

  def device_map_icon_url(device)
    if device.footfall_red? || device.battery_red?
      return "http://maps.google.com/mapfiles/ms/icons/red-dot.png"
    end

    if device.footfall_amber? || device.battery_amber?
      return "http://maps.google.com/mapfiles/ms/icons/orange-dot.png"
    end

    if device.footfall_green? || device.battery_green?
      return "http://maps.google.com/mapfiles/ms/icons/green-dot.png";
    end

    return "http://maps.google.com/mapfiles/ms/icons/purple-dot.png";
  end
end
