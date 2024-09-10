# :nocov:
# テストのテストになるため
class SimpleCovFormatter
  class GroupedTable
    include CommandLineReporter

    def self.call(result) = new(result).call
    def initialize(result) = @result = result

    def call
      return unless files.any?

      matrix!

      header(title: conclusion)
    end

    private

    attr_reader :result

    def matrix!
      table(border: true) do
        row(header: true) { table_header }
        groups.each do |group_name, grouped_files|
          row { table_body(group_name, grouped_files) }
        end
      end
    end

    def root = defined?(Rails) ? Rails.root.to_s : Dir.pwd
    def files = @files ||= result.files
    def groups = files.group_by { |file| grouping(file.filename) }

    def grouping(filename)
      path = filename.sub(root, '')

      return '/lib' if path.start_with?('/lib')

      path.split('/').take(3).join('/')
    end

    def table_header
      column('Dir(s)', width: 20)
      column('Lines of Code', width: 13, align: 'right')
      column('Covered Lines', width: 13, align: 'right')
      column('L.COV', width: 9, align: 'right')
      column('Br.COV', width: 9, align: 'right')
    end

    def table_body(group_name, grouped_files)
      column(group_name)
      column(grouped_files.sum(&:lines_of_code))
      column(grouped_files.map(&:covered_lines).sum(&:size))
      column(grouped_line_coverage(grouped_files))
      column(grouped_branch_coverage(grouped_files))
    end

    def grouped_line_coverage(grouped_files)
      format(
        '%.3f%%',
        (
          grouped_files.map(&:covered_lines).sum(&:size) / \
            grouped_files.sum(&:lines_of_code).to_f * 100
        ).tap { |n| break 100.0 if n.nan? }
      )
    end

    def grouped_branch_coverage(grouped_files)
      format(
        '%.3f%%',
        (
          grouped_files.map(&:covered_branches).sum(&:size) / \
            grouped_files.map(&:total_branches).sum(&:size).to_f * 100
        ).tap { |n| break 100.0 if n.nan? }
      )
    end

    def conclusion = "#{conclusion_lines} | #{conclusion_branches}"

    def conclusion_lines
      statistic = coverage_statistics[:line]
      [
        "LINES: #{statistic.covered} / #{statistic.total}",
        "coverage: #{format('%.3f%%', statistic.percent)}"
      ].join(' ')
    end

    def conclusion_branches
      statistic = coverage_statistics[:branch]
      [
        "BRANCHES: #{statistic.covered} / #{statistic.total}",
        "coverage: #{format('%.3f%%', statistic.percent)}"
      ].join(' ')
    end

    def coverage_statistics = result.coverage_statistics
  end
end
# :nocov:
