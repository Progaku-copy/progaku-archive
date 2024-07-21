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
    result_memos = fetch_memos # 検索結果をresult_memosに代入
    # order（並び替えのルール）が存在している時,下記の並び順を検索結果を引数とした並び変え実施しsorted_memosに代入
    sorted_memos = sort_memos(result_memos) if params[:order].present?
    # 最後に見つかったメモをJSONという形で表示します。status: :ok は「ちゃんと動きましたよ」という意味
    # 並べ替えが行われている場合はsorted_memos、そうでない場合はresult_memosをJSONレスポンスとして返します。
    render json: { memos: sorted_memos || result_memos }, status: :ok
  end

  private

  def fetch_memos
    if params[:keyword].present? # keywordが存在している時
      q = Memo.ransack(title_or_content_cont: params[:keyword]) # keywordを含む情報をtitleまたはcontentから取得
      q.result # その検索結果を取得
    else # もし「keyword」が入力されていなかったら
      Memo.order(id: 'DESC') # 全てのメモを新しい順(降順)で並べて取得
    end
  end

  def sort_memos(memos)
    sort_direction = 'DESC' # ﾃﾞﾌｫﾙﾄの並び替え方向を降順に設定
    sort_direction = 'ASC' if params[:order] == 'asc' # params[asc]の場合に昇順(DBと対話するため大文字）
    sort_direction = 'DESC' if params[:order] == 'desc' # params[desc]の場合に降順(DBと対話するため大文字）
    # Memosは存在しないｸﾗｽ名のためMemos.orderとするとｴﾗｰになってしまう
    # MemoはﾓﾃﾞﾙｸﾗｽのためMemo.orderとするとMemoﾓﾃﾞﾙ全体に対して並び替えしてしまう
    # searchﾒｿｯﾄﾞのsort_memos(result_memos)からmemosはfetch_memosﾒｿｯﾄﾞが返すﾒﾓのﾘｽﾄとなりmemos.orderが適切
    memos.order(updated_at: sort_direction) # メモが最後に更新された時間で上記の順番で並び替える
  end

  def memo_params
    params.require(:memo).permit(:title, :content)
  end

  def update_memo_params
    params.require(:memo).permit(:content)
  end
end
