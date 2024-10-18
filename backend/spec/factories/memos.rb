# frozen_string_literal: true

# == Schema Information
#
# Table name: memos
#
#  id                        :bigint           not null, primary key
#  content(メモの本文)       :text(65535)      not null
#  poster(Slackのユーザー名) :string(50)       not null
#  title(メモのタイトル)     :string(255)      not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
FactoryBot.define do
  factory :memo do
    title { Faker::Lorem.sentence(word_count: 3) }
    content { Faker::Lorem.paragraph(sentence_count: 5) }
    poster { Faker::Name.name }

    trait :with_tags do
      after :create do |memo|
        create_list(:memo_tag, 3, memo: memo)
      end
    end
  end
end
