# frozen_string_literal: true

class Memo
  class BuildForm
    include ActiveModel::Validations

    validates :memo, cascade: true
    validates :memo_tags, cascade: true

    def initialize(params:)
      @params = params
    end

    def save
      return false if invalid?

      ActiveRecord::Base.transaction do
        save_record!(memo)
      end

      errors.empty?
    end

    private

    attr_reader :params

    def save_record!(record)
      return true if record.save

      errors.add(:base, record.error_message)
      raise ActiveRecord::Rollback
    end

    def memo
      @memo ||= Memo.new(
        title: params[:title],
        content: params[:content],
        poster_user_key: params[:poster_user_key],
        slack_ts: params[:slack_ts]
      )
    end

    def memo_tags
      return if memo.nil?

      @memo_tags ||= build_memo_tags
    end

    def tags
      Tag.where(id: params[:tag_ids])
    end

    def build_memo_tags
      tags.map do |tag|
        memo.memo_tags.build(tag: tag)
      end
    end
  end
end
