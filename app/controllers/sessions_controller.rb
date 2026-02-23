class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create, :failure]

  def new
  end

  def create
    auth = request.env["omniauth.auth"]
    email = auth.info.email

    unless email.downcase == AppConfig.authorized_email&.downcase
      redirect_to login_path, alert: "Unauthorized account."
      return
    end

    user = User.find_or_create_by!(google_uid: auth.uid) do |u|
      u.email = email
      u.name = auth.info.name
    end
    user.update!(email: email, name: auth.info.name)

    session[:user_id] = user.id
    redirect_to session.delete(:return_to) || root_path, notice: "Signed in successfully."
  end

  def failure
    redirect_to login_path, alert: "Authentication failed: #{params[:message]}"
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Signed out."
  end
end
