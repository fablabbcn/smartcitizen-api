json.cache_if! !@no_cache, ["world_map"], expires_in: 1.minute do
    json.array! Device.for_world_map, partial: 'device', as: :device, local_assigns: { with_data: false, with_postprocessing: false, slim_owner: true, never_authorized: true }
end