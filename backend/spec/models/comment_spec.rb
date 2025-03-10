# frozen_string_literal: true

# == Schema Information
#
# Table name: comments
#
#  id                                             :bigint           not null, primary key
#  content(内容)                                  :text(65535)      not null
#  poster_user_key(Slackの投稿者のID)             :string(255)      not null
#  slack_parent_ts(Slackの親メッセージの投稿時刻) :string(255)      not null
#  slack_ts(Slackの投稿時刻)                      :string(255)      not null
#  created_at                                     :datetime         not null
#  updated_at                                     :datetime         not null
#  memo_id(メモID)                                :bigint           not null
#
# Indexes
#
#  index_comments_on_memo_id          (memo_id)
#  index_comments_on_poster_user_key  (poster_user_key)
#  index_comments_on_slack_parent_ts  (slack_parent_ts)
#  index_comments_on_slack_ts         (slack_ts) UNIQUE
#
# Foreign Keys
#
#  fk_comments_memo_id          (memo_id => memos.id)
#  fk_comments_poster_user_key  (poster_user_key => posters.user_key)
#
RSpec.describe Comment do
  subject(:comment) { build(:comment) }

  describe 'バリデーションのテスト' do
    context 'memo_idとcontentが有効な場合' do
      let(:memo) { create(:memo) }
      let(:comment) { build(:comment, memo: memo) }

      it 'valid?メソッドがtrueを返すこと' do
        expect(comment).to be_valid
      end
    end

    context 'contentが空文字の場合' do
      before { comment.content = ' ' }

      it 'valid?メソッドがfalseを返し、errorsに「内容を入力してください」と格納されること' do
        aggregate_failures do
          expect(comment).not_to be_valid
          expect(comment.errors.full_messages).to eq ['内容を入力してください']
        end
      end
    end

    context 'contentがnilの場合' do
      before { comment.content = nil }

      it 'valid?メソッドがfalseを返し、errorsに「内容を入力してください」と格納されること' do
        aggregate_failures do
          expect(comment).not_to be_valid
          expect(comment.errors.full_messages).to eq ['内容を入力してください']
        end
      end
    end

    context 'poster_user_keyが空文字の場合' do
      before { comment.poster_user_key = '' }

      it 'valid?メソッドがfalseを返し、エラーメッセージが格納される' do
        aggregate_failures do
          comment.valid?
          expect(comment.errors.full_messages).to eq ['SlackのユーザーIDを入力してください']
        end
      end
    end

    context 'poster_user_keyがnilの場合' do
      before { comment.poster_user_key = nil }

      it 'valid?メソッドがfalseを返し、エラーメッセージが格納される' do
        aggregate_failures do
          expect(comment).not_to be_valid
          expect(comment.errors.full_messages).to eq ['SlackのユーザーIDを入力してください']
        end
      end
    end

    context 'poster_user_keyが50文字以上の場合' do
      before { comment.poster_user_key = 'a' * 51 }

      it 'valid?メソッドがfalseを返し、エラーメッセージが格納される' do
        aggregate_failures do
          expect(comment).not_to be_valid
          expect(comment.errors.full_messages).to eq ['SlackのユーザーIDを入力してください']
        end
      end
    end
  end

  describe 'アソシエーションのテスト' do
    context 'Memoモデルとの関係' do
      it '1:Nの関係になっている' do
        association = described_class.reflect_on_association(:memo)
        expect(association.macro).to eq(:belongs_to)
      end
    end
  end
end
