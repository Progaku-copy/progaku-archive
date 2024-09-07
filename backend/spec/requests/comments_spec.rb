# frozen_string_literal: true

RSpec.describe 'CommentsController' do
  let!(:user) { create(:user, password: 'password') }

  describe 'POST /memos/:memo_id/comments' do
    context 'ログイン中かつコンテンツが有効な場合' do
      let(:memo) { create(:memo) }
      let(:params) { { content: Faker::Lorem.paragraph(sentence_count: 3) } }

      before { sign_in(user) }

      it 'コメントが追加され、204が返る' do
        aggregate_failures do
          expect do
            post "/memos/#{memo.id}/comments", params: { comment: params }, as: :json
          end.to change(Comment, :count).by(1)

          expect(response).to have_http_status(:no_content)
          expect(response.body).to be_empty
        end
      end
    end

    context 'ログイン中かつバリデーションエラーになる場合' do
      let(:memo) { create(:memo) }
      let(:params) { { content: '' } }

      before { sign_in(user) }

      it 'コメントが追加されず、422が返る' do
        aggregate_failures do
          expect do
            post "/memos/#{memo.id}/comments", params: { comment: params }, as: :json
          end.not_to change(Comment, :count)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body['errors']).to eq(['内容を入力してください'])
        end
      end
    end

    context 'ログインしていない場合' do
      it '401が返る' do
        post '/memos/1/comments'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT /memos/:memo_id/comments/:id' do
    context 'ログイン中かつコンテンツが有効な場合' do
      let(:memo) { create(:memo) }
      let(:comment) { create(:comment, memo: memo) }
      let(:params) { { content: Faker::Lorem.paragraph(sentence_count: 3) } }

      before { sign_in(user) }

      it 'コメントが更新され、204が返る' do
        aggregate_failures do
          put "/memos/#{memo.id}/comments/#{comment.id}", params: { comment: params }, as: :json
          expect(response).to have_http_status(:no_content)
          expect(response.body).to be_empty
        end
      end
    end
  end

  context 'ログイン中かつバリデーションエラーになる場合' do
    let(:memo) { create(:memo) }
    let(:comment) { create(:comment, memo: memo) }
    let(:params) { { content: '' } }

    before { sign_in(user) }

    it 'コメントが更新されず、422が返る' do
      aggregate_failures do
        put "/memos/#{memo.id}/comments/#{comment.id}", params: { comment: params }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['errors']).to eq(['内容を入力してください'])
      end
    end
  end

  context 'ログイン中かつ存在しないコメントIDの場合' do
    let(:memo) { create(:memo) }
    let(:comment) { create(:comment, memo: memo) }
    let(:params) { { content: Faker::Lorem.paragraph(sentence_count: 3) } }

    before { sign_in(user) }

    it '404が返る' do
      aggregate_failures do
        put "/memos/#{memo.id}/comments/0", params: { comment: params }, as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  context 'ログイン中かつ存在しないメモIDの場合' do
    let(:memo) { create(:memo) }
    let(:comment) { create(:comment, memo: memo) }
    let(:params) { { content: Faker::Lorem.paragraph(sentence_count: 3) } }

    before { sign_in(user) }

    it '404が返る' do
      aggregate_failures do
        put "/memos/0/comments/#{comment.id}", params: { comment: params }, as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  context 'ログインしていない場合' do
    it '401が返る' do
      put '/memos/1/comments/1'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /memos/:memo_id/comments/:id' do
    context 'ログイン中かつコメントが存在する場合' do
      let!(:memo) { create(:memo) }
      let!(:comment) { create(:comment, memo: memo) }

      before { sign_in(user) }

      it 'コメントが削除され、204になる' do
        aggregate_failures do
          expect do
            delete "/memos/#{memo.id}/comments/#{comment.id}", as: :json
          end.to change(Comment, :count).by(-1)
          expect(response).to have_http_status(:no_content)
        end
      end
    end

    context 'ログイン中かつコメントが存在しない場合' do
      let!(:memo) { create(:memo) }

      before { sign_in(user) }

      it '404が返る' do
        aggregate_failures do
          expect do
            delete "/memos/#{memo.id}/comments/0", as: :json
          end.not_to change(Comment, :count)
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'ログイン中かつメモが存在しない場合' do
      let!(:memo) { create(:memo) }
      let!(:comment) { create(:comment, memo: memo) }

      before { sign_in(user) }

      it '404が返る' do
        aggregate_failures do
          expect do
            delete "/memos/0/comments/#{comment.id}", as: :json
          end.not_to change(Comment, :count)
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'ログイン中かつコメントの削除に失敗した場合' do
      let!(:memo) { create(:memo) }
      let!(:comment) { create(:comment, memo: memo) }

      before do
        sign_in(user)
        allow(Comment).to receive(:find_by).and_return(comment)
        allow(comment).to receive(:destroy).and_return(false)
      end

      it '422が返る' do
        aggregate_failures do
          expect do
            delete "/memos/#{memo.id}/comments/#{comment.id}", as: :json
          end.not_to change(Comment, :count)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'ログインしていない場合' do
      it '401が返る' do
        delete '/memos/1/comments/1'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
