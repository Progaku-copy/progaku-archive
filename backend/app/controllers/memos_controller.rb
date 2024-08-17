# frozen_string_literal: true

class MemosController < ApplicationController
  before_action :set_memo, only: %i[show update destroy]

  # GET /memos
  def index
    memos = Memo.order(id: 'DESC')
    render json: { memos: memos }, status: :ok
  end

  # GET /memos/:id
  def show
    @comments = @memo.comments.order(id: 'DESC')
    render 'show', status: :ok
  end

  # POST /memos
  def create
    @memo_form = MemoForm.new(memo_form_params)

    if @memo_form.save
      head :no_content
    else
      render json: { errors: @memo_form.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /memos/:id
  def update
    @memo_form = MemoForm.new(update_memo_form_params, memo: @memo)
    
    if @memo_form.save
      head :no_content
    else
      render json: { errors: @memo_form.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /memos/:id
  def destroy
    @memo.destroy
    head :no_content
  end

  private

  def set_memo
    @memo = Memo.find(params[:id])
  end

  def memo_form_params
    params.require(:memo_form).permit(:title, :content, tag_ids: [])
  end

  def update_memo_form_params
    params.require(:memo_form).permit(:content, tag_ids: [])
  end
end
