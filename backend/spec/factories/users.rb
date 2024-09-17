# frozen_string_literal: true

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
FactoryBot.define do
  factory :user do
    sequence(:account_name) { "User-#{_1}" }
    password { 'password_password' }
  end
end
