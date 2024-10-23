module Ui
  class SessionsController < ApplicationController
    include SharedControllerMethods
    require 'uri'
    require 'net/http'
    require 'net/https'

    def new
      redirect_to users_url if current_user
    end

    def index
      # If you click 'Sign in to your account' and it fails with a
      # 'Email or password invalid' and you then refresh the page
      # it would end here with a rails error
      redirect_to '/'
  end

  def create
    if params[:send_password_email]
      logger.warn '---- send_password_email'
      reset_password_email
      redirect_to new_ui_session_path
      return
    end

    if params[:change_password]
      logger.warn '---- change_password'
      change_password
      #redirect_to '/'
      #return
    end

    logger.warn '---- Create - normal login'
    user = User.where("lower(email) = lower(?) OR lower(username) = lower(?)",
                      params[:username_or_email], params[:username_or_email]).first
    if user && user.authenticate_with_legacy_support(params[:password])
      logger.warn '---- with_legacy'
      session[:user_id] = user.id

      # If we came from Discourse (with the goto param), redirect to /discourse/sso
      if params[:goto].include? 'discourse'
        redirect_to session[:discourse_url]
      else
        logger.warn '---- without discourse'
        redirect_to (session[:user_return_to] || ui_users_path), notice: "You have been successfully logged in!"
      end
    else
      flash.now.alert = "Email or password is invalid"
      render "new"
    end
  end

  def reset_password_email
    uri = URI.parse("https://api.smartcitizen.me/v0/password_resets")
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true

    req = Net::HTTP::Post.new(uri.path)
    req.body = URI.encode_www_form({:email_or_username => params[:username_or_email] })
    res = https.request(req)
    jsonres = JSON.parse( res.body )

    flash[:alert] = jsonres["message"]

    if flash[:alert].include? "Delivered"
      flash[:notice] = 'Please check your email to reset the password.'
    else
      flash[:notice] = 'Is your username / email correct?'
    end

  end

  def password_reset_landing
    # Landing page from the email
    logger.warn '---- password_reset (landing page from email)'
    token = params[:token]
    logger.warn @token
  end

  def change_password
    logger.warn '---- Send PATCH request with token + password'
    logger.warn params[:token]

    #curl -XPATCH "https://api.smartcitizen.me/v0/password_resets/kP3LH5G7J6k9rqjVmGwYOA?password=12341234"
    uri = URI.parse("https://api.smartcitizen.me/v0/password_resets/#{params[:token]}")
      https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true

    req = Net::HTTP::Patch.new(uri.path)
    req.body = URI.encode_www_form({:password => params[:password] })
    res = https.request(req)
    jsonres = JSON.parse( res.body )

    logger.warn jsonres

    if jsonres["message"]
      flash[:alert] = jsonres["message"]
      if flash[:alert].include? "Could"
        flash[:notice] = 'Your reset code might be too old or have been used before.'
      end
    end

    if jsonres["username"]
      flash[:notice] = 'Changed password for: '
      flash[:alert] = jsonres["username"]
    end

    redirect_to new_ui_session_path

  end

  def destroy
    session[:user_id] = nil
    redirect_to login_url, notice: "Logged out!"
  end

end
end
