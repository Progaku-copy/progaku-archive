# frozen_string_literal: true

RSpec.describe 'Slack::PostersController' do
  describe 'PUT /slack/posters/' do
    let(:slack_posters) do
      {
        'members' => [
          { 'id' => 'user1', 'profile' => { 'display_name' => 'User One' }, 'real_name' => 'User 1' },
          { 'id' => 'user2', 'profile' => { 'display_name' => 'User Two' }, 'real_name' => 'User 2' }
        ]
      }
    end

    before do
      allow(SlackApiClient).to receive(:fetch_slack_users).and_return(slack_posters)
    end

    context 'Slackから取り込んだidがpostersテーブルにレコードが存在しない場合' do
      it 'Postersテーブルにレコードが追加される' do
        aggregate_failures do
          expect do
            put '/slack/posters/', as: :json
          end.to change(Poster, :count).by(2)

          posters = Poster.where(user_key: %w[user1 user2]).index_by(&:user_key)
          expect(posters['user1'].display_name).to eq('User One')
          expect(posters['user1'].real_name).to eq('User 1')
          expect(posters['user2'].display_name).to eq('User Two')
          expect(posters['user2'].real_name).to eq('User 2')
          expect(response).to have_http_status(:no_content)
        end
      end
    end

    context '既に存在するidのデータが含まれる場合' do
      before do
        create(:poster, user_key: 'user1', display_name: 'Old Name', real_name: 'Old Real Name')
      end

      it '既存のレコードは更新、新規のレコードは作成される' do
        aggregate_failures do
          expect do
            put '/slack/posters/', as: :json
          end.to change(Poster, :count).by(1)
          updated_poster = Poster.find_by(user_key: 'user1')
          expect(updated_poster.display_name).to eq('User One')
          expect(updated_poster.real_name).to eq('User 1')
          expect(response).to have_http_status(:no_content)
        end
      end
    end

    context 'Slack APIのレスポンスが不正の場合' do
      before do
        allow(SlackApiClient).to receive(:fetch_slack_users).and_raise(StandardError, 'Slack API error')
      end

      it '500が返る' do
        aggregate_failures do
          expect do
            put '/slack/posters/', as: :json
          end.not_to change(Poster, :count)

          expect(response).to have_http_status(:internal_server_error)
        end
      end
    end
  end
end
