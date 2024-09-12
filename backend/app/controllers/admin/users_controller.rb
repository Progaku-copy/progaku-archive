# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    before_action :authorize_admin!, only: %i[create]

    def create
      user = User.new(user_params)
      if user.save
        head :no_content
      else
        render json: { message: user.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:account_name, :password, :password_confirmation)
    end

    def authorize_admin!
      render_forbidden_error('権限がありません') unless current_user.admin?
    end
  end
end
