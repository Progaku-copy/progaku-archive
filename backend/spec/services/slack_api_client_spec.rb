# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SlackApiClient do
  describe '#fetch_archive_posts' do
    subject(:posts) { described_class.fetch_archive_posts(channel) }

    before do
      allow(described_class).to receive(:fetch_data).and_return({ 'messages' => messages })
      allow(described_class).to receive(:replace_user_mentions) { |text| text }
    end

    context '通常チャンネル（リアクション必須）の場合' do
      let(:channel) { { channel_id: 'C000000001', tag_id: 1 } }

      context 'アーカイブリアクションが付いているとき' do
        let(:messages) do
          [
            {
              'text' => 'Hello',
              'user' => 'U123',
              'ts' => '123.000',
              'thread_ts' => nil,
              'reactions' => [
                {
                  'name' => Rails.application.config.slack[:archive_reaction]
                }
              ]
            }
          ]
        end

        it '投稿を取り込む' do
          expect(posts.length).to eq(1)
        end
      end

      context 'アーカイブリアクションが付いていないとき' do
        let(:messages) do
          [
            {
              'text' => 'Hello',
              'user' => 'U123',
              'ts' => '123.000',
              'thread_ts' => nil,
              'reactions' => []
            }
          ]
        end

        it '投稿をスキップする' do
          expect(posts).to be_empty
        end
      end
    end

    context 'force_importが有効なチャンネルの場合' do
      let(:channel) { { channel_id: 'C_FORCE', tag_id: 5, force_import: true } }
      let(:messages) do
        [
          {
            'text' => 'Force import me',
            'user' => 'U999',
            'ts' => '999.000',
            'thread_ts' => nil,
            'reactions' => []
          }
        ]
      end

      it 'リアクション無しでも投稿を取り込む' do
        expect(posts.length).to eq(1)
      end
    end
  end
end
