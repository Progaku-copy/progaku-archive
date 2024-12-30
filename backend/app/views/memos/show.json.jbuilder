# frozen_string_literal: true

json.memo do
  json.id @memo.id
  json.title @memo.title
  json.content @memo.content
  json.poster(@memo.poster.display_name.presence || @memo.poster.real_name)
  json.created_at @memo.created_at
  json.updated_at @memo.updated_at

  json.tags @memo.tags do |tag|
    json.id tag.id
    json.name tag.name
  end

  json.comments @comments do |comment|
    json.id comment.id
    json.content comment.conte
    json.poster(comment.poster.display_name.presence || comment.poster.real_name)
    json.created_at comment.created_at
    json.memo_id comment.memo_id
  end
end
