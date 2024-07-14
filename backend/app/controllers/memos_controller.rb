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

    if memo.update(update_memo_params)
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

  def search
    if params[:keyword].present?
      q = Memo.ransack(title_or_content_cont: params[:keyword])
      memos = q.result
    else
      memos = Memo.order(id: 'DESC')
    end
    if params[:order].present?
      sort_direction = case params[:order]
                       when 'asc'
                         'ASC'
                       when 'desc'
                         'DESC'
                       else
                         'DESC'
                       end
      memos = Memo.order(updated_at: sort_direction)
    end
    render json: { memos: memos }, status: :ok
  end

  private

  def memo_params
    params.require(:memo).permit(:title, :content)
  end

  def update_memo_params
    params.require(:memo).permit(:content)
  end
end
