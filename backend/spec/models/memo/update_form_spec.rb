# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Memo::UpdateForm do
  let!(:tag) { create(:tag) }
  let(:tags) { create_list(:tag, 2) }
  let!(:memo) { create(:memo) }
  let(:tag_ids) { tags.map(&:id) }

  before { create(:memo_tag, memo: memo, tag: tag) }

  describe '#バリデーション' do
    context 'フォームの値が有効な場合' do
      let(:params) { { content: 'Updated memo content', tag_ids: tag_ids } }
      let(:memo_update_form) { described_class.new(params: params, memo: memo) }

      specify '有効な状態であること' do
        expect(memo_update_form).to be_valid
      end

      specify 'メモの内容が更新されること' do
        expect { memo_update_form.save }.to change { memo.reload.content }.to('Updated memo content')
      end

      specify 'メモのタグが更新されること' do
        memo_update_form.save
        expect(memo.reload.tags.pluck(:id)).to match_array(tag_ids)
      end
    end

    context 'メモの内容が空文字の場合' do
      let(:params) { { content: '', tag_ids: tag_ids } }
      let(:memo_update_form) { described_class.new(params: params, memo: memo) }

      specify '無効な状態であること' do
        expect(memo_update_form).not_to be_valid
      end

      specify '適切なエラーメッセージが追加されていること' do
        memo_update_form.valid?
        expect(memo_update_form.errors.full_messages).to eq ['コンテンツを入力してください']
      end
    end
  end

  describe '#save' do
    context 'フォームの値が有効な場合' do
      let(:params) { { content: 'Updated memo content', tag_ids: tag_ids } }
      let(:memo_update_form) { described_class.new(params: params, memo: memo) }

      specify 'メモの内容が更新されること' do
        expect { memo_update_form.save }.to change { memo.reload.content }.to('Updated memo content')
      end

      specify 'メモのタグが更新されること' do
        memo_update_form.save
        expect(memo.reload.tags.pluck(:id)).to match_array(tag_ids)
      end

      specify 'trueが返されること' do
        expect(memo_update_form.save).to be_truthy
      end
    end

    context 'フォームの値が無効な場合' do
      let(:params) { { content: '', tag_ids: tag_ids } }
      let(:memo_update_form) { described_class.new(params: params, memo: memo) }

      specify 'メモの内容が更新されないこと' do
        expect { memo_update_form.save }.not_to(change { memo.reload.content })
      end

      specify 'falseが返されること' do
        expect(memo_update_form.save).to be_falsey
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
