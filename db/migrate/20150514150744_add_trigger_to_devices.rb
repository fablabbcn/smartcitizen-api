class AddTriggerToDevices < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE FUNCTION replace_old_data() RETURNS trigger AS $$
      BEGIN
          NEW.old_data := OLD.data;
          RETURN NEW;
      END;
      $$ language plpgsql;

      CREATE TRIGGER old_data_trigger
        BEFORE UPDATE
        ON devices
        FOR EACH ROW
        EXECUTE PROCEDURE replace_old_data();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER old_data_trigger ON devices;
      DROP FUNCTION replace_old_data();
    SQL
  end
end
