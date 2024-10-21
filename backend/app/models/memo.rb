# frozen_string_literal: true

# == Schema Information
#
# Table name: memos
#
#  id                        :bigint           not null, primary key
#  content(メモの本文)       :text(65535)      not null
#  poster(Slackのユーザー名) :string(50)       not null
#  title(メモのタイトル)     :string(255)      not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
class Memo < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true
  validates :poster, presence: true, length: { maximum: 50 }
  has_many :comments, dependent: :destroy
  has_many :memo_tags, dependent: :destroy
  has_many :tags, through: :memo_tags

  module Query
    FILTERS = %i[TitleFilter ContentFilter OrderFilter TagFilter].freeze
    private_constant :FILTERS
    FIRST_PAGE = 1
    private_constant :FIRST_PAGE

    class << self
      # メモのフィルダリングとページネーションを行う
      # @param filter_collection [ActiveRecord::Relation[Memo]]:メモのリスト
      # @param params [ActionController::Parameters]: クエリパラメータ
      # @return [Array] フィルタリングされたメモのリスト、メモの総数、ページ数、現在のページ番号
      def call(filter_collection:, params:)
        memo_relation = \
          filtered_memos(
            filter_collection: filter_collection,
            params: params
          )
        memo_count = memo_relation.count
        { memos: PageFilter.resolve(scope: memo_relation, params: params),
          total_page: memo_count.zero? ? FIRST_PAGE : (memo_count / PageFilter::MAX_ITEMS).ceil }
      end

      private

      # 各フィルタを順次適用してメモをフィルタリングする
      def filtered_memos(filter_collection:, params:)
        FILTERS.reduce(filter_collection) do |scope, filter|
          const_get(filter).resolve(scope: scope, params: params)
        end
      end

      # ページ番号を取得する。ページ番号が指定されていない場合は最初のページを返す
      def page_number(page)
        return Integer(page) if page.present?

        FIRST_PAGE
      end
    end

    module TitleFilter
      # params[:title] に値が存在する場合、タイトルに部分一致するメモを返す
      def self.resolve(scope:, params:)
        return scope if params[:title].blank?

        scope.where('title LIKE ?', "%#{params[:title]}%")
      end
    end
    private_constant :TitleFilter

    module ContentFilter
      # params[:content] に値が存在する場合、本文に部分一致するメモを返す
      def self.resolve(scope:, params:)
        return scope if params[:content].blank?

        scope.where('content LIKE ?', "%#{params[:content]}%")
      end
    end
    private_constant :ContentFilter

    module TagFilter
      # params[:tag] に値が存在する場合、タグが一致するメモを返す
      def self.resolve(scope:, params:)
        return scope if params[:tag_ids].blank?

        scope.joins(:tags).where(tags: { id: params[:tag_ids] })
      end
    end
    private_constant :TagFilter

    module OrderFilter
      DEFAULT_ORDER = 'desc'
      private_constant :DEFAULT_ORDER

      # params[:order] に値が存在する場合、指定された順序でメモを返す
      def self.resolve(scope:, params:)
        scope.order(id: params[:order].presence || DEFAULT_ORDER)
      end
    end
    private_constant :OrderFilter

    module PageFilter
      MAX_ITEMS = 10.0
      public_constant :MAX_ITEMS

      # params[:page] に基づいて指定されたページの範囲のメモを返す
      def self.resolve(scope:, params:)
        return scope.limit(MAX_ITEMS) if params[:page].blank?

        target_page = Integer(params[:page], 10, exception: false) || params[:page]
        raise TypeError unless target_page.is_a?(Integer)

        [target_page - 1, 0].max.then do |page|
          scope.offset(MAX_ITEMS * page).limit(MAX_ITEMS)
        end
      end
    end
    private_constant :PageFilter
  end
end
