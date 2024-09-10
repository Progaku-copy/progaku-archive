# :nocov:
# テストのテストになるため
class SimpleCovFormatter
  class AwkwardTable
    include CommandLineReporter
    COVERED_LINES_THRESHOLD = 80
    COVERED_BRANCHES_THRESHOLD = 80

    def self.project_root = defined?(Rails) ? Rails.root.to_s : Dir.pwd
    def self.call(result) = new(result).call
    def initialize(result) = @result = result

    def call
      return unless files.any?

      table(border: true) do
        row(header: true) { table_header }
        files.each { |file| row { table_body(file) } }
      end
    end

    private

    attr_reader :result

    def cov_env = @cov_env ||= ENV.fetch('COVERAGE', nil)

    def files
      return specific_file if specific_test?

      @files ||= \
        awkward_files
        .sort_by { |f| (f.missed_lines.size + f.missed_branches.size) * -1 }
        .first(20)
    end

    def awkward_files
      result.files.select do |f|
        cov_env || \
          f.covered_percent < COVERED_LINES_THRESHOLD || \
          f.branches_coverage_percent < COVERED_BRANCHES_THRESHOLD
      end
    end

    def specific_test?
      defined?(RSpec) && \
        RSpec.world
             .instance_variable_get(:@configuration)
             .files_to_run
             .size == 1
    end

    def specific_file
      result.files.select do |file|
        specific_file_pattern.match?(file.filename)
      end
    end

    def specific_file_pattern
      @specific_file_pattern ||= Regexp.new(
        RSpec
          .world
          .instance_variable_get(:@configuration)
          .files_to_run
          .first
          &.gsub(%r{/spec/}, '/app/')
          &.gsub(/_spec\.rb\z/, '.rb')
      )
    end

    def table_header
      column('File(s)', width: 13)
      column('Lines', width: 6, align: 'right')
      column('Covered', width: 7, align: 'right')
      column('L.COV', width: 6, align: 'right')
      column('Miss Line', width: 9)
      column('Br.COV', width: 6, align: 'right')
      column('Miss Branch', width: 11, align: 'right')
    end

    def table_body(file)
      column(filename(file))
      column(file.lines_of_code)
      column(file.covered_lines.size)
      column(percent_of_covered_lines(file))
      column(missing_lines(file))
      column(percent_of_covered_branches(file))
      column(missing_branches(file))
    end

    def filename(file)
      file.filename.sub(self.class.project_root, '')
    end

    def percent_of_covered_lines(file)
      format('%.3f%%', file.covered_percent.tap { |n| break 100.0 if n.nan? })
    end

    def missing_lines(file)
      file.missed_lines.map(&:number).sort.join(', ')
    end

    def percent_of_covered_branches(file)
      format(
        '%.3f%%',
        file.branches_coverage_percent.tap { |n| break 100.0 if n.nan? }
      )
    end

    def missing_branches(file)
      file.missed_branches
          .map { |r| "#{r.start_line}..#{r.end_line}" }
          .sort
          .join(', ')
    end
  end
end
# :nocov:
