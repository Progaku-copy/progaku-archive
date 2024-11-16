# frozen_string_literal: true

# == Schema Information
#
# Table name: posters
#
#  id                              :bigint           not null, primary key
#  display_name(slack上での表示名) :string(255)
#  real_name(slack上での本名)      :string(255)
#  user_key(slack上でのuser.id)    :string(255)      not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#
# Indexes
#
#  index_posters_on_user_key  (user_key) UNIQUE
#
FactoryBot.define do
  factory :poster do
    user_key { SecureRandom.uuid } # 一意の値を生成
    display_name { Faker::Name.name  }
    real_name { Faker::Name.name }
  end
end
