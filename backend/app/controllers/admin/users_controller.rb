# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    before_action :check_admin
    def create
      user = User.new(user_params)
      if user.save
        head :no_content
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:account_name, :password, :password_confirmation)
    end

    def check_admin
      render json: { message: '権限がありません' }, status: :forbidden unless current_user.admin?
    end
  end
end
