# frozen_string_literal: true

json.memos @memos[:memos] do |memo|
  json.id memo.id
  json.title memo.title
  json.content memo.content
  json.poster(memo.poster.display_name.presence&.downcase == 'unknown' ? memo.poster.real_name : memo.poster.display_name)
  json.slack_posted_at memo.slack_posted_at&.iso8601(6)
  json.tags memo.tags do |tag|
    json.id tag.id
    json.name tag.name
  end
end
json.total_page @memos[:total_page]
