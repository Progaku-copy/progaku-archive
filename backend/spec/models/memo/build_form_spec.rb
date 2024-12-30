# frozen_string_literal: true

RSpec.describe Memo::BuildForm do
  let!(:tags) { create_list(:tag, 3) }
  let(:tag_ids) { tags.map(&:id) }
  let!(:poster) { create(:poster) }

  describe '#バリデーション' do
    context 'フォーム入力値が有効な場合' do
      let(:params) do
        { title: 'Test Memo',
          content: 'This is a test memo',
          poster_user_key: poster.user_key,
          slack_ts: Faker::Number.decimal(l_digits: 10, r_digits: 6),
          tag_ids: }
      end
      let(:form) { described_class.new(params:) }

      it 'フォームが有効な状態であること' do
        expect(form).to be_valid
      end
    end

    context 'フォーム入力値が無効な場合' do
      let(:params) { { title: '', content: '', tag_ids: } }
      let(:form) { described_class.new(params:) }

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
      let(:params) do
        { title: 'Test Memo',
          content: 'This is a test memo',
          poster_user_key: poster.user_key,
          slack_ts: Faker::Number.decimal(l_digits: 10, r_digits: 6),
          tag_ids: }
      end
      let(:form) { described_class.new(params:) }

      it 'メモが新規作成され、タグが紐付けられ、trueが返されること' do
        aggregate_failures do
          expect { form.save }.to change { [Memo.count, MemoTag.count] }.by([1, 3])
          expect(Memo.last.tags.pluck(:id)).to match_array(tag_ids)
          expect(form.save).to be_truthy
        end
      end
    end

    context 'フォームの値が無効な場合' do
      let(:params) { { title: '', content: 'This is a test memo', tag_ids: } }
      let(:form) { described_class.new(params:) }

      it 'メモとメモタグが新規作成されず、falseが返されること' do
        aggregate_failures do
          expect { form.save }.not_to(change { [Memo.count, MemoTag.count] })
          expect(form.save).to be_falsey
        end
      end
    end
  end
end
