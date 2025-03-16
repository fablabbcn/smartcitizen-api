module ApplicationHelper
  def show_svg(path)
    File.open("app/assets/images/#{path}", "rb") do |file|
      raw file.read
    end
  end
  def flash_class(level)
    case level.to_sym
      when :success then "alert alert-success"
      when :error then "alert alert-danger"
      when :alert then "alert alert-danger"
      else "alert alert-primary"
    end
  end


  def sc_nav_button_to(legend, path, opts={})
    button_class = opts[:dark_buttons] ? "btn-dark" : "btn-secondary"
    button_class << " btn-active" if current_page?(path)
    link_to(legend, path, class: "btn #{button_class} me-md-2 mb-3 w-100 w-md-auto")
  end
end
