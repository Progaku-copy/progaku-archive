# frozen_string_literal: true

# == Schema Information
#
# Table name: memo_tags
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  memo_id    :bigint           not null
#  tag_id     :bigint           not null
#
# Indexes
#
#  index_memo_tags_on_memo_id             (memo_id)
#  index_memo_tags_on_memo_id_and_tag_id  (memo_id,tag_id) UNIQUE
#  index_memo_tags_on_tag_id              (tag_id)
#
# Foreign Keys
#
#  fk_memo_tags_memo_id  (memo_id => memos.id)
#  fk_memo_tags_tag_id   (tag_id => tags.id)
#
class MemoTag < ApplicationRecord
  belongs_to :memo
  belongs_to :tag

  validates :memo_id, uniqueness: { scope: :tag_id }

  def self.build_tags_for_post(channel_data)
    channel_data.each do |channel|
      # アーカイブされた投稿を抽出
      archived_posts = channel[:posts]['messages'].select do |post|
        post[:reactions]&.any? { |reaction| reaction['name'] == 'アーカイブ' }
      end

      # アーカイブされた投稿のts を抽出
      ts_values = archived_posts.pluck(:ts)

      # ts をKeyに posts の id を取得
      memo_ids = Memo.where(ts: ts_values).pluck(:id)

      # memo_tags 用のインスタンスを作成
      memo_ids.map do |memo_id|
        MemoTag.new(
          memo_id: memo_id,
          tag_id: channel[:tag_id]
        )
      end
    end
  end
end
