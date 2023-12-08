# frozen_string_literal: true

RSpec.describe 'MemosController' do
  describe 'POST /memos' do
    context 'タイトルとコンテンツが有効な場合' do
      let(:valid_memo_params) do
        { title: Faker::Lorem.sentence(word_count: 3), content: Faker::Lorem.paragraph(sentence_count: 5) }
      end

      it 'memoレコードが追加され、204になる' do
        aggregate_failures do
          expect { post '/memos', params: { memo: valid_memo_params } }.to change(Memo, :count).by(+1)
          expect(response).to have_http_status(:no_content)
          expect(response.body).to be_empty
        end
      end
    end

    context 'バリデーションエラーになる場合' do
      let(:empty_memo_params) { { title: '', content: '' } }

      it '422になり、エラーメッセージがレスポンスとして返る' do
        aggregate_failures do
          post '/memos', params: { memo: empty_memo_params }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body['errors']).to eq(%w[タイトルを入力してください コンテンツを入力してください])
        end
      end
    end
  end

  describe 'PUT /memos/:id' do
    context 'タイトルとコンテンツが有効な場合' do
      let(:update_memo_params) { { content: '新しいコンテンツ' } }
      let(:existing_memo) { create(:memo) }

      it 'memoが更新され、204になる' do
        aggregate_failures do
          put "/memos/#{existing_memo.id}", params: { memo: update_memo_params }
          expect(response).to have_http_status(:no_content)
          existing_memo.reload
          expect(existing_memo.content).to eq('新しいコンテンツ')
        end
      end
    end

    context 'バリデーションエラーになる場合'
  end
end
