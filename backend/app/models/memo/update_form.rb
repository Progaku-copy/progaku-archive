# frozen_string_literal: true

class Memo
  class UpdateForm
    include ActiveModel::Validations

    validates :memo, cascade: true
    validates :memo_tags, cascade: true, if: -> { errors.empty? }

    def initialize(params:, id:)
      @params = params
      @id = id
    end

    def save
      return false if invalid?

      ActiveRecord::Base.transaction do
        save_record!(memo)
        memo.memo_tags.select(&:marked_for_destruction?)
            .each { destroy_record!(_1) }
      end

      errors.empty?
    end

    private

    attr_reader :params, :id

    def save_record!(record)
      return true if record.save

      errors.add(:base, record.error_message)
      raise ActiveRecord::Rollback
    end

    def destroy_record!(record)
      return true if record.destroy

      errors.add(:base, record.error_message)
      raise ActiveRecord::Rollback
    end

    def memo
      @memo ||= \
        Memo.find(id)
            .tap do |model|
              model.assign_attributes(
                title: params[:title],
                content: params[:content],
                tags: tags
              )
            end
    end

    def memo_tags
      @memo_tags ||= memo.tap do |_model|
        mark_for_destruction_memo_tags!
      end.memo_tags.reject(&:marked_for_destruction?)
    end

    def tag_ids = params[:tag_ids] || []

    def tags = Tag.where(id: tag_ids)

    def before_save_tag_ids
      @before_save_tag_ids ||= memo.memo_tags.pluck(:tag_id)
    end

    def destroy_target_tag_ids = before_save_tag_ids - tag_ids

    def mark_for_destruction_memo_tags!
      memo.memo_tags.each do |memo_tag|
        next unless destroy_target_tag_ids.include?(memo_tag.tag_id)

        memo_tag.mark_for_destruction
      end
    end
  end
end
