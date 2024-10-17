# frozen_string_literal: true

# == Schema Information
#
# Table name: memos
#
#  id                        :bigint           not null, primary key
#  content(メモの本文)       :text(65535)      not null
#  poster(Slackのユーザー名) :string(50)       not null
#  title(メモのタイトル)     :string(255)      not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
RSpec.describe Memo do
  let(:memo) { build(:memo) }

  describe 'バリデーションのテスト' do
    context '属性が有効な場合' do
      it 'valid?メソッドがtrueを返すこと' do
        expect(memo).to be_valid
      end
    end

    context 'titleが空文字の場合' do
      before { memo.title = '' }

      it 'valid?メソッドがfalseを返し、エラーメッセージが格納される' do
        aggregate_failures do
          expect(memo).not_to be_valid
          expect(memo.errors.full_messages).to eq ['タイトルを入力してください']
        end
      end
    end

    context 'titleがnilの場合' do
      before { memo.title = nil }

      it 'valid?メソッドがfalseを返し、エラーメッセージが格納される' do
        aggregate_failures do
          expect(memo).not_to be_valid
          expect(memo.errors.full_messages).to eq ['タイトルを入力してください']
        end
      end
    end

    context 'contentが空文字の場合' do
      before { memo.content = '' }

      it 'valid?メソッドがfalseを返し、エラーメッセージが格納される' do
        aggregate_failures do
          expect(memo).not_to be_valid
          expect(memo.errors.full_messages).to eq ['コンテンツを入力してください']
        end
      end
    end

    context 'contentがnilの場合' do
      before { memo.content = nil }

      it 'valid?メソッドがfalseを返し、エラーメッセージが格納される' do
        aggregate_failures do
          expect(memo).not_to be_valid
          expect(memo.errors.full_messages).to eq ['コンテンツを入力してください']
        end
      end
    end

    context 'posterが空文字の場合' do
      before { memo.poster = '' }

      it 'valid?メソッドがfalseを返し、エラーメッセージが格納される' do
        aggregate_failures do
          memo.valid?
          expect(memo.errors.full_messages).to eq ['Slackでの投稿者名を入力してください']
        end
      end
    end

    context 'posterがnilの場合' do
      before { memo.poster = nil }

      it 'valid?メソッドがfalseを返し、エラーメッセージが格納される' do
        aggregate_failures do
          expect(memo).not_to be_valid
          expect(memo.errors.full_messages).to eq ['Slackでの投稿者名を入力してください']
        end
      end
    end

    context 'posterが50文字以上の場合' do
      before { memo.poster = 'a' * 51 }

      it 'valid?メソッドがfalseを返し、エラーメッセージが格納される' do
        aggregate_failures do
          expect(memo).not_to be_valid
          expect(memo.errors.full_messages).to eq ['Slackでの投稿者名は50文字以内で入力してください']
        end
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

  describe 'Query::call(filter_collection:, params:)' do
    let(:memos) do
      [
        create(:memo, title: 'テスト タイトル１', content: 'テスト コンテンツ１'),
        create(:memo, title: 'テスト タイトル２', content: 'テスト コンテンツ２'),
        create(:memo, title: 'その他 タイトル', content: 'その他 コンテンツ')
      ]
    end
    let(:firts_expected_memo) do
      {
        'id' => memos[0].id,
        'title' => memos[0].title,
        'content' => memos[0].content,
        'poster' => memos[0].poster,
        'created_at' => memos[0].created_at,
        'updated_at' => memos[0].updated_at,
        :tag_names => memos[0].tags.map(&:name)
      }
    end
    let(:second_expected_memo) do
      {
        'id' => memos[1].id,
        'title' => memos[1].title,
        'content' => memos[1].content,
        'poster' => memos[1].poster,
        'created_at' => memos[1].created_at,
        'updated_at' => memos[1].updated_at,
        :tag_names => memos[1].tags.map(&:name)
      }
    end
    let!(:third_expected_memo) do
      {
        'id' => memos[2].id,
        'title' => memos[2].title,
        'content' => memos[2].content,
        'poster' => memos[2].poster,
        'created_at' => memos[2].created_at,
        'updated_at' => memos[2].updated_at,
        :tag_names => memos[2].tags.map(&:name)
      }
    end

    context 'タイトルで検索した場合' do
      it 'タイトルフィルターが正しく機能し、期待されるメモが取得できることを確認する' do
        aggregate_failures do
          result = Memo::Query.call(filter_collection: described_class.all, params: { title: 'テスト' })
          expect(result[:memos]).to include(firts_expected_memo, second_expected_memo)
        end
      end
    end

    context 'コンテンツで検索した場合' do
      it 'コンテンツフィルターが正しく機能し、期待されるメモが取得できることを確認する' do
        result = Memo::Query.call(filter_collection: described_class.all, params: { content: 'コンテンツ' })
        expect(result[:memos]).to include(firts_expected_memo, second_expected_memo, third_expected_memo)
      end
    end

    context 'タイトルとコンテンツで検索した場合' do
      it 'タイトルとコンテンツの両方でフィルターが正しく機能し、期待されるメモが取得できることを確認する' do
        aggregate_failures do
          result = Memo::Query.call(filter_collection: described_class.all, params: { title: 'その他', content: 'コンテンツ' })
          expect(result[:memos]).to include(third_expected_memo)
          expect(result[:memos]).not_to include(firts_expected_memo, second_expected_memo)
        end
      end
    end

    context '並び替え機能のテスト' do
      it '昇順機能が正しく機能していること' do
        result = Memo::Query.call(filter_collection: described_class.all, params: { order: 'asc' })
        expect(result[:memos]).to contain_exactly(firts_expected_memo, second_expected_memo, third_expected_memo)
      end

      it 'デフォルトで降順機能が正しく機能されていること' do
        aggregate_failures do
          result = Memo::Query.call(filter_collection: described_class.all, params: {})
          expect(result[:memos]).to contain_exactly(third_expected_memo, second_expected_memo, firts_expected_memo)
        end
      end
    end

    context 'ページネーション機能のテスト' do
      before { create_list(:memo, 20) }

      it '指定したページ数のメモ、総数が取得できること' do
        aggregate_failures do
          result = Memo::Query.call(filter_collection: described_class.all, params: { page: 2 })
          memo_relation = described_class.order(id: :desc).limit(10).offset(10)
          expect(result[:memos].pluck('id')).to eq(memo_relation.pluck(:id))
          expect(result[:total_page]).to eq(3)
        end
      end
    end
  end
end
