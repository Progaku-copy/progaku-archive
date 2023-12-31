# progaku-archive
Progakuのアーカイブ用のアプリ

## ドキュメント
- ドキュメントのリンクは[こちら](docs/)
  - [バックエンド](docs/backend/)
    - [バックエンドのCIについて](docs/backend/ci.md)
    - [DB関連の説明(マイグレーション方法等)](docs/backend/database.md)
    - [RSpecとFactoryBot](docs/backend/Rspec_FactoryBot.md)
    - [Rubocopについて](docs/backend/rubocop.md)
  - [フロントエンド](docs/frontend/)
    - [バックエンドのCIについて](docs/frontend/ci.md)
  - [その他のドキュメント群](docs/others/)
    - [Git/Githubについて](docs/others/git_and_github.md)
    - [シェルスクリプトの説明](docs/others/shell_script.md)

## バックエンドの環境構築
### 1. envファイルを作成して記述する
`infra/env/backend.env`を作成して、`infra/env/backend.env.template`の内容を元に記述する。

**※ 現時点ではコピペでも動きますが、usernameやpasswordは適宜変えて使用して下さい。**

---

残りのコマンドの実行は、`bin/backend/setup`コマンドを実行しても同じ結果が得られます。
### 2. imageをbuildする
以下のコマンドをホストマシン上で実行して下さい。
```
$ docker compose build backend
```

### 3. MySQLコンテナにローカル用のdatabaseを作成する
以下のコマンドをホストマシン上で実行して下さい。
```bash
$ docker compose run backend rails db:create
$ docker compose run backend rails db:create RAILS_ENV=test
```

### 4. マイグレーションを行う
以下のコマンドをホストマシン上で実行して下さい。
```bash
$ docker compose run backend rake ridgepole:apply
```

## その他

### Rspecを実行する
Rspecを走らせるには、以下のコマンドをホストマシン上で実行して下さい。
詳しくは、[こちらのドキュメント](docs/backend/Rspec_FactoryBot.md)を参照して下さい。
```bash
$ docker compose run backend bundle exec rspec
```

### Rubocopを実行する
Rubocopを走らせるには、以下のコマンドをホストマシン上で実行して下さい。
```bash
$ docker compose run backend bundle exec rubocop
```
