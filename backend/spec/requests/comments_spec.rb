# frozen_string_literal: true

RSpec.describe 'CommentsController' do
  describe 'POST /memos/:memo_id/comments' do
    context 'コンテンツが有効な場合' do
      let(:memo) { create(:memo) }
      let(:params) { { content: Faker::Lorem.paragraph(sentence_count: 3) } }

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

    context 'バリデーションエラーになる場合' do
      let(:memo) { create(:memo) }
      let(:params) { { content: '' } }

      it 'コメントが追加されず、422が返る' do
        aggregate_failures do
          expect do
            post "/memos/#{memo.id}/comments", params: { comment: params }, as: :json
          end.not_to change(Comment, :count)
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.parsed_body['errors']).to eq(['内容を入力してください'])
        end
      end
    end
  end

  describe 'PUT /memos/:memo_id/comments/:id' do
    context 'コンテンツが有効な場合' do
      let(:memo) { create(:memo) }
      let(:comment) { create(:comment, memo: memo) }
      let(:params) { { content: Faker::Lorem.paragraph(sentence_count: 3) } }

      it 'コメントが更新され、204が返る' do
        aggregate_failures do
          put "/memos/#{memo.id}/comments/#{comment.id}", params: { comment: params }, as: :json
          expect(response).to have_http_status(:no_content)
          expect(response.body).to be_empty
        end
      end
    end
  end

  context 'バリデーションエラーになる場合' do
    let(:memo) { create(:memo) }
    let(:comment) { create(:comment, memo: memo) }
    let(:params) { { content: '' } }

    it 'コメントが更新されず、422が返る' do
      aggregate_failures do
        put "/memos/#{memo.id}/comments/#{comment.id}", params: { comment: params }, as: :json
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body['errors']).to eq(['内容を入力してください'])
      end
    end
  end

  context '存在しないコメントIDの場合' do
    let(:memo) { create(:memo) }
    let(:comment) { create(:comment, memo: memo) }
    let(:params) { { content: Faker::Lorem.paragraph(sentence_count: 3) } }

    it '404が返る' do
      aggregate_failures do
        put "/memos/#{memo.id}/comments/0", params: { comment: params }, as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  context '存在しないメモIDの場合' do
    let(:memo) { create(:memo) }
    let(:comment) { create(:comment, memo: memo) }
    let(:params) { { content: Faker::Lorem.paragraph(sentence_count: 3) } }

    it '404が返る' do
      aggregate_failures do
        put "/memos/0/comments/#{comment.id}", params: { comment: params }, as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /memos/:memo_id/comments/:id' do
    context 'コメントが存在する場合' do
      let!(:memo) { create(:memo) }
      let!(:comment) { create(:comment, memo: memo) }

      it 'コメントが削除され、204になる' do
        aggregate_failures do
          expect do
            delete "/memos/#{memo.id}/comments/#{comment.id}", as: :json
          end.to change(Comment, :count).by(-1)
          expect(response).to have_http_status(:no_content)
        end
      end
    end

    context 'コメントが存在しない場合' do
      let!(:memo) { create(:memo) }

      it '404が返る' do
        aggregate_failures do
          expect do
            delete "/memos/#{memo.id}/comments/0", as: :json
          end.not_to change(Comment, :count)
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'メモが存在しない場合' do
      let!(:memo) { create(:memo) }
      let!(:comment) { create(:comment, memo: memo) }

      it '404が返る' do
        aggregate_failures do
          expect do
            delete "/memos/0/comments/#{comment.id}", as: :json
          end.not_to change(Comment, :count)
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'コメントの削除に失敗した場合' do
      let!(:memo) { create(:memo) }
      let!(:comment) { create(:comment, memo: memo) }

      before do
        allow(Comment).to receive(:find_by).and_return(comment)
        allow(comment).to receive(:destroy).and_return(false)
      end

      it '422が返る' do
        aggregate_failures do
          expect do
            delete "/memos/#{memo.id}/comments/#{comment.id}", as: :json
          end.not_to change(Comment, :count)
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end
end
