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

  # PUT /memos/:memo_id/comments/:id
  def update
    comment = Comment.find_by!(id: params[:id], memo_id: params[:memo_id])
    if comment.update(comment_params)
      head :no_content
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
