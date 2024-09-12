class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  include ActionController::Cookies
  before_action :authenticate_user!

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    render json: { message: 'ログインしてください' }, status: :unauthorized unless current_user
  end

  def record_not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end
end
