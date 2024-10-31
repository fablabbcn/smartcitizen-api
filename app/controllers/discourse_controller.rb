class DiscourseController < ApplicationController
  include SharedControllerMethods

  DISCOURSE_SSO_SECRET = ENV.fetch("discourse_sso_secret")
  DISCOURSE_ENDPOINT = ENV.fetch("discourse_endpoint")
  def sso
    if !current_user
      session[:discourse_url] = request.url
      redirect_to new_ui_session_path(goto: request.path), notice: I18n.t(:login_before_sso_notice)
      return
    end
    secret = DISCOURSE_SSO_SECRET
    sso = SingleSignOn.parse(request.query_string, secret)
    sso.email = current_user.email # from devise
    #sso.name = current_user.full_name # this is a custom method on the User class
    sso.username = current_user.email # from devise
    #sso.username = current_user.username
    sso.external_id = current_user.id # from devise
    sso.sso_secret = secret

    redirect_to sso.to_url("#{DISCOURSE_ENDPOINT}session/sso_login")
  rescue => e
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace)
    #flash[:error] = 'SSO error'
    render inline: "Error, check logs"

    #redirect_to "/"
    #redirect_to root
  end

end
