# frozen_string_literal: true

# == Schema Information
#
# Table name: memos
#
#  id                    :bigint           not null, primary key
#  content(メモの本文)   :text(65535)      not null
#  title(メモのタイトル) :string(255)      not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
RSpec.describe Memo do
  subject(:memo) { build(:memo) }

  describe 'バリデーションのテスト' do
    context 'title と content が有効な場合' do
      it 'valid?メソッドがtrueを返すこと' do
        expect(memo).to be_valid
      end
    end

    context 'titleが空文字の場合' do
      before { memo.title = '' }

      it 'valid?メソッドがfalseを返すこと' do
        expect(memo).not_to be_valid
      end

      it 'errorsに「タイトルを入力してください」と格納されること' do
        memo.valid?
        expect(memo.errors.full_messages).to eq ['タイトルを入力してください']
      end
    end

    context 'titleがnilの場合' do
      before { memo.title = nil }

      it 'valid?メソッドがfalseを返すこと' do
        expect(memo).not_to be_valid
      end

      it 'errorsに「タイトルを入力してください」と格納されること' do
        memo.valid?
        expect(memo.errors.full_messages).to eq ['タイトルを入力してください']
      end
    end

    context 'contentが空文字の場合' do
      before { memo.content = '' }

      it 'valid?メソッドがfalseを返すこと' do
        expect(memo).not_to be_valid
      end

      it 'errorsに「コンテンツを入力してください」と格納されること' do
        memo.valid?
        expect(memo.errors.full_messages).to eq ['コンテンツを入力してください']
      end
    end

    context 'contentがnilの場合' do
      before { memo.content = nil }

      it 'valid?メソッドがfalseを返すこと' do
        expect(memo).not_to be_valid
      end

      it 'errorsに「コンテンツを入力してください」と格納されること' do
        memo.valid?
        expect(memo.errors.full_messages).to eq ['コンテンツを入力してください']
      end
    end
  end

  describe 'アソシエーションのテスト' do
    context 'Commentモデルとの関係' do
      it '1:Nとなっている' do
        association = described_class.reflect_on_association(:comments)
        expect(association.macro).to eq(:has_many)
      end
    end
  end

  describe '検索機能のテスト' do
    let!(:searchable_memo_one) { described_class.create(title: 'テスト タイトル１', content: 'テスト コンテンツ１') }
    let!(:searchable_memo_two) { described_class.create(title: 'テスト タイトル２', content: 'テスト コンテンツ２') }
    let!(:non_searchable_memo) { described_class.create(title: 'その他 タイトル', content: 'その他 コンテンツ') }

    context 'タイトルで検索した場合' do
      it 'タイトルフィルターが正しく機能し、期待されるメモが取得できることを確認する' do
        aggregate_failures do
          result = Memo::SearchResolver.resolve(memos: described_class.all, params: { title: 'テスト' })
          expect(result).to include(searchable_memo_one, searchable_memo_two)
          expect(result).not_to include(non_searchable_memo)
        end
      end
    end

    context 'コンテンツで検索した場合' do
      it 'コンテンツフィルターが正しく機能し、期待されるメモが取得できることを確認する' do
        aggregate_failures do
          result = Memo::SearchResolver.resolve(memos: described_class.all, params: { content: 'コンテンツ' })
          expect(result).to include(searchable_memo_one, searchable_memo_two, non_searchable_memo)
        end
      end
    end

    context 'タイトルとコンテンツで検索した場合' do
      it 'タイトルとコンテンツの両方でフィルターが正しく機能し、期待されるメモが取得できることを確認する' do
        aggregate_failures do
          result = Memo::SearchResolver.resolve(memos: described_class.all, params: { title: 'その他', content: 'コンテンツ' })
          expect(result).to include(non_searchable_memo)
          expect(result).not_to include(searchable_memo_one, searchable_memo_two)
        end
      end
    end

    context '並び替え機能のテスト' do
      it '昇順機能が正しく機能していること' do
        aggregate_failures do
          result = Memo::SearchResolver.resolve(memos: described_class.all, params: { order: 'asc' })
          expect(result).to eq([searchable_memo_one, searchable_memo_two, non_searchable_memo])
        end
      end

      it 'デフォルトで降順機能が正しく機能されていること' do
        aggregate_failures do
          result = Memo::SearchResolver.resolve(memos: described_class.all, params: {})
          expect(result).to eq([non_searchable_memo, searchable_memo_two, searchable_memo_one])
        end
      end
    end
  end
end
