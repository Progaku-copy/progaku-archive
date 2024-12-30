# db/seeds.rb

require "faker"

# ユーザの作成
user_values = []
3.times do
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
    priority: n + 1
  )
end
Tag.import tag_values

# Posterの作成
poster_values = []
10.times do
  poster_values << Poster.new(
    user_key: Faker::Base.bothify("U###D##???#"),
    display_name: Faker::Name.name,
    real_name: Faker::Name.name
  )
end
Poster.import poster_values

# 作成したPosterのuser_key一覧を取得 (MemoやCommentで使う)
poster_user_keys = Poster.pluck(:user_key)

# メモの作成
memo_values = []
30.times do
  memo_values << Memo.new(
    title: Faker::Lorem.sentence(word_count: 10),
    content: Faker::Lorem.paragraphs(number: 5).join("\n\n"),
    # paragraphsは配列が返るためjoinして文字列に
    poster_user_key: poster_user_keys.sample, # Posterのuser_keyをランダムに割当
    slack_ts: Faker::Number.decimal(l_digits: 10, r_digits: 6)
  )
end
Memo.import memo_values

# 新規に作成したMemoのID一覧を取得
new_memo_ids = Memo.order(created_at: :desc).limit(30).pluck(:id)

# メモに紐づくコメントとタグを作成
comment_values = []
memo_tag_values = []
tag_ids = Tag.pluck(:id)

new_memo_ids.each do |memo_id|
  # Comment
  10.times do
    comment_values << Comment.new(
      memo_id: memo_id,
      content: Faker::Lorem.sentence(word_count: 10),
      poster_user_key: poster_user_keys.sample,  # Posterのuser_keyをランダムに割当
      slack_parent_ts: Faker::Number.decimal(l_digits: 10, r_digits: 6)
    )
  end

  # MemoTag
  3.times do |tn|
    memo_tag_values << MemoTag.new(
      memo_id: memo_id,
      tag_id: tag_ids[tn]
    )
  end
end

Comment.import comment_values
MemoTag.import memo_tag_values
