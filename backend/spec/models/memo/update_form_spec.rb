# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Memo::UpdateForm do
  let!(:tag) { create(:tag) }
  let(:tags) { create_list(:tag, 2) }
  let!(:memo) { create(:memo) }
  let(:tag_ids) { tags.map(&:id) }

  before { create(:memo_tag, memo:, tag:) }

  describe '#バリデーション' do
    context 'フォーム入力値が有効な場合' do
      let(:params) { { title: memo.title, content: 'Updated memo content', tag_ids: } }
      let(:form) { described_class.new(params:, id: memo.id) }

      it 'フォームが有効な状態であること' do
        expect(form).to be_valid
      end
    end

    context 'フォーム入力値が無効な場合' do
      let(:params) { { title: '', content: '', tag_ids: } }
      let(:form) { described_class.new(params:, id: memo.id) }

      it 'フォームが無効な状態であり、適切なエラーメッセージが追加されていること' do
        aggregate_failures do
          expect(form).not_to be_valid
          expect(form.errors.full_messages).to eq ['メモに関連するエラーがあります']
        end
      end
    end
  end

  describe '#save' do
    context 'フォームの値が有効な場合' do
      let(:params) { { title: memo.title, content: 'Updated memo content', tag_ids: } }
      let(:form) { described_class.new(params:, id: memo.id) }

      it 'メモとタグが更新され、trueが返されること' do
        aggregate_failures do
          expect(form.save).to be true
          expect(memo.reload.content).to eq 'Updated memo content'
          expect(memo.reload.memo_tags.pluck(:tag_id)).to match_array(tag_ids)
          expect(memo.reload.memo_tags.pluck(:tag_id)).not_to include(tag.id)
        end
      end
    end

    context 'フォームの値が無効な場合' do
      let(:params) { { title: '', content: '', tag_ids: } }
      let(:form) { described_class.new(params:, id: memo.id) }

      it 'メモとタグが更新されず、falseが返されること' do
        aggregate_failures do
          expect(form.save).to be false
          expect(memo.reload.title).to eq memo.title
          expect(memo.reload.content).to eq memo.content
          expect { form.save }.not_to(change { memo.reload.memo_tags.pluck(:tag_id) })
        end
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
