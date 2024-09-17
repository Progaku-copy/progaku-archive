class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  include ActionController::Cookies
  before_action :authenticate_user!

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def authenticate_user!
    render_unauthorized_error('ログインしてください') unless current_user
  end

  def record_not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def render_unauthorized_error(message)
    render json: { message: message }, status: :unauthorized
  end

  def render_forbidden_error(message)
    render json: { message: message }, status: :forbidden
  end
end
