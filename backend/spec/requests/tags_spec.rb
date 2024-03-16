# frozen_string_literal: true

RSpec.describe 'MemosController' do
  describe 'POST /tags' do
    let(:memo) { create(:memo) }
    let(:params) { { tag: { name: 'タグ名称' }, memo_id: memo.id } }

    subject { post '/tags', params: }

    context '正常なパラメータが送られた場合' do
      it 'tagsレコードが作成されること' do
        expect { subject }.to change { memo.reload.tags.count }.by(1)
      end

      it '204になること' do
        aggregate_failures do
          subject
          expect(response).to have_http_status(:no_content)
          expect(response.body).to be_empty
        end
      end
    end

    context 'バリデーションエラーになる場合' do
      let(:params) { { tag: { name: '' }, memo_id: memo.id } }

      it 'レコードが作成されないこと' do
        expect { subject }.to change { memo.reload.tags.count }.by(0)
      end

      it 'バリデーションエラーが返ること, 422になること' do
        aggregate_failures do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include("#{Tag.human_attribute_name(:name)}#{I18n.t('errors.messages.blank')}")
        end
      end
    end

    context 'メモIDが存在しない場合' do
      let(:params) { { tag: { name: 'タグ名称' }, memo_id: nil } }

      it 'レコードが作成されないこと' do
        expect { subject }.to change { memo.reload.tags.count }.by(0)
      end

      it '404が返ること' do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
