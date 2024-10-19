# frozen_string_literal: true

json.memos @memos[:memos] do |memo|
  json.id memo.id
  json.title memo.title
  json.content memo.content
  json.poster memo.poster
  json.created_at memo.created_at
  json.updated_at memo.updated_at
  json.tag_names memo.tags.map(&:name)
end
json.total_page @memos[:total_page]
