# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[create]

  def create
    user = User.find_by(account_name: session_params[:account_name])
    if user&.authenticate(session_params[:password])
      session[:user_id] = user.id
      head :ok
    else
      render json: { message: 'アカウント名とパスワードの組み合わせが不正です' }, status: :unauthorized
    end
  end

  def destroy
    reset_session
    render json: { message: 'ログアウトしました' }, status: :ok
  end

  private

  def session_params
    params.require(:session).permit(:account_name, :password)
  end
end
