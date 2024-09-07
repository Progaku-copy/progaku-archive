# == Schema Information
#
# Table name: users
#
#  id                                  :bigint           not null, primary key
#  account_name(ユーザーの名前)        :string(60)       not null
#  admin(管理者フラグ)                 :boolean          default(FALSE), not null
#  password_digest(ユーザーのpassword) :string(60)       not null
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#
# Indexes
#
#  index_users_on_account_name  (account_name) UNIQUE
#
RSpec.describe User do
  subject(:user) { build(:user) }

  describe "バリデーションのテスト" do
    context "account_name と password が有効な場合" do
      it "valid?メソッドがtrueを返す" do
        expect(user).to be_valid
      end
    end

    context "account_name が空文字の場合" do
      before { user.account_name = "" }

      it "valid?メソッドがfalseを返す" do
        expect(user).not_to be_valid
      end

      it "errorsに「アカウント名を入力してください」と格納される" do
        user.valid?
        expect(user.errors.full_messages).to include("アカウント名を入力してください")
      end
    end

    context "account_name が6文字未満の場合" do
      before { user.account_name = Faker::Lorem.characters(number: 5) }

      it "valid?メソッドがfalseを返す" do
        expect(user).not_to be_valid
      end

      it "errorsに「アカウント名は6文字以上で入力してください」と格納される" do
        user.valid?
        expect(user.errors.full_messages).to include("アカウント名は6文字以上で入力してください")
      end
    end

    context "account_name が31文字以上の場合" do
      before { user.account_name = Faker::Lorem.characters(number: 31) }

      it "valid?メソッドがfalseを返す" do
        expect(user).not_to be_valid
      end

      it "errorsに「アカウント名は30文字以内で入力してください」と格納される" do
        user.valid?
        expect(user.errors.full_messages).to include("アカウント名は30文字以内で入力してください")
      end
    end

    context "account_name が重複している場合" do
      before { create(:user, account_name: user.account_name) }

      it "valid?メソッドがfalseを返す" do
        expect(user).not_to be_valid
      end

      it "errorsに「アカウント名はすでに存在します」と格納される" do
        user.valid?
        expect(user.errors.full_messages).to include("アカウント名はすでに存在します")
      end
    end
  end

  context "password が有効な場合" do
    it "valid?メソッドがtrueを返す" do
      expect(user).to be_valid
    end
  end

  context "passwordがnilの場合" do
    before do
      user.password = nil
    end

    it "valid?メソッドがfalseを返す" do
      expect(user).not_to be_valid
    end
  end

  context "password が6文字未満の場合" do
    before { user.password = Faker::Lorem.characters(number: 5) }

    it "valid?メソッドがfalseを返す" do
      expect(user).not_to be_valid
    end
  end

  context "password が13文字以上の場合" do
    before { user.password = Faker::Lorem.characters(number: 13) }

    it "valid?メソッドがfalseを返す" do
      expect(user).not_to be_valid
    end
  end
end
