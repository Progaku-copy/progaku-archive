# frozen_string_literal: true

RSpec.describe 'Tags' do
  let!(:tag1) { create(:tag, priority: 2) }
  let!(:tag2) { create(:tag, priority: 1) }
  let!(:tag3) { create(:tag, priority: 3) }
  let(:tags) { [tag1, tag2, tag3] }
  let(:tag_id) { tag1.id }

  def json
    response.parsed_body
  end

  describe 'GET /tags' do
    before { get tags_path }

    it 'タグ一覧でタグIDを返す' do
      tag_ids = tags.map(&:id)
      json.each do |tag|
        expect(tag_ids).to include(tag['id'])
      end
    end

    it 'タグ一覧でタグ名を返す' do
      tag_names = tags.map(&:name)
      json.each do |tag|
        expect(tag_names).to include(tag['name'])
      end
    end

    it 'タグ一覧でタグを昇順で返す' do
      tag_priorities = tags.map(&:priority)
      expect(json.map { |tag| tag['priority'] }).to eq(tag_priorities.sort)
    end

    it 'タグ数が正しい' do
      expect(json.size).to eq(3)
    end

    it 'ステータスコード200を返す' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /tags' do
    context 'リクエストが有効な場合' do
      it 'タグが作成される' do
        expect do
          post tags_path, params: { tag: { name: 'New Tag', priority: 1 } }
        end.to change(Tag, :count).by(1)
      end

      it 'ステータスコード201を返す' do
        post tags_path, params: { tag: { name: 'New Tag', priority: 1 } }
        expect(response).to have_http_status(:created)
      end
    end

    context 'リクエストが無効な場合' do
      it 'タグが作成されない' do
        expect do
          post tags_path, params: { tag: { name: '' } }
        end.not_to change(Tag, :count)
      end

      it 'ステータスコード422を返す' do
        post tags_path, params: { tag: { name: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'バリデーション失敗メッセージを返す' do
        post tags_path, params: { tag: { name: '' } }
        expect(response.body).to match('タグ名を入力してください')
      end
    end
  end

  describe 'PUT /tags/:id' do
    context 'レコードが存在する場合' do
      before { put tag_path(tag_id), params: { tag: { name: 'Update Tag' } } }

      it 'レコードを更新される' do
        expect(json['name']).to eq('Update Tag')
      end

      it 'ステータスコード200を返す' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'レコードが存在しない場合' do
      let(:tag_id) { 100 }

      before { put tag_path(tag_id), params: { tag: { name: 'Update Tag'   } } }

      it 'ステータスコード404を返す' do
        expect(response).to have_http_status(:not_found)
      end

      it '見つからないメッセージを返す' do
        expect(response.body).to match(/Couldn't find Tag/)
      end
    end

    context 'リクエストが無効な場合' do
      before { put tag_path(tag_id), params: { tag: { name: '' } } }

      it 'ステータスコード422を返す' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'バリデーション失敗メッセージを返す' do
        expect(response.body).to match('タグ名を入力してください')
      end
    end
  end

  describe 'DELETE /tags/:id' do
    context 'レコードが存在する場合' do
      it 'タグが削除される' do
        expect do
          delete tag_path(tag_id)
        end.to change(Tag, :count).by(-1)
      end

      it 'ステータスコード204を返す' do
        delete tag_path(tag_id)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'レコードが存在しない場合' do
      let(:tag_id) { 100 }

      it 'タグが削除されない' do
        expect do
          delete tag_path(tag_id)
        end.not_to change(Tag, :count)
      end

      it 'ステータスコード404を返す' do
        delete tag_path(tag_id)
        expect(response).to have_http_status(:not_found)
      end

      it '見つからないメッセージを返す' do
        delete tag_path(tag_id)
        expect(response.body).to match(/Couldn't find Tag/)
      end
    end
  end
end
