# frozen_string_literal: true

class MemosController < ApplicationController
  # GET /memos
  def index
    @memos = \
      Memo::Query.call(
        filter_collection: Memo.preload(:tags).joins(:poster),
        params: params
      )
  rescue TypeError
    render json: { error: 'ページパラメータが無効です' }, status: :bad_request
  end

  # GET /memos/:id
  def show
    @memo = Memo.preload(:tags).joins(:poster).find(params[:id])
    @comments = @memo.comments.joins(:poster).order(id: :desc)
  end

  # POST /memos
  def create
    form = Memo::BuildForm.new(params: memo_params)

    if form.save
      head :no_content
    else
      render json: { errors: form.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /memos/:id
  def update
    form = Memo::UpdateForm.new(params: memo_params, id: params[:id])

    if form.save
      head :no_content
    else
      render json: { errors: form.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /memos/:id
  def destroy
    memo = Memo.find(params[:id])
    memo.destroy
    head :no_content
  end

  private

  def memo_params
    params.require(:memo).permit(:title, :content, :poster_user_key, tag_ids: [])
  end
end
