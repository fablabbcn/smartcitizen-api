json.devices do
  json.array! @devices, partial: 'device', as: :device
end
