# frozen_string_literal: true

class MemosController < ApplicationController
  # GET /memos
  def index
    render json: Memo::Query.call(filter_collection: Memo.all, params: params), status: :ok
  rescue TypeError
    render json: { error: 'ページパラメータが無効です' }, status: :bad_request
  end

  # GET /memos/:id
  def show
    @memo = Memo.find(params[:id])
    @comments = @memo.comments.order(id: 'DESC')
    render 'show', status: :ok
  end

  # POST /memos
  def create
    form = Memo::BuildForm.new(params: form_params)

    if form.save
      head :no_content
    else
      render json: { errors: form.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /memos/:id
  def update
    # memo = Memo.find(params[:id])
    form = Memo::UpdateForm.new(params: form_params, id: params[:id])

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

  def form_params
    params.require(:form).permit(:title, :content, :poster, tag_ids: [])
  end
end
