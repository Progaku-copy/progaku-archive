# frozen_string_literal: true

RSpec.describe 'SessionsController' do
  let(:user) { create(:user) }

  describe 'POST /login' do
    context 'ログイン情報が正しい場合' do
      it 'ログインが成功し、200が返る' do
        post '/login', params: { session: { account_name: user.account_name, password: user.password } }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'アカウント名が存在しない場合' do
      let(:params) { { session: { account_name: 'invalid_account_name', password: user.password } } }

      it 'ログインに失敗し、401が返る' do
        aggregate_failures do
          post '/login', params: params
          expect(response).to have_http_status(:unauthorized)
          expect(response.parsed_body['message']).to eq('アカウント名とパスワードの組み合わせが不正です')
        end
      end
    end

    context 'パスワードが異なる場合' do
      let(:params) { { session: { account_name: user.account_name, password: 'invalid_password' } } }

      it 'ログインに失敗し、401が返る' do
        aggregate_failures do
          post '/login', params: params
          expect(response).to have_http_status(:unauthorized)
          expect(response.parsed_body['message']).to eq('アカウント名とパスワードの組み合わせが不正です')
        end
      end
    end
  end

  describe 'DELETE /logout' do
    context 'ログインしている場合' do
      before { post '/login', params: { session: { account_name: user.account_name, password: user.password } } }

      it 'ログアウトが成功し、200が返る' do
        aggregate_failures do
          delete '/logout'
          expect(response).to have_http_status(:ok)
          expect(response.parsed_body['message']).to eq('ログアウトしました')
        end
      end
    end
  end
end
