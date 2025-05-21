module UserHelper
  def profile_picture_url(user)
    if user.profile_picture.attached?
      polymorphic_url(user.profile_picture, only_path: false)
    else
      ''
    end
  end

  def possessive(user, current_user, params={})
    third_person = params[:third_person]
    first_person = params[:first_person]
    capitalize = params[:capitalize]
    if !third_person && current_user && current_user == user
      pronoun = t(first_person ? :first_person_possessive : :second_person_possessive)
      capitalize ? pronoun.capitalize : pronoun
    else
      t :third_person_possessive, username: user.username
    end
  end
end
