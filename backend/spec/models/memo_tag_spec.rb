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

RSpec.describe MemoTag do
  let(:memo) { create(:memo) }
  let(:tag) { create(:tag) }
  let(:memo_tag) { build(:memo_tag, memo:, tag:) }

  context '有効な属性の場合' do
    it '有効である' do
      expect(memo_tag).to be_valid
    end
  end

  context '重複するmemo_idとtag_idの組み合わせの場合' do
    before { memo_tag.save }

    it '無効である' do
      aggregate_failures do
        duplicate_memo_tag = build(:memo_tag, memo:, tag:)
        expect(duplicate_memo_tag).not_to be_valid
        expect(duplicate_memo_tag.errors[:memo_id]).to include('はすでに存在します')
      end
    end
  end

  context 'memoが存在しない場合' do
    let(:memo_tag) { build(:memo_tag, memo: nil) }

    it '無効である' do
      aggregate_failures do
        expect(memo_tag).not_to be_valid
        expect(memo_tag.errors[:memo]).to include('を入力してください')
      end
    end
  end

  context 'tagが存在しない場合' do
    let(:memo_tag) { build(:memo_tag, tag: nil) }

    it '無効である' do
      aggregate_failures do
        expect(memo_tag).not_to be_valid
        expect(memo_tag.errors[:tag]).to include('を入力してください')
      end
    end
  end
end
