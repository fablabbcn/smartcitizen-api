module ApplicationHelper
  def flash_class(level)
    case level.to_sym
      when :success then "alert alert-success"
      when :error then "alert alert-danger"
      when :alert then "alert alert-danger"
      else "alert alert-primary"
    end
  end
end
