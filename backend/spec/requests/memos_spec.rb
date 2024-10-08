# frozen_string_literal: true

RSpec.describe 'MemosController' do
  let!(:user) { create(:user) }

  describe 'GET /memos' do
    let!(:memos) { create_list(:memo, 20) }

    context 'ログイン中かつメモが存在し、パラメータが指定されていない場合' do
      before { sign_in(user) }

      it '降順で、1ページ目に10件のメモが返ること' do
        aggregate_failures do
          get '/memos'
          assert_request_schema_confirm
          assert_response_schema_confirm(200)
          expect(response.parsed_body['memos'].length).to eq(10)
          result_memo_ids = response.parsed_body['memos'].map { _1['id'] } # rubocop:disable Rails/Pluck
          expected_memo_ids = memos.reverse.map(&:id)
          expect(result_memo_ids).to eq(expected_memo_ids[0..9])
          expect(response.parsed_body['total_page']).to eq(2)
        end
      end
    end

    context 'ログイン中かつメモが存在し、ページが指定された場合' do
      before { sign_in(user) }

      it '降順で、指定されたページに10件のメモが返ること' do
        aggregate_failures do
          get '/memos', params: { page: 2 }
          assert_request_schema_confirm
          assert_response_schema_confirm(200)
          expect(response.parsed_body['memos'].length).to eq(10)
          result_memo_ids = response.parsed_body['memos'].pluck('id')
          expected_memo_ids = memos.sort_by(&:id).reverse[10..19].map(&:id)
          expect(result_memo_ids).to eq(expected_memo_ids)
          expect(response.parsed_body['total_page']).to eq(2)
        end
      end
    end

    context 'ログイン中かつメモが存在し、無効なページが指定された場合' do
      before { sign_in(user) }

      it '400が返る' do
        get '/memos', params: { page: 'a' }
        aggregate_failures do
          assert_response_schema_confirm(400)
          expect(response.parsed_body['error']).to eq('ページパラメータが無効です')
        end
      end
    end

    context 'ログインしていない場合' do
      it '401が返る' do
        get '/memos'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /memos/:id' do
    let!(:memo) { create(:memo) }
    let!(:comments) { create_list(:comment, 3, memo: memo) }

    context 'ログイン中かつメモが存在する場合' do
      before { sign_in(user) }

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

    context 'ログイン中かつ存在しないメモを取得しようとした場合' do
      before { sign_in(user) }

      it '404が返る' do
        get '/memos/0'
        expect(response).to have_http_status(:not_found)
        assert_response_schema_confirm(404)
      end
    end

    context 'ログインしていない場合' do
      it '401が返る' do
        get "/memos/#{memo.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /memos' do
    let!(:tags) { create_list(:tag, 3) }
    let(:tag_ids) { tags.map(&:id) }

    context 'ログイン中かつタイトルとコンテンツと投稿者が有効な場合' do
      let(:valid_form_params) do
        { title: Faker::Lorem.sentence(word_count: 3),
          content: Faker::Lorem.paragraph(sentence_count: 5),
          poster: Faker::Name.name,
          tag_ids: tag_ids }
      end

      before { sign_in(user) }

      it 'memoレコードが追加され、204が返る' do
        aggregate_failures do
          expect do
            post '/memos', params: { memo: valid_form_params }, as: :json
          end.to change(Memo, :count).by(1)
             .and change(MemoTag, :count).by(3)
          assert_request_schema_confirm
          expect(response).to have_http_status(:no_content)
          assert_response_schema_confirm(204)
          expect(response.body).to be_empty
        end
      end
    end

    context 'ログインしていてバリデーションエラーになる場合' do
      let(:empty_memo_params) { { title: '', content: '', poster: '', tag_ids: } }

      before { sign_in(user) }

      it '422になり、エラーメッセージが返る' do
        aggregate_failures do
          expect do
            expect do
              post '/memos', params: { memo: empty_memo_params }, as: :json
            end.not_to change(Memo, :count)
          end.not_to change(MemoTag, :count)
          assert_request_schema_confirm
          expect(response).to have_http_status(:unprocessable_content)
          assert_response_schema_confirm(422)
          expect(response.parsed_body['errors']).to eq ['メモに関連するエラーがあります']
        end
      end
    end

    context 'ログインしていない場合' do
      it '401が返る' do
        post '/memos'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT /memos/:id' do
    context 'ログインしていてコンテンツが有効な場合' do
      let(:existing_memo) { create(:memo) }
      let(:existing_tags) { create_list(:tag, 3) }
      let(:params) do
        { title: existing_memo.title,
          content: '新しいコンテンツ',
          poster: existing_memo.poster,
          tag_ids: [existing_tags.second.id] }
      end

      before do
        sign_in(user)
        create(:memo_tag, memo: existing_memo, tag: existing_tags.first)
      end

      it 'memoが更新され、204になる' do
        aggregate_failures do
          put "/memos/#{existing_memo.id}", params: { memo: params }, as: :json
          assert_request_schema_confirm
          expect(response).to have_http_status(:no_content)
          assert_response_schema_confirm(204)
          existing_memo.reload
          expect(existing_memo.content).to eq('新しいコンテンツ')
          expect(existing_memo.tags.first.name).to eq(existing_tags.second.name)
          expect(existing_memo.tags).not_to include(existing_tags.first)
        end
      end
    end

    context 'ログイン中かつコンテンツが空の場合' do
      let(:existing_memo) { create(:memo) }
      let(:params) do
        { title: existing_memo.title,
          content: '',
          poster: existing_memo.poster,
          tag_ids: [] }
      end

      before { sign_in(user) }

      it '422になり、エラーメッセージが返る' do
        aggregate_failures do
          put "/memos/#{existing_memo.id}", params: { memo: params }, as: :json
          assert_request_schema_confirm
          existing_memo.reload
          expect(response).to have_http_status(:unprocessable_content)
          assert_response_schema_confirm(422)
          expect(response.parsed_body['errors']).to eq(%w[メモに関連するエラーがあります])
        end
      end
    end

    context 'ログイン中かつタイトルが有効な場合' do
      let(:existing_memo) { create(:memo) }
      let(:params) do
        { title: '新しいタイトル',
          content: existing_memo.content,
          poster: existing_memo.poster,
          tag_ids: [] }
      end

      before { sign_in(user) }

      it 'タイトルが更新され、204が返る' do
        aggregate_failures do
          put "/memos/#{existing_memo.id}", params: { memo: params }, as: :json
          assert_request_schema_confirm
          expect(response).to have_http_status(:no_content)
          existing_memo.reload
          assert_response_schema_confirm(204)
          expect(existing_memo.title).to eq('新しいタイトル')
        end
      end
    end

    context 'ログイン中かつタイトルが無効な場合' do
      let(:existing_memo) { create(:memo) }
      let(:params) do
        { title: '',
          content: existing_memo.content,
          poster: existing_memo.poster,
          tag_ids: [] }
      end

      before { sign_in(user) }

      it '422が返り、エラーメッセージが返る' do
        aggregate_failures do
          put "/memos/#{existing_memo.id}", params: { memo: params }, as: :json
          assert_request_schema_confirm
          existing_memo.reload
          expect(response).to have_http_status(:unprocessable_content)
          assert_response_schema_confirm(422)
          expect(response.parsed_body['errors']).to eq(['メモに関連するエラーがあります'])
        end
      end
    end

    context 'ログインしていない場合' do
      it '401が返る' do
        put '/memos/0'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /memos/:id' do
    context 'ログイン中かつメモを削除しようとした場合' do
      let!(:existing_memo) { create(:memo) }

      before { sign_in(user) }

      it 'メモを削除され、204が返る' do
        aggregate_failures do
          expect { delete "/memos/#{existing_memo.id}" }.to change(Memo, :count).by(-1)
          assert_request_schema_confirm
          expect(response).to have_http_status(:no_content)
          assert_response_schema_confirm(204)
        end
      end
    end

    context 'ログイン中かつ存在しないメモを削除しようとした場合' do
      before { sign_in(user) }

      it '404が返る' do
        aggregate_failures do
          expect { delete '/memos/0' }.not_to change(Memo, :count)
          assert_request_schema_confirm
          expect(response).to have_http_status(:not_found)
          assert_response_schema_confirm(404)
        end
      end
    end

    context 'ログインしていない場合' do
      it '401が返る' do
        delete '/memos/0'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
