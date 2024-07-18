# frozen_string_literal: true

RSpec.describe 'MemosController' do
  describe 'GET /memos' do
    context 'メモが存在する場合' do
      let!(:memos) { create_list(:memo, 3) }

      it '全てのメモが取得でき降順で並び変えられていることを確認する' do
        aggregate_failures do
          get '/memos'
          expect(response).to have_http_status(:ok)
          assert_response_schema_confirm(200)
          expect(response.parsed_body['memos'].length).to eq(3)
          result_memo_ids = response.parsed_body['memos'].map { _1['id'] } # rubocop:disable Rails/Pluck
          expected_memo_ids = memos.reverse.map(&:id)
          expect(result_memo_ids).to eq(expected_memo_ids)
        end
      end
    end
  end

  describe 'GET /memos/:id' do
    context 'メモが存在する場合' do
      let!(:memo) { create(:memo) }
      let!(:comments) { create_list(:comment, 3, memo: memo) }

      it '指定したメモ、コメントが取得できることを確認する' do
        aggregate_failures do
          get "/memos/#{memo.id}", headers: { Accept: 'application/json' }
          expect(response).to have_http_status(:ok)
          assert_response_schema_confirm(200)
          expect(response.parsed_body['memo']['id']).to eq(memo.id)
          expect(response.parsed_body['memo']['comments'].length).to eq(3)
          result_comment_ids = response.parsed_body['memo']['comments'].map { _1['id'] } # rubocop:disable Rails/Pluck
          expected_comments_ids = comments.reverse.map(&:id)
          expect(result_comment_ids).to eq(expected_comments_ids)
        end
      end
    end

    context '存在しないメモを取得しようとした場合' do
      it '404が返ることを確認する' do
        get '/memos/0'
        expect(response).to have_http_status(:not_found)
        assert_response_schema_confirm(404)
      end
    end
  end

  describe 'POST /memos' do
    context 'タイトルとコンテンツが有効な場合' do
      let(:valid_memo_params) do
        { title: Faker::Lorem.sentence(word_count: 3), content: Faker::Lorem.paragraph(sentence_count: 5) }
      end

      it 'memoレコードが追加され、204になる' do
        aggregate_failures do
          expect { post '/memos', params: { memo: valid_memo_params }, as: :json }.to change(Memo, :count).by(+1)
          assert_request_schema_confirm
          expect(response).to have_http_status(:no_content)
          assert_response_schema_confirm(204)
          expect(response.body).to be_empty
        end
      end
    end

    context 'バリデーションエラーになる場合' do
      let(:empty_memo_params) { { title: '', content: '' } }

      it '422になり、エラーメッセージがレスポンスとして返る' do
        aggregate_failures do
          post '/memos', params: { memo: empty_memo_params }, as: :json
          assert_request_schema_confirm
          expect(response).to have_http_status(:unprocessable_entity)
          assert_response_schema_confirm(422)
          expect(response.parsed_body['errors']).to eq(%w[タイトルを入力してください コンテンツを入力してください])
        end
      end
    end
  end

  describe 'PUT /memos/:id' do
    context 'コンテンツが有効な場合' do
      let(:existing_memo) { create(:memo) }
      let(:params) { { content: '新しいコンテンツ' } }

      it 'memoが更新され、204になる' do
        aggregate_failures do
          put "/memos/#{existing_memo.id}", params: { memo: params }, as: :json
          assert_request_schema_confirm
          expect(response).to have_http_status(:no_content)
          assert_response_schema_confirm(204)
          existing_memo.reload
          expect(existing_memo.content).to eq('新しいコンテンツ')
        end
      end
    end

    context 'バリデーションエラーになる場合' do
      let(:existing_memo) { create(:memo) }
      let(:params) { { content: '' } }

      it '422になり、エラーメッセージがレスポンスとして返る' do
        aggregate_failures do
          put "/memos/#{existing_memo.id}", params: { memo: params }, as: :json
          assert_request_schema_confirm
          existing_memo.reload
          expect(response).to have_http_status(:unprocessable_entity)
          assert_response_schema_confirm(422)
          expect(response.parsed_body['errors']).to eq(['コンテンツを入力してください'])
        end
      end
    end
  end

  context 'タイトルを更新しようとした場合' do
    let(:existing_memo) { create(:memo) }
    let(:params) { { title: '新しいタイトル' } }

    it 'タイトルが変更されていないことを確認する' do
      aggregate_failures do
        put "/memos/#{existing_memo.id}", params: { memo: params }, as: :json
        assert_request_schema_confirm
        expect(response).to have_http_status(:no_content)
        existing_memo.reload
        assert_response_schema_confirm(204)
        expect(existing_memo.title).not_to eq('新しいタイトル')
      end
    end
  end

  describe 'DELETE /memos/:id' do
    context 'メモを削除しようとした場合' do
      let!(:existing_memo) { create(:memo) }

      it 'メモを削除されたことを確認する' do
        aggregate_failures do
          expect { delete "/memos/#{existing_memo.id}" }.to change(Memo, :count).by(-1)
          assert_request_schema_confirm
          expect(response).to have_http_status(:no_content)
          assert_response_schema_confirm(204)
        end
      end
    end

    context '存在しないメモを削除しようとした場合' do
      it '404が返ることを確認する' do
        aggregate_failures do
          expect { delete '/memos/0' }.not_to change(Memo, :count)
          assert_request_schema_confirm
          expect(response).to have_http_status(:not_found)
          assert_response_schema_confirm(404)
        end
      end
    end
  end

  describe 'GET /memos/search' do
    context 'キーワードで検索する場合' do
      before do
        create(:memo, title: '1番目のメモ', content: '1番目の内容') # !付きはﾌﾞﾛｯｸ実行前にcreateする
        create(:memo, title: '2番目のメモ', content: '2番目の内容')
      end

      it 'キーワードに一致するメモのタイトルが取得できることを確認する' do
        aggregate_failures do # 複数の確認を一度にまとめて行うことを意味する
          get '/memos/search', params: { keyword: '2番目' } # 「2番目」というkeywordでﾒﾓを検索するﾘｸｴｽﾄを送っている
          expect(response).to have_http_status(:ok) # ﾘｸｴｽﾄが成功しているか(ｽﾃｰﾀｽがOKか)を確認している
          expect(response.parsed_body['memos'].length).to eq(1) # 見つかったﾒﾓが1つであるか確認している
          # 見つかったﾒﾓのﾀｲﾄﾙが「2番目のﾒﾓ」であることを確認 [0]は最初に作成したmemosのことで、そのmemosのtitleということ
          expect(response.parsed_body['memos'][0]['title']).to eq('2番目のメモ')
        end
      end

      it 'キーワードに一致するメモのコンテントが取得できることを確認する' do
        aggregate_failures do # 複数の確認を一度にまとめて行うことを意味する
          get '/memos/search', params: { keyword: '1番目の内' } # 「1番目の内」というkeywordでﾒﾓを検索するﾘｸｴｽﾄを送っている
          expect(response).to have_http_status(:ok) # ﾘｸｴｽﾄが成功しているか(ｽﾃｰﾀｽがOKか)を確認している
          expect(response.parsed_body['memos'].length).to eq(1) # 見つかったﾒﾓが1つであるか確認している
          # 見つかったﾒﾓのﾀｲﾄﾙが「2番目のﾒﾓ」であることを確認 [0]は最初に作成したmemosのことで、そのmemosのcontentということ
          expect(response.parsed_body['memos'][0]['content']).to eq('1番目の内容')
        end
      end

      it 'キーワードを空で検索すると全てのメモが取得できることを確認する' do
        aggregate_failures do # 複数の確認を一度にまとめて行うことを意味する
          get '/memos/search', params: { keyword: '' } # 空のkeywordでﾒﾓを検索するﾘｸｴｽﾄを送っている
          expect(response).to have_http_status(:ok) # ﾘｸｴｽﾄが成功しているか(ｽﾃｰﾀｽがOKか)を確認している
          expect(response.parsed_body['memos'].length).to eq(2) # 見つかったﾒﾓが2つであるか確認している
          # 見つかったﾒﾓのﾀｲﾄﾙが「1番目のﾒﾓと2番目のﾒﾓ」であることを確認している
          # map:配列作成のための命令 |memo|:要素名 memo['title']:それぞれのﾒﾓのﾀｲﾄﾙを取る to:～であることを期待する
          # contain_exactly:この配列の中にあるものが、指定したものと同じであるかを確認
          # しかしmapは全てのﾒﾓｵﾌﾞｼﾞｪｸﾄを読み込みその後ﾀｲﾄﾙだけを取り出すので不要なﾒﾓﾘ使用が発生する
          # そのためpluckを使用しDBから直接ﾀｲﾄﾙだけ取得するので余計なﾒﾓﾘ使用を避けることができる
          # expect(response.parsed_body['memos'].map { |memo| memo['title'] }).to contain_exactly('1番目のメモ', '2番目のメモ')
          expect(Memo.pluck(:title)).to contain_exactly('1番目のメモ', '2番目のメモ')
        end
      end
    end
  end
end
