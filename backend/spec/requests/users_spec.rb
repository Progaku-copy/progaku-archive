# frozen_string_literal: true

RSpec.describe 'UsersController' do
  let(:user) { create(:user, password: 'password', admin: true) }

  describe 'POST /admin/users' do
    context '管理ユーザでログイン中かつアカウント名とパスワードが有効な場合' do
      let(:params) { { account_name: 'test_user', password: 'password_password' } }

      before { sign_in(user) }

      it 'ユーザが作成され、204が返る' do
        aggregate_failures do
          post '/admin/users', params: { user: params }, as: :json
          expect(response).to have_http_status(:no_content)
        end
      end
    end

    context '管理ユーザでログイン中かつアカウント名が無効な場合' do
      let(:params) { { account_name: '', password: 'password_password' } }

      before { sign_in(user) }

      it '422が返り、エラーメッセージが返る' do
        aggregate_failures do
          post '/admin/users', params: { user: params }, as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body['errors']).to include('アカウント名を入力してください')
        end
      end
    end

    context '管理ユーザでログイン中かつパスワードが無効な場合' do
      let(:params) { { account_name: 'testUser', password: '' } }

      before { sign_in(user) }

      it '422が返り、エラーメッセージが返る' do
        aggregate_failures do
          post '/admin/users', params: { user: params }, as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body['message']).to eq('パスワードを入力してください、パスワードを入力してください、パスワードは10文字以上で入力してください')
        end
      end
    end

    context '管理ユーザでログイン中かつアカウント名が重複している場合' do
      let(:params) { { account_name: user.account_name, password: 'password_password' } }

      before { sign_in(user) }

      it '422が返り、エラーメッセージが返る' do
        aggregate_failures do
          post '/admin/users', params: { user: params }, as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body['message']).to eq('アカウント名はすでに存在します')
        end
      end
    end

    context '管理ユーザでログイン中でない場合' do
      let(:params) { { account_name: 'test_user', password: 'password_password' } }

      before { sign_in(create(:user, password: 'password_password', admin: false)) }

      it '403が返る' do
        aggregate_failures do
          post '/admin/users', params: { user: params }, as: :json
          expect(response).to have_http_status(:forbidden)
          expect(response.parsed_body['message']).to eq('権限がありません')
        end
      end
    end

    context 'ログインしていない場合' do
      let(:params) { { account_name: 'test_user', password: 'password_password' } }

      it '401が返る' do
        aggregate_failures do
          post '/admin/users', params: { user: params }, as: :json
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
