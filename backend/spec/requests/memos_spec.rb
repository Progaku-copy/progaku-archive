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
    context 'タイトルとコンテンツが有効な場合' do
      let(:valid_memo_params) do
        { title: Faker::Lorem.sentence(word_count: 3), content: Faker::Lorem.paragraph(sentence_count: 5) }
      end

      it 'memoレコードが追加され、204が返る' do
        aggregate_failures do
          expect { post '/memos', params: { memo: valid_memo_params }, as: :json }.to change(Memo, :count).by(+1)
          assert_request_schema_confirm
          expect(response).to have_http_status(:no_content)
          assert_response_schema_confirm(204)
          expect(response.body).to be_empty
        end
      end
    end

    context 'バリデーションエラーになる場合' do
      let(:empty_memo_params) { { title: '', content: '' } }

      it '422になり、エラーメッセージが返る' do
        aggregate_failures do
          post '/memos', params: { memo: empty_memo_params }, as: :json
          assert_request_schema_confirm
          expect(response).to have_http_status(:unprocessable_entity)
          assert_response_schema_confirm(422)
          expect(response.parsed_body['errors']).to eq(%w[タイトルを入力してください コンテンツを入力してください])
        end
      end
    end
  end

  describe 'PUT /memos/:id' do
    context 'コンテンツが有効な場合' do
      let(:existing_memo) { create(:memo) }
      let(:params) { { content: '新しいコンテンツ' } }

      it 'memoが更新され、204になる' do
        aggregate_failures do
          put "/memos/#{existing_memo.id}", params: { memo: params }, as: :json
          assert_request_schema_confirm
          expect(response).to have_http_status(:no_content)
          assert_response_schema_confirm(204)
          existing_memo.reload
          expect(existing_memo.content).to eq('新しいコンテンツ')
        end
      end
    end

    context 'バリデーションエラーになる場合' do
      let(:existing_memo) { create(:memo) }
      let(:params) { { content: '' } }

      it '422になり、エラーメッセージが返る' do
        aggregate_failures do
          put "/memos/#{existing_memo.id}", params: { memo: params }, as: :json
          assert_request_schema_confirm
          existing_memo.reload
          expect(response).to have_http_status(:unprocessable_entity)
          assert_response_schema_confirm(422)
          expect(response.parsed_body['errors']).to eq(['コンテンツを入力してください'])
        end
      end
    end
  end

  context 'タイトルを更新しようとした場合' do
    let(:existing_memo) { create(:memo) }
    let(:params) { { title: '新しいタイトル' } }

    it 'タイトルが変更されず204が返る' do
      aggregate_failures do
        put "/memos/#{existing_memo.id}", params: { memo: params }, as: :json
        assert_request_schema_confirm
        expect(response).to have_http_status(:no_content)
        existing_memo.reload
        assert_response_schema_confirm(204)
        expect(existing_memo.title).not_to eq('新しいタイトル')
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

  describe 'SearchResolver' do
    let!(:memo1) { create(:memo, title: 'テスト タイトル１', content: 'テスト コンテンツ１') }
    let!(:memo2) { create(:memo, title: 'その他 タイトル', content: 'その他 コンテンツ') }
    let!(:memo3) { create(:memo, title: 'テスト タイトル２', content: 'テスト コンテンツ２') }
  
    describe 'resolveメソッドのテスト' do
      context 'タイトルで検索した場合' do
        it 'タイトルフィルターが正しく機能することを確認する' do
          filter_params = { title: 'テスト' }
          result = Memo::SearchResolver.resolve(filter_collection: Memo.all, filter_params: filter_params)
          expect(result).to contain_exactly(memo1, memo3)
        end
      end

      context 'コンテンツで検索した場合' do
        it 'コンテンツフィルターが正しく機能することを確認する' do
          filter_params = { content: 'コンテンツ' }
          result = Memo::SearchResolver.resolve(filter_collection: Memo.all, filter_params: filter_params)
          expect(result).to contain_exactly(memo1, memo2, memo3)
        end
      end

      context '並び替え機能のテスト' do
        it '並び替え機能が正しく機能することを確認する' do
          filter_params = { order: 'desc' }
          result = Memo::SearchResolver.resolve(filter_collection: Memo.all, filter_params: filter_params)
          expect(result).to eq([memo3, memo2, memo1])
        end
      end

      context 'タイトルとコンテンツで検索した場合' do
        it 'タイトルとコンテンツフィルターが正しく機能することを確認する' do
          filter_params = { title: 'テスト', content: 'コンテンツ', order: 'desc' }
          result = Memo::SearchResolver.resolve(filter_collection: Memo.all, filter_params: filter_params)
          expect(result).to eq([memo3, memo1])
        end
      end

      context '検索内容を入力しない場合' do
        it '全てのメモが返されることを確認する' do
          filter_params = {}
          result = Memo::SearchResolver.resolve(filter_collection: Memo.all, filter_params: filter_params)
          expect(result).to contain_exactly(memo1, memo2, memo3)
        end
      end
    end
  end
end

