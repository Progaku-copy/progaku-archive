# frozen_string_literal: true

# == Schema Information
#
# Table name: memos
#
#  id                                 :bigint           not null, primary key
#  content(メモの本文)                :text(65535)      not null
#  poster_user_key(Slackの投稿者のID) :string(255)      not null
#  slack_ts(Slackの投稿時刻)          :string(255)      not null
#  title(メモのタイトル)              :string(255)      not null
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#
# Indexes
#
#  index_memos_on_poster_user_key  (poster_user_key)
#  index_memos_on_slack_ts         (slack_ts) UNIQUE
#
# Foreign Keys
#
#  fk_memos_poster_user_key  (poster_user_key => posters.user_key)
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

    context 'poster_user_keyが空文字の場合' do
      before { memo.poster_user_key = '' }

      it 'valid?メソッドがfalseを返し、エラーメッセージが格納される' do
        aggregate_failures do
          memo.valid?
          expect(memo.errors.full_messages).to eq ['SlackのユーザーIDを入力してください']
        end
      end
    end

    context 'poster_user_keyがnilの場合' do
      before { memo.poster_user_key = nil }

      it 'valid?メソッドがfalseを返し、エラーメッセージが格納される' do
        aggregate_failures do
          expect(memo).not_to be_valid
          expect(memo.errors.full_messages).to eq ['SlackのユーザーIDを入力してください']
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
        create(:memo, title: 'テスト タイトル１', content: 'テスト コンテンツ１', slack_ts: '1000.000000'),
        create(:memo, title: 'テスト タイトル２', content: 'テスト コンテンツ２', slack_ts: '2000.000000'),
        create(:memo, title: 'その他 タイトル', content: 'その他 コンテンツ', slack_ts: '3000.000000')
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

    context  'タグで検索した場合' do
      before do
        tag_data = Array.new(3) do |n|
          {
            id: n + 1,
            name: "tag-#{n + 1}",
            priority: n + 1,
            created_at: Time.current,
            updated_at: Time.current
          }
        end

        Tag.bulk_import!(tag_data)

        memos[0].tags << Tag.find(1)
      end

      it 'タグフィルターが正しく機能し、期待されるメモが取得できることを確認する' do
        result = Memo::Query.call(filter_collection: described_class.preload(:tags), params: { tag_ids: 1 })
        expect(result[:memos]).to include(memos[0])
      end
    end

    context '並び替え機能のテスト' do
      before { memos }

      it '昇順機能が正しく機能していること' do
        result = Memo::Query.call(filter_collection: described_class.all, params: { order: 'asc' })
        expect(result[:memos].pluck(:slack_ts)).to eq(%w[1000.000000 2000.000000 3000.000000])
      end

      it 'デフォルトで降順機能が正しく機能されていること' do
        aggregate_failures do
          result = Memo::Query.call(filter_collection: described_class.all, params: {})
          expect(result[:memos].pluck(:slack_ts)).to eq(%w[3000.000000 2000.000000 1000.000000])
        end
      end
    end

    context 'ページネーション機能のテスト' do
      before do
        poster = create(:poster)

        memos_data = Array.new(20) do
          {
            title: Faker::Lorem.sentence(word_count: 3),
            content: Faker::Lorem.paragraph(sentence_count: 5),
            poster_user_key: poster.user_key,
            slack_ts: Faker::Number.decimal(l_digits: 10, r_digits: 6),
            created_at: Time.current,
            updated_at: Time.current
          }
        end

        described_class.bulk_import!(memos_data)
      end

      it '指定したページ数のメモ、総数が取得できること' do
        aggregate_failures do
          result = Memo::Query.call(filter_collection: described_class.all, params: { page: 2 })
          memo_relation = described_class.order(Arel.sql('CAST(memos.slack_ts AS DECIMAL(20,6)) DESC')).limit(10).offset(10)
          expect(result[:memos].pluck('id')).to eq(memo_relation.pluck(:id))
          expect(result[:total_page]).to eq(2)
        end
      end
    end
  end
end
