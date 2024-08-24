# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id                   :bigint           not null, primary key
#  name(タグ名)         :string(30)       not null
#  priority(タグの順番) :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_tags_on_name      (name) UNIQUE
#  index_tags_on_priority  (priority)
#

FactoryBot.define do
  factory :tag do
    name { Faker::Lorem.sentence(word_count: 1) }
    sequence(:priority) { |n| n }
  end
end
