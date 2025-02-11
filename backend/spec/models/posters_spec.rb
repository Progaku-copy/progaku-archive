# frozen_string_literal: true
# # frozen_string_literal: true
#
# # == Schema Information
# #
# # Table name: posters
# #
# #  id                              :bigint           not null, primary key
# #  user_key(ユーザーキー)          :string           not null
# #  display_name(表示名)            :string
# #  real_name(本名)                 :string
# #  created_at                      :datetime         not null
# #  updated_at                      :datetime         not null
# #
# # Indexes
# #
# #  index_posters_on_user_key  (user_key) UNIQUE
# #
#
# RSpec.describe Poster do
#   let(:poster) { build(:poster) }
#
#   describe 'バリデーションのテスト' do
#     context 'user_key が有効な場合' do
#       it 'valid?メソッドがtrueを返す' do
#         expect(poster).to be_valid
#       end
#     end
#
#     context 'user_key が空文字の場合' do
#       before { poster.user_key = '' }
#
#       it 'valid?メソッドがfalseを返し、エラーメッセージが格納される' do
#         aggregate_failures do
#           expect(poster).not_to be_valid
#           poster.valid?
#           expect(poster.errors.full_messages).to eq(['SlackのユーザーIDを入力してください'])
#         end
#       end
#     end
#
#     context 'user_key が重複している場合' do
#       before { create(:poster, user_key: poster.user_key) }
#
#       it 'valid?メソッドがfalseを返し、エラーメッセージが格納される' do
#         aggregate_failures do
#           expect(poster).not_to be_valid
#           poster.valid?
#           expect(poster.errors.full_messages).to eq(['SlackのユーザーIDはすでに存在します'])
#         end
#       end
#     end
#   end
#
#   describe 'build_from_slack_postersのテスト' do
#     let(:default_name) { 'unknown' }
#
#     context '全てのデータに値が設定されている場合' do
#       let(:slack_posters) do
#         [
#           { 'id' => 'user1', 'profile' => { 'display_name' => 'User One' }, 'real_name' => 'User 1' },
#           { 'id' => 'user2', 'profile' => { 'display_name' => 'User Two' }, 'real_name' => 'User 2' }
#         ]
#       end
#
#       it 'Slackのユーザ情報からuser_key,display_name,real_nameを抽出したインスタンス配列が返る' do
#         result = described_class.build_from_slack_posters
#
#         aggregate_failures do
#           expect(result.size).to eq(2)
#           expect(result.first.user_key).to eq('user1')
#           expect(result.first.display_name).to eq('User One')
#           expect(result.first.real_name).to eq('User 1')
#           expect(result.second.user_key).to eq('user2')
#           expect(result.second.display_name).to eq('User Two')
#           expect(result.second.real_name).to eq('User 2')
#         end
#       end
#     end
#
#     context 'idがnilのデータが含まれる場合' do
#       let(:slack_posters) do
#         [
#           { 'id' => 'user1', 'profile' => { 'display_name' => 'User One' }, 'real_name' => 'User 1' },
#           { 'id' => nil, 'profile' => { 'display_name' => 'User Invalid' }, 'real_name' => 'Invalid' }
#         ]
#       end
#
#       it 'nilが除去され、有効なデータのみ配列に含まれる' do
#         result = described_class.build_from_slack_posters
#
#         aggregate_failures do
#           expect(result.size).to eq(1)
#           expect(result.first.user_key).to eq('user1')
#           expect(result.first.display_name).to eq('User One')
#           expect(result.first.real_name).to eq('User 1')
#         end
#       end
#     end
#
#     context '名前が空のデータが含まれる場合' do
#       let(:slack_posters) do
#         [
#           { 'id' => 'user1', 'profile' => { 'display_name' => '' }, 'real_name' => '' }
#         ]
#       end
#
#       it '空の名前がデフォルト値に置き換えられる' do
#         result = described_class.build_from_slack_posters
#
#         aggregate_failures do
#           expect(result.size).to eq(1)
#           expect(result.first.user_key).to eq('user1')
#           expect(result.first.display_name).to eq('unknown')
#           expect(result.first.real_name).to eq('unknown')
#         end
#       end
#     end
#   end
# end
