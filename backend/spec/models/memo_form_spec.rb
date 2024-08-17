# frozen_string_literal: true

RSpec.describe MemoForm do
  let(:memo) { build(:memo) }
  let!(:tags) { create_list(:tag, 3) }
  let(:tag_ids) { tags.map(&:id) }

  describe '#バリデーション' do
    context 'フォームの値が有効な場合' do
      let(:valid_attributes) { { title: 'Test Memo', content: 'This is a test memo', tag_ids: tag_ids } }
      let(:form) { described_class.new(valid_attributes, memo: memo) }

      specify '有効な状態であること' do
        expect(form).to be_valid
      end
    end

    context 'メモのタイトルが空文字の場合' do
      let(:invalid_attributes) { { title: '', content: 'This is a test memo', tag_ids: tag_ids } }
      let(:form) { described_class.new(invalid_attributes, memo: memo) }

      specify '無効な状態であること' do
        expect(form).not_to be_valid
      end

      specify '適切なエラーメッセージが追加されていること' do
        form.valid?
        expect(form.errors.full_messages).to eq ['タイトルを入力してください']
      end
    end

    context 'メモの内容が空文字の場合' do
      let(:invalid_attributes) { { title: 'Test Memo', content: '', tag_ids: tag_ids } }
      let(:form) { described_class.new(invalid_attributes, memo: memo) }

      specify '無効な状態であること' do
        expect(form).not_to be_valid
      end

      specify '適切なエラーメッセージが追加されていること' do
        form.valid?
        expect(form.errors.full_messages).to eq ['コンテンツを入力してください']
      end
    end

    # rubocop:disable RSpec/MultipleMemoizedHelpers
    context 'タグが存在しない場合' do
      let(:invalid_tag_ids) { tag_ids + [999, 1000, 1001] }
      let(:invalid_tag_names) { Tag.where(id: invalid_tag_ids).pluck(:name) }
      let(:invalid_attributes) { { title: 'Test Memo', content: 'This is a test memo', tag_ids: invalid_tag_ids } }
      let(:form) { described_class.new(invalid_attributes, memo: memo) }

      specify '無効な状態であること' do
        expect(form).not_to be_valid
      end

      specify '適切なエラーメッセージが追加されていること' do
        form.valid?
        expect(form.errors.full_messages).to eq ['タグに無効なものが含まれています']
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers

  describe '#save' do
    context 'フォームの値が有効な場合' do
      let(:valid_attributes) { { title: 'Test Memo', content: 'This is a test memo', tag_ids: tag_ids } }
      let(:form) { described_class.new(valid_attributes, memo: memo) }

      specify 'メモが新規作成されること' do
        expect { form.save }.to change(Memo, :count).by(1)
      end

      specify 'メモにタグが紐付けられること' do
        form.save
        expect(memo.tags.pluck(:id)).to match_array(tag_ids)
      end

      specify 'trueが返されること' do
        expect(form.save).to be_truthy
      end
    end

    context 'フォームの値が無効な場合' do
      let(:invalid_attributes) { { title: '', content: 'This is a test memo', tag_ids: tag_ids } }
      let(:form) { described_class.new(invalid_attributes, memo: memo) }

      it 'メモが新規作成されないこと' do
        expect { form.save }.not_to(change(Memo, :count))
      end

      it 'メモにタグが紐付けられないこと' do
        form.save
        expect(memo.tags).to be_empty
      end

      it 'falseが返されること' do
        expect(form.save).to be_falsey
      end
    end
  end
end
