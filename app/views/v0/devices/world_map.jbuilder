json.cache! ["world_map"], expires_in: 1.minute do
    json.partial! 'devices/world_map_list'
end