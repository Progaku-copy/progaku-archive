# frozen_string_literal: true

json.memos @memos[:memos] do |memo|
  json.id memo.id
  json.title memo.title
  json.content memo.content
  json.poster(memo.poster.display_name.presence || memo.poster.real_name)
  json.created_at memo.created_at
  json.updated_at memo.updated_at
  json.tags memo.tags do |tag|
    json.id tag.id
    json.name tag.name
  end
end
json.total_page @memos[:total_page]
