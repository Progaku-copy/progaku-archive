# frozen_string_literal: true

class MemosController < ApplicationController
  # GET /memos
  def index
    memos = Memo.order(id: 'DESC')
    render json: { memos: memos }, status: :ok
  end

  # GET /memos/:id
  def show
    @memo = Memo.find(params[:id])
    @comments = @memo.comments.order(id: 'DESC')
    render 'show', status: :ok
  end

  # POST /memos
  def create
    @memo_form = MemoForm.new(create_params)

    if @memo_form.save
      head :no_content
    else
      render json: { errors: @memo_form.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /memos/:id
  def update
    memo = Memo.find(params[:id])
    @memo_form = MemoForm.new(update_params, memo: memo)

    if @memo_form.save
      head :no_content
    else
      render json: { errors: @memo_form.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /memos/:id
  def destroy
    memo = Memo.find(params[:id])
    memo.destroy
    head :no_content
  end

  private

  def create_params
    params.require(:memo_form).permit(:title, :content, tag_ids: [])
  end

  def update_params
    params.require(:memo_form).permit(:content, tag_ids: [])
  end
end
