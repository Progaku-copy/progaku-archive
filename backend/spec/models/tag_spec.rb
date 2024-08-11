# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

RSpec.describe Tag do
  describe 'バリデーション' do
    context 'タグ名がある場合' do
      let(:tag) { build(:tag) }

      it '有効な状態であること' do
        expect(tag).to be_valid
      end
    end

    context 'タグ名が空文字の場合' do
      let(:tag) { build(:tag, name: '') }

      it '無効な状態であること' do
        expect(tag).not_to be_valid
      end

      it 'エラーメッセージが「タグ名を入力してください」となっていること' do
        tag.valid?
        expect(tag.errors.full_messages).to eq ['タグ名を入力してください']
      end
    end
  end

  describe 'アソシエーションのテスト' do
    it 'Memoモデルとの関連がhas_manyであること' do
      tag = described_class.reflect_on_association(:memos)
      expect(tag.macro).to eq :has_many
    end

    it 'MemoTagモデルを介していること' do
      tag = described_class.reflect_on_association(:memos)
      expect(tag.through_reflection.name).to eq :memo_tags
    end
  end
end
