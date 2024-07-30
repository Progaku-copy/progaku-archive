# frozen_string_literal: true

class CommentsController < ApplicationController
  # POST /memos/:memo_id/comments
  def create
    memo = Memo.find(params[:memo_id])
    comment = memo.comments.build(comment_params)
    if comment.save
      head :no_content
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    memo = Memo.find(params[:memo_id])
    comment = memo.comments.find(params[:id])
    comment.destroy
    head :no_content
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
