# module MonkeyPatching
#   def to_s
#     "%Y-%m-%dT%H:%M:%SZ"
#   end

#   def inspect
#     to_s
#   end

#   def inspect
#     "#{time.strftime('%a, %d %b %Y %H:%M:%S JOHN')} #{zone} #{formatted_offset}"
#   end
# end

# class Time
#   include MonkeyPatching
# end

# class DateTime
#   include MonkeyPatching
# end

# module ActiveSupport
#   class TimeWithZone

#     def inspect
#       "#{time.change(:usec => 0).strftime('%a, %d %b %Y %H:%M:%S')}"
#     end

#     def to_s
#       "#{time.change(:usec => 0).strftime('%Y-%m-%dT%H:%M:%SZ')}"
#     end

#     # def inspect
#     #   "#{time.strftime('%a, %d %b %Y %H:%M:%S JOHN')} #{zone} #{formatted_offset}"
#     # end
#   end
# end

# # Time::DATE_FORMATS[:default] = "%Y-%m-%dT%H:%M:%SZ"
# # DateTime::DATE_FORMATS[:default] = "%Y-%m-%dT%H:%M:%SZ"