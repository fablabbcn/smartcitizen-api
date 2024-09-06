class DatetimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    [:starts_at, :ends_at].each do |field|
      if value.is_a?(String)
        begin
          Date.iso8601(value)
        rescue Date::Error
          begin
            Time.iso8601(value)
          rescue ArgumentError
            record.errors.add(attribute, "is not a valid ISO8601 date or time")
          end
        end
      end
    end
  end
end
