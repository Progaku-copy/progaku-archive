# frozen_string_literal: true

class Memo::UpdateForm
  include ActiveModel::Validations

  attr_reader :params, :memo

  validate :memo_valid?

  def initialize(params:, memo:)
    @params = params
    @memo = memo
  end

  def update
    return false unless valid?

    resolve_memo_tags

    ActiveRecord::Base.transaction do
      memo.update!(content: params[:content])
    end
  end

  private

  def memo_valid?
    memo.assign_attributes(content: params[:content])
    return if memo.valid?

    memo.errors.each { |error| errors.add(:base, error.full_message) }
  end

  def resolve_memo_tags
    memo.memo_tags.destroy_all
    tags = Tag.where(id: params[:tag_ids])
    tags.each do |tag|
      memo.memo_tags.build(tag: tag)
    end
  end
end
