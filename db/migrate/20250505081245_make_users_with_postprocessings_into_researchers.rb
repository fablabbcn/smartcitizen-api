class MakeUsersWithPostprocessingsIntoResearchers < ActiveRecord::Migration[6.1]
  def change
    execute %{
      UPDATE users
      SET role_mask = 2
      FROM devices
      INNER JOIN postprocessings on devices.id = postprocessings.device_id
      WHERE devices.owner_id = users.id AND postprocessings.id IS NOT NULL and users.role_mask = 0;
    }
  end
end
