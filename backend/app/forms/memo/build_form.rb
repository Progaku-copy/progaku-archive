# frozen_string_literal: true

class Memo::BuildForm
  include ActiveModel::Validations

  attr_reader :params

  validate :memo_valid?

  def initialize(params:)
    @params = params
  end

  def memo
    @memo ||= Memo.new(
      title: params[:title],
      content: params[:content]
    )
  end

  def save
    return false unless valid?

    resolve_memo_tags

    ActiveRecord::Base.transaction do
      memo.save!
    end
  end

  private

  def memo_valid?
    return if memo.valid?

    memo.errors.each { |error| errors.add(:base, error.full_message) }
  end

  def resolve_memo_tags
    tags = Tag.where(id: params[:tag_ids])
    tags.each do |tag|
      memo.memo_tags.build(tag: tag)
    end
  end
end
