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

    context 'タイトルで検索した場合' do
      it 'タイトルフィルターが正しく機能し、期待されるメモが取得できることを確認する' do
        aggregate_failures do
          result = Memo::Query.call(filter_collection: described_class.all, params: { title: 'テスト' })
          expect(result[:memos]).to include(memos[0], memos[1])
        end
      end
    end

    context 'コンテンツで検索した場合' do
      it 'コンテンツフィルターが正しく機能し、期待されるメモが取得できることを確認する' do
        result = Memo::Query.call(filter_collection: described_class.all, params: { content: 'コンテンツ' })
        expect(result[:memos]).to include(memos[0], memos[1], memos[2])
      end
    end

    context 'タイトルとコンテンツで検索した場合' do
      it 'タイトルとコンテンツの両方でフィルターが正しく機能し、期待されるメモが取得できることを確認する' do
        aggregate_failures do
          result = Memo::Query.call(filter_collection: described_class.all, params: { title: 'その他', content: 'コンテンツ' })
          expect(result[:memos]).to include(memos[2])
          expect(result[:memos]).not_to include(memos[0], memos[1])
        end
      end
    end

    context '並び替え機能のテスト' do
      it '昇順機能が正しく機能していること' do
        result = Memo::Query.call(filter_collection: described_class.all, params: { order: 'asc' })
        expect(result[:memos]).to contain_exactly(memos[0], memos[1], memos[2])
      end

      it 'デフォルトで降順機能が正しく機能されていること' do
        aggregate_failures do
          result = Memo::Query.call(filter_collection: described_class.all, params: {})
          expect(result[:memos]).to contain_exactly(memos[2], memos[1], memos[0])
        end
      end
    end

    context 'ページネーション機能のテスト' do
      before do
        memos_data = Array.new(20) do
          {
            title: Faker::Lorem.sentence(word_count: 3),
            content: Faker::Lorem.paragraph(sentence_count: 5),
            poster: Faker::Name.name,
            created_at: Time.current,
            updated_at: Time.current
          }
        end

        described_class.bulk_import!(memos_data)
      end

      it '指定したページ数のメモ、総数が取得できること' do
        aggregate_failures do
          result = Memo::Query.call(filter_collection: described_class.all, params: { page: 2 })
          memo_relation = described_class.order(id: :desc).limit(10).offset(10)
          expect(result[:memos].pluck('id')).to eq(memo_relation.pluck(:id))
          expect(result[:total_page]).to eq(2)
        end
      end
    end
  end
end
