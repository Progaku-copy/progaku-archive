# frozen_string_literal: true

class TagsController < ApplicationController
  # GET /tags
  def index
    tags = Tag.all
    render json: tags.order(priority: :asc), only: [:id, :name, :priority], status: :ok
  end

  # POST /tags
  def create
    tag = Tag.new(tag_params)
    if tag.save
      head :no_content
    else
      render json: { errors: tag.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /tags/:id
  def update
    tag = Tag.find(params[:id])

    if tag.update(tag_params)
      head :no_content
    else
      render json: { errors: tag.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /tags/:id
  def destroy
    tag = Tag.find(params[:id])
    if tag.destroy
      head :no_content
    else
      render json: { errors: tag.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:name, :priority)
  end
end
