json.array! Device.for_world_map(never_authorized ? nil : current_user), partial: 'world_map_device', as: :device, local_assigns: { never_authorized: never_authorized }
