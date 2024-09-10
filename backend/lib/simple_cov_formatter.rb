# :nocov:
# テストのテストになるため
require 'command_line_reporter'
require_relative 'simple_cov_formatter/grouped_table'
require_relative 'simple_cov_formatter/awkward_table'

class SimpleCovFormatter
  include CommandLineReporter

  def format(result)
    return AwkwardTable.call(result) if specific_test?

    setup_stdout! do
      header!
      GroupedTable.call(result)
      AwkwardTable.call(result)
      footer!
    end
    buf = File.read('tmp/coverage')
    # rubocop:disable Rails/Output
    # 意図して標準出力を利用しているため
    puts(buf) || restore!(buf)
    # rubocop:enable Rails/Output
  end

  def restore!(buf)
    File.binwrite(
      'tmp/coverage',
      JSON.generate(body: "```sh\n#{buf.gsub(/\e\[(\d+)m/, '')}\n```")
    )
  end

  private

  def specific_test?
    defined?(RSpec) && \
      RSpec.world
           &.instance_variable_get(:@configuration)
           &.files_to_run
           &.size == 1
  rescue StandardError
    false
  end

  def setup_stdout!(&block)
    stdout_old = $stdout.dup
    File.open('tmp/coverage', 'w') do |fp|
      $stdout.reopen(fp)
      yield if block
    end
  ensure
    $stdout.flush
    $stdout.reopen stdout_old
  end

  def header!
    header(
      title: 'COVERAGE',
      rule: :header,
      align: 'center',
      timestamp: true,
      bold: true,
      width: 80
    )
  end

  def footer!
    header(
      rule: :footer,
      width: 80
    )
  end
end
# :nocov:
