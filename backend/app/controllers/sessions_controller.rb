# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate_user!
  def create
    user = User.find_by(account_name: session_params[:account_name])
    return render json: { errors: ['アカウント名が存在しません'] }, status: :unauthorized unless user

    unless user.authenticate(session_params[:password])
      return render json: { errors: ['パスワードが正しくありません'] },
                    status: :unauthorized
    end

    session[:user_id] = user.id
    render json: { message: 'ログインしました。' }, status: :ok
  end

  def destroy
    reset_session
    head :no_content
  end

  private

  def session_params
    params.require(:session).permit(:account_name, :password)
  end
end
