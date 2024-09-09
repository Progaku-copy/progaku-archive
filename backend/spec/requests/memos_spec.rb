# frozen_string_literal: true

RSpec.describe 'MemosController' do
  describe 'GET /memos' do
    context 'メモが存在する場合' do
      let!(:memos) { create_list(:memo, 3) }

      it '全てのメモが降順で返る' do
        aggregate_failures do
          get '/memos'
          expect(response).to have_http_status(:ok)
          assert_response_schema_confirm(200)
          expect(response.parsed_body['memos'].length).to eq(3)
          result_memo_ids = response.parsed_body['memos'].map { _1['id'] } # rubocop:disable Rails/Pluck
          expected_memo_ids = memos.reverse.map(&:id)
          expect(result_memo_ids).to eq(expected_memo_ids)
        end
      end
    end
  end

  describe 'GET /memos/:id' do
    context 'メモが存在する場合' do
      let!(:memo) { create(:memo) }
      let!(:comments) { create_list(:comment, 3, memo: memo) }

      it '指定したメモ、コメントが返る' do
        aggregate_failures do
          get "/memos/#{memo.id}", headers: { Accept: 'application/json' }
          expect(response).to have_http_status(:ok)
          assert_response_schema_confirm(200)
          expect(response.parsed_body['memo']['id']).to eq(memo.id)
          expect(response.parsed_body['memo']['comments'].length).to eq(3)
          result_comment_ids = response.parsed_body['memo']['comments'].map { _1['id'] } # rubocop:disable Rails/Pluck
          expected_comments_ids = comments.reverse.map(&:id)
          expect(result_comment_ids).to eq(expected_comments_ids)
        end
      end
    end

    context '存在しないメモを取得しようとした場合' do
      it '404が返る' do
        get '/memos/0'
        expect(response).to have_http_status(:not_found)
        assert_response_schema_confirm(404)
      end
    end
  end

  describe 'POST /memos' do
    let!(:tags) { create_list(:tag, 3) }
    let(:tag_ids) { tags.map(&:id) }

    context 'タイトルとコンテンツが有効な場合' do
      let(:valid_memo_form_params) do
        { title: Faker::Lorem.sentence(word_count: 3), content: Faker::Lorem.paragraph(sentence_count: 5),
          tag_ids: tag_ids }
      end

      it 'memoレコードが追加され、タグが紐付けられ、204になる' do
        aggregate_failures do
          expect do
            post '/memos', params: { memo_form: valid_memo_form_params }, as: :json
          end.to change(Memo, :count).by(+1)
          expect(Memo.last.tags.count).to eq(3)
          assert_request_schema_confirm
          expect(response).to have_http_status(:no_content)
          assert_response_schema_confirm(204)
          expect(response.body).to be_empty
        end
      end
    end

    context 'バリデーションエラーになる場合' do
      let(:invalid_memo_form_params) do
        { title: '', content: '', tag_ids: tag_ids }
      end

      it '422になり、エラーメッセージが返る' do
        aggregate_failures do
          expect do
            expect do
              post '/memos', params: { memo_form: invalid_memo_form_params }, as: :json
            end.not_to change(Memo, :count)
          end.not_to change(Tag, :count)
          assert_request_schema_confirm
          expect(response).to have_http_status(:unprocessable_entity)
          assert_response_schema_confirm(422)
          expect(response.parsed_body['errors']).to eq(%w[タイトルを入力してください コンテンツを入力してください])
        end
      end
    end
  end

  describe 'PUT /memos/:id' do
    let!(:existing_memo) { create(:memo) }
    let!(:existing_tags) { create_list(:tag, 3) }

    before { create(:memo_tag, memo: existing_memo, tag: existing_tags.first) }

    context 'コンテンツ、タグが有効な場合' do
      let(:params) { { content: '新しいコンテンツ', tag_ids: [existing_tags.second.id] } }

      it 'memoが更新され、204になる' do
        aggregate_failures do
          put "/memos/#{existing_memo.id}", params: { memo_form: params }, as: :json
          assert_request_schema_confirm
          expect(response).to have_http_status(:no_content)
          assert_response_schema_confirm(204)
          existing_memo.reload
          expect(existing_memo.content).to eq('新しいコンテンツ')
          expect(existing_memo.tags.first.name).to eq(existing_tags.second.name)
        end
      end
    end

    context 'バリデーションエラーになる場合' do
      let(:params) { { content: '', tag_ids: [existing_tags.last.id + 100] } }

      it '422になり、エラーメッセージが返る' do
        aggregate_failures do
          put "/memos/#{existing_memo.id}", params: { memo_form: params }, as: :json
          assert_request_schema_confirm
          existing_memo.reload
          expect(response).to have_http_status(:unprocessable_entity)
          assert_response_schema_confirm(422)
          expect(response.parsed_body['errors']).to eq(%w[コンテンツを入力してください])
        end
      end
    end

    context 'タイトルを更新しようとした場合' do
      let(:params) { { title: '新しいタイトル' } }

      it 'タイトルが変更されていないことを確認する' do
        aggregate_failures do
          put "/memos/#{existing_memo.id}", params: { memo_form: params }, as: :json
          assert_request_schema_confirm
          expect(response).to have_http_status(:unprocessable_entity)
          existing_memo.reload
          assert_response_schema_confirm(422)
          expect(existing_memo.title).not_to eq('新しいタイトル')
        end
      end
    end
  end

  describe 'DELETE /memos/:id' do
    context 'メモを削除しようとした場合' do
      let!(:existing_memo) { create(:memo) }

      it 'メモを削除され、204が返る' do
        aggregate_failures do
          expect { delete "/memos/#{existing_memo.id}" }.to change(Memo, :count).by(-1)
          assert_request_schema_confirm
          expect(response).to have_http_status(:no_content)
          assert_response_schema_confirm(204)
        end
      end
    end

    context '存在しないメモを削除しようとした場合' do
      it '404が返る' do
        aggregate_failures do
          expect { delete '/memos/0' }.not_to change(Memo, :count)
          assert_request_schema_confirm
          expect(response).to have_http_status(:not_found)
          assert_response_schema_confirm(404)
        end
      end
    end
  end
end
