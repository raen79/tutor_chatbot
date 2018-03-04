class ApplicationController < ActionController::API
  def current_user
    @current_user ||= User.find_by(:jwt => request.headers['Authorization'])
  end
end
