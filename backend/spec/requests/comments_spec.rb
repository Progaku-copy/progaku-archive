# frozen_string_literal: true

RSpec.describe 'CommentsController' do
  describe 'POST /memos/:memo_id/comments' do
    context 'コンテンツが有効な場合' do
      let(:memo) { create(:memo) }
      let(:valid_comment_params) { { content: Faker::Lorem.paragraph(sentence_count: 3) } }

      it 'コメントが追加され、204になる' do
        aggregate_failures do
          expect do
            post "/memos/#{memo.id}/comments", params: { comment: valid_comment_params }, as: :json
          end.to change(Comment, :count).by(1)

          expect(response).to have_http_status(:no_content)
          expect(response.body).to be_empty
        end
      end
    end

    context 'バリデーションエラーになる場合' do
      let(:memo) { create(:memo) }
      let(:invalid_comment_params) { { content: '' } }

      it 'コメントが追加されていないこと、422になることを確認する' do
        aggregate_failures do
          expect do
            post "/memos/#{memo.id}/comments", params: { comment: invalid_comment_params }, as: :json
          end.not_to change(Comment, :count)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body['errors']).to eq(['内容を入力してください'])
        end
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

      it '404が返ることを確認する' do
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

      it '404が返ることを確認する' do
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

      it '422が返ることを確認する' do
        aggregate_failures do
          expect do
            delete "/memos/#{memo.id}/comments/#{comment.id}", as: :json
          end.not_to change(Comment, :count)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
