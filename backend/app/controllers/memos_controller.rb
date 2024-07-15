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
    if params[:keyword].present? # keywordが存在している時
      q = Memo.ransack(title_or_content_cont: params[:keyword]) # keywordを含む情報をtitleまたはcontentから取得
      memos = q.result # その検索結果をmemosに代入
    else # もし「keyword」が入力されていなかったら
      memos = Memo.order(id: 'DESC') # 全てのメモを新しい順(降順)で並べてmemosに入れます
    end
    if params[:order].present? # order（並び替えのルール）が存在している時
      sort_direction = case params[:order] # 以下のケースをsort_directionに代入
                       when 'asc' # params[asc]の場合
                         'ASC' # 昇順 DBと対話するため大文字にしている
                       when 'desc' # params[desc]の場合
                         'DESC' # 降順 DBと対話するため大文字にしている
                       else # paramsに何も入っていない時
                         'DESC' # 降順 DBと対話するため大文字にしている
                       end
      memos = Memo.order(updated_at: sort_direction) # メモが最後に更新された時間で上記の順番で並び替える
    end
    render json: { memos: memos }, status: :ok # 最後に見つかったメモをJSONという形で表示します。status: :ok は「ちゃんと動きましたよ」という意味

  end

  private

  def memo_params
    params.require(:memo).permit(:title, :content)
  end

  def update_memo_params
    params.require(:memo).permit(:content)
  end
end
