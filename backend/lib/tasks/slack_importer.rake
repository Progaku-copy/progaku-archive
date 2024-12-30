# frozen_string_literal: true

namespace :slack_importer do
  task save_memos: :environment do
    if Memo::SlackImporter.save
      puts 'メモの取り込みに成功しました'
    else
      puts 'メモの取り込みに失敗しました'
      exit(1)
    end
  end

  task save_posters: :environment do
    if Poster.build_from_slack_posters
      puts 'ユーザーの取り込みに成功しました'
    else
      puts 'ユーザーの取り込みに失敗しました'
      exit(1)
    end
  end
end
