# frozen_string_literal: true

RSpec.describe 'Tags' do
  let!(:user) { create(:user) }

  describe 'GET /tags' do
    let!(:tags) do
      (1..3).map do |index|
        create(:tag, priority: index)
      end.index_by(&:priority)
    end

    before { sign_in(user) }

    it '全てのメモが取得でき昇順で並び変えられている' do
      aggregate_failures do
        get '/tags'
        expect(response).to have_http_status(:ok)
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.length).to eq(3)

        tag_ids = tags.values.map(&:id)
        response.parsed_body.each do |tag|
          expect(tag_ids).to include(tag['id'])
        end

        tag_names = tags.values.map(&:name)
        response.parsed_body.each do |tag|
          expect(tag_names).to include(tag['name'])
        end

        tag_priorities = tags.values.map(&:priority)
        expect(response.parsed_body.pluck('priority')).to eq(tag_priorities.sort)
      end
    end
  end

  describe 'POST /tags' do
    context 'ログイン中かつタグ名が有効な場合' do
      let(:params) { { name: 'New Tag', priority: 4 } }

      before { sign_in(user) }

      it 'tagレコードが追加され、204になる' do
        aggregate_failures do
          expect { post '/tags', params: { tag: params }, as: :json }.to change(Tag, :count).by(+1)
          assert_request_schema_confirm
          expect(response).to have_http_status(:no_content)
          assert_response_schema_confirm(204)
          expect(response.body).to be_empty
        end
      end
    end

    context 'ログイン中かつバリデーションエラーになる場合' do
      let(:params) { { name: '' } }

      before { sign_in(user) }

      it '422になり、エラーメッセージがレスポンスとして返る' do
        aggregate_failures do
          expect { post '/tags', params: { tag: params }, as: :json }.not_to change(Tag, :count)
          assert_request_schema_confirm
          expect(response).to have_http_status(:unprocessable_content)
          assert_response_schema_confirm(422)
          expect(response.parsed_body['errors']).to eq(%w[タグ名を入力してください タグの順番を入力してください])
        end
      end
    end
  end

  describe 'PUT /tags/:id' do
    context 'ログイン中かつタグ名及びタグの順番が有効な場合' do
      let!(:tag) { create(:tag, priority: 4) }
      let(:params) { { name: 'Update Tag', priority: 5 } }

      before { sign_in(user) }

      it 'タグが更新され、204になる' do
        aggregate_failures do
          put "/tags/#{tag.id}", params: { tag: params }, as: :json
          assert_request_schema_confirm
          expect(response).to have_http_status(:no_content)
          assert_response_schema_confirm(204)
          expect(Tag.find_by(priority: 5).name).to eq('Update Tag')
        end
      end
    end

    context 'ログイン中かつバリデーションエラーになる場合' do
      let!(:tag) { create(:tag, priority: 4) }
      let(:params) { { name: '' } }

      before { sign_in(user) }

      it '422になり、エラーメッセージがレスポンスとして返る' do
        aggregate_failures do
          put "/tags/#{tag.id}", params: { tag: params }, as: :json
          assert_request_schema_confirm
          expect(response).to have_http_status(:unprocessable_content)
          assert_response_schema_confirm(422)
          expect(response.parsed_body['errors']).to eq(['タグ名を入力してください'])
        end
      end
    end

    context 'ログイン中かつ存在しないタグを更新しようとした場合' do
      before { sign_in(user) }

      it 'ステータスコード404を返す' do
        aggregate_failures do
          put '/tags/0', params: { tag: { name: 'Update Tag' } }, as: :json
          expect(response).to have_http_status(:not_found)
          expect(response.body).to match(/Couldn't find Tag/)
        end
      end
    end
  end

  describe 'DELETE /tags/:id' do
    context 'ログイン中かつ存在するタグを削除しようとした場合' do
      let!(:tag) { create(:tag, priority: 4) }

      before { sign_in(user) }

      it 'タグが削除される' do
        aggregate_failures do
          expect { delete "/tags/#{tag.id}" }.to change(Tag, :count).by(-1)
          assert_request_schema_confirm
          expect(response).to have_http_status(:no_content)
          assert_response_schema_confirm(204)
        end
      end
    end

    context 'ログイン中かつ存在しないタグを削除しようとした場合' do
      before { sign_in(user) }

      it 'ステータスコード404を返す' do
        aggregate_failures do
          delete '/tags/0'
          expect { delete '/tags/0' }.not_to change(Tag, :count)
          assert_request_schema_confirm
          expect(response).to have_http_status(:not_found)
          assert_response_schema_confirm(404)
          expect(response.body).to match(/Couldn't find Tag/)
        end
      end
    end

    context 'ログイン中かつタグの削除に失敗する場合' do
      let!(:tag) { create(:tag, priority: 4) }

      before do
        sign_in(user)
        allow(Tag).to receive(:find).and_return(tag)
        allow(tag).to receive(:destroy).and_return(false)
      end

      it 'ステータスコード422を返す' do
        aggregate_failures do
          expect { delete "/tags/#{tag.id}", as: :json }.not_to change(Tag, :count)
          assert_request_schema_confirm
          expect(response).to have_http_status(:unprocessable_content)
          assert_response_schema_confirm(422)
        end
      end
    end
  end
end
