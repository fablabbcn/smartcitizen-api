module UserHelper
  def profile_picture_url(user)
    if user.profile_picture.attached?
      polymorphic_url(user.profile_picture, only_path: false)
    else
      ''
    end
  end
end