# frozen_string_literal: true

json.memo do
  json.id @memo.id
  json.title @memo.title
  json.content @memo.content
  json.poster(@memo.poster.display_name.presence&.downcase == 'unknown' ? @memo.poster.real_name : @memo.poster.display_name)
  json.slack_posted_at @memo.slack_posted_at&.iso8601(6)

  json.tags @memo.tags do |tag|
    json.id tag.id
    json.name tag.name
  end

  json.comments @comments do |comment|
    json.id comment.id
    json.content comment.content
    json.poster(comment.poster.display_name.presence&.downcase == 'unknown' ? comment.poster.real_name : comment.poster.display_name)
    json.slack_posted_at comment.slack_posted_at&.iso8601(6)
    json.memo_id comment.memo_id
  end
end
