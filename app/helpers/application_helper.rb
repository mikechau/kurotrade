module ApplicationHelper
  def flash_class(level)
    case level
    when :notice then "alert alert-info"
    when :success then "alert alert-success"
    when :error then "alert alert-error"
    when :alert then "alert alert-error"
    end
  end

  def current_user
    @user ||= User.find_by_id(session[:user_id]) if logged_in?
  end
  
  def logged_in?
    session[:user_id]
  end

end
