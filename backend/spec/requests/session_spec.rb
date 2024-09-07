# frozen_string_literal: true

RSpec.describe 'SessionsController' do
  let(:user) { create(:user, password: 'password') }

  describe 'POST /login' do
    context 'ログイン情報が正しい場合' do
      it 'ログインが成功し、200が返る' do
        aggregate_failures do
          post '/login', params: { session: { account_name: user.account_name, password: 'password' } }
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'アカウント名が存在しない場合' do
      let(:params) { { session: { account_name: 'invalid_account_name', password: 'password' } } }

      it 'ログインに失敗し、401が返る' do
        aggregate_failures do
          post '/login', params: params
          expect(response).to have_http_status(:unauthorized)
          expect(response.parsed_body['errors']).to eq(['アカウント名が存在しません'])
        end
      end
    end

    context 'パスワードが異なる場合' do
      let(:params) { { session: { account_name: user.account_name, password: 'invalid_password' } } }

      it 'ログインに失敗し、401が返る' do
        aggregate_failures do
          post '/login', params: params
          expect(response).to have_http_status(:unauthorized)
          expect(response.parsed_body['errors']).to eq(['パスワードが正しくありません'])
        end
      end
    end
  end

  describe 'DELETE /logout' do
    context 'ログインしている場合' do
      before { post '/login', params: { session: { account_name: user.account_name, password: 'password' } } }

      it 'ログアウトが成功し、204が返る' do
        aggregate_failures do
          delete '/logout'
          expect(response).to have_http_status(:no_content)
        end
      end
    end
  end
end
