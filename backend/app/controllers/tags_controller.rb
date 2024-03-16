# frozen_string_literal: true

class TagsController < ApplicationController
  # POST /tags
  def create
    tag = Memo.find(params[:memo_id]).tags.new(tag_params)
    if tag.save
      head :no_content
    else
      render json: { errors: tag.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end
end
