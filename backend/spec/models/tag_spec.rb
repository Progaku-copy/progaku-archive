# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id                   :bigint           not null, primary key
#  name(タグ名)         :string(30)       not null
#  priority(タグの順番) :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_tags_on_name      (name) UNIQUE
#  index_tags_on_priority  (priority)
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

      it '無効な状態であり、エラーメッセージが「タグ名を入力してください」となっていること' do
        expect(tag).not_to be_valid
        expect(tag.errors.full_messages).to eq ['タグ名を入力してください']
      end
    end

    context 'タグ名が31文字以上の場合' do
      let(:tag) { build(:tag, name: 'a' * 31) }

      it '無効な状態であり、エラーメッセージが「タグ名は30文字以内で入力してください」となっていること' do
        expect(tag).not_to be_valid
        expect(tag.errors.full_messages).to eq ['タグ名は30文字以内で入力してください']
      end
    end

    context 'タグ名が重複している場合' do
      let(:tag) { create(:tag) }
      let(:duplicate_tag) { build(:tag, name: tag.name) }

      it '無効な状態であり、エラーメッセージが「タグ名はすでに存在します」となっていること' do
        expect(duplicate_tag).not_to be_valid
        expect(duplicate_tag.errors.full_messages).to eq ['タグ名はすでに存在します']
      end
    end

    context 'タグの順番がない場合' do
      let(:tag) { build(:tag, priority: nil) }

      it '無効な状態であり、エラーメッセージが「タグの順番を入力してください」となっていること' do
        expect(tag).not_to be_valid
        expect(tag.errors.full_messages).to eq ['タグの順番を入力してください']
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
