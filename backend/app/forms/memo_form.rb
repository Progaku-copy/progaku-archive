# frozen_string_literal: true

class MemoForm
  include ActiveModel::Model

  attr_accessor :title, :content, :tag_ids

  validates :title, presence: true
  validates :content, presence: true
  validate :tag_ids_must_exist

  def initialize(attributes = nil, memo: Memo.new)
    @memo = memo
    attributes = default_attributes.merge(attributes)
    super(attributes)
  end

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      memo.update!(title: title, content: content)
      memo.memo_tags.destroy_all
      tag_ids.each do |tag_id|
        memo.memo_tags.create!(tag_id: tag_id)
      end
    end
  end

  private

  attr_reader :memo

  def default_attributes
    {
      title: memo.title,
      content: memo.content,
      tag_ids: memo.tags.pluck(:id)
    }
  end

  def tag_ids_must_exist
    return if tag_ids.blank?

    return unless Tag.where(id: tag_ids).count != tag_ids.size

    errors.add(:tag_ids, 'に無効なものが含まれています')
  end
end
