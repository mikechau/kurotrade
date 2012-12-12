class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_username(params[:username])

    if user != nil && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to users_url, :flash => { :success => "kurotrade welcomes you #{user.name}!" } #change this
    else
      redirect_to login_url, :flash => { :error => "<b>Invalid login!</b> Please try again or #{view_context.link_to('register.', new_user_url)}".html_safe } #this is the login page
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_url, :flash => { :notice => "You are now logged out! Come back soon." }
  end
end
