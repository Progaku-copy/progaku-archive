# frozen_string_literal: true

class Memo
  class UpdateForm
    include ActiveModel::Validations

    validates :memo, cascade: true
    validates :memo_tags_to_add, cascade: true, if: -> { errors.empty? }

    def initialize(params:, id:)
      @params = params
      @id = id
    end

    def save
      return false if invalid?

      ActiveRecord::Base.transaction do
        save_record!(memo)
        memo_tags_to_remove.destroy_all
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

    def memo
      @memo ||= \
        Memo.find(id)
            .tap do |model|
              model.assign_attributes(
                title: params[:title] || model.title,
                content: params[:content] || model.content,
                tags: tags
              )
            end
    end

    def tags = Tag.where(id: params[:tag_ids])

    def memo_tags_to_remove
      current_tag_ids = memo.memo_tags.pluck(:tag_id)
      tag_ids_to_remove = current_tag_ids - (params[:tag_ids] || [])
      memo.memo_tags.where(tag_id: tag_ids_to_remove)
    end

    def memo_tags_to_add
      current_tag_ids = memo.memo_tags.pluck(:tag_id)
      tag_ids_to_add = (params[:tag_ids] || []) - current_tag_ids
      @memo_tags_to_add = tag_ids_to_add.map { |tag_id| memo.memo_tags.build(tag_id: tag_id) }
    end
  end
end
