module PresentationHelper
  def present(model, options={})
    Presenters.present(model, current_user, self, options)
  end
end
