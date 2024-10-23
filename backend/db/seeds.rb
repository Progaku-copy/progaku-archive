# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

require "faker"

# ユーザの作成
user_values = []

3.times do |n|
user_values << User.new(
  account_name: Faker::Internet.unique.username(specifier: 6..9),
  password: "test_user_test_user"
)
end
User.import user_values

# タグの作成
tag_values = []

10.times do |n|
  tag_values << Tag.new(
    name: Faker::Lorem.unique.word,
    priority: "#{n} + 1"
  )
end
Tag.import tag_values

#　メモの作成
memo_values = []

30.times do |n|
  memo_values << Memo.new(
    title: Faker::Lorem.sentence(word_count:10),
    content: Faker::Lorem.paragraphs(number: 5),
    poster: Faker::Name.name
  )
end
Memo.import memo_values

# メモのIDを取得
new_memo_ids = Memo.order(created_at: :desc).limit(30).pluck(:id)

# メモに紐づくコメントとタグを作成
comment_values = []
memo_tag_values = []
tag_lds = Tag.pluck(:id)

new_memo_ids.each do |memo_id|
  10.times do |cn|
    comment_values << Comment.new(
      memo_id: memo_id,
      content: Faker::Lorem.sentence(word_count:10),
      poster: Faker::Name.name
    )
  end
  3.times do |tn|
    memo_tag_values << MemoTag.new(
      memo_id: memo_id,
      tag_id: tag_lds[tn]
    )
  end
end
Comment.import comment_values
MemoTag.import memo_tag_values
