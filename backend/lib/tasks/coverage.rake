require_relative '../simple_cov_formatter/awkward_table'
require_relative '../simple_cov_formatter/grouped_table'

namespace :coverage do
  desc 'テスト実行結果（coverage/.resultset.json）を読み取ってテストカバレッジを出力する'
  task report: :environment do
    require 'simplecov'
    require 'command_line_reporter'

    previous_buffer = if File.exist?('coverage/.resultset.json')
                        File.binread('coverage/.resultset.json')
                      end

    SimpleCov.collate Dir['coverage/**/.resultset.json'], 'rails' do
      enable_coverage :branch
      formatter SimpleCovFormatter

      # 実装が10行未満のファイルは除外する
      # add_filter { |source_file| source_file.lines_of_code <= 6 }

      # Rakeタスクは除外する
      add_filter '/lib/tasks/'
    end

    # collateが連結した結果を書き込んでしまうが、意味なくディスクスペースを無駄に消費するのを避ける
    if previous_buffer
      File.binwrite('coverage/.resultset.json', previous_buffer)
    end
  end
end
