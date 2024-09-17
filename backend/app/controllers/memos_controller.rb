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
    memo = Memo.new(memo_params)
    if memo.save
      head :no_content
    else
      render json: { errors: memo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /memos/:id
  def update
    memo = Memo.find(params[:id])

    if memo.update(memo_params)
      head :no_content
    else
      render json: { errors: memo.errors.full_messages }, status: :unprocessable_entity
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
    params.require(:memo).permit(:title, :content, :poster)
  end
end
