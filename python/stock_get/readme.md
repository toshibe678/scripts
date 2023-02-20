# 日本株価の取得ツール
日本の株価を引数により16分割で取得しcsvにしてリポジトリにプッシュするツールです。
pandas_datareaderは同一IPから実行しすぎると拒否されるのでherokuを1時間おきにcronで実行してIPコロコロしてます。

#### ローカルでテスト時
pip3 install -r requirements.txt

herokuで実行
heroku run --app floating-stream-17786 python stock.py 1
heroku run --app floating-stream-17786 python stock.py 16

環境変数の一覧
heroku config --app floating-stream-17786

環境変数を追加／変更する
heroku config:set 環境変数名=セットしたい値 --app floating-stream-17786

環境変数を削除する
heroku config:unset 環境変数名 --app floating-stream-17786

stock token
heroku config:set git_token=xxxxxxxxxxxxxxxx --app floating-stream-17786


crontab -e
2 0 * * 1-5 /usr/local/bin/heroku run --app floating-stream-17786 python stock.py 0 1>/dev/null 2>/dev/null
32 1 * * 1-5 /usr/local/bin/heroku run --app floating-stream-17786 python stock.py 1 1>/dev/null 2>/dev/null
2 3 * * 1-5 /usr/local/bin/heroku run --app floating-stream-17786 python stock.py 2 1>/dev/null 2>/dev/null
32 4 * * 1-5 /usr/local/bin/heroku run --app floating-stream-17786 python stock.py 3 1>/dev/null 2>/dev/null
2 6 * * 1-5 /usr/local/bin/heroku run --app floating-stream-17786 python stock.py 4 1>/dev/null 2>/dev/null
32 7 * * 1-5 /usr/local/bin/heroku run --app floating-stream-17786 python stock.py 5 1>/dev/null 2>/dev/null
2 9 * * 1-5 /usr/local/bin/heroku run --app floating-stream-17786 python stock.py 6 1>/dev/null 2>/dev/null
32 10 * * 1-5 /usr/local/bin/heroku run --app floating-stream-17786 python stock.py 7 1>/dev/null 2>/dev/null
2 12 * * 1-5 /usr/local/bin/heroku run --app floating-stream-17786 python stock.py 8 1>/dev/null 2>/dev/null
32 13 * * 1-5 /usr/local/bin/heroku run --app floating-stream-17786 python stock.py 9 1>/dev/null 2>/dev/null
2 15 * * 1-5 /usr/local/bin/heroku run --app floating-stream-17786 python stock.py 10 1>/dev/null 2>/dev/null
32 16 * * 1-5 /usr/local/bin/heroku run --app floating-stream-17786 python stock.py 11 1>/dev/null 2>/dev/null
2 18 * * 1-5 /usr/local/bin/heroku run --app floating-stream-17786 python stock.py 12 1>/dev/null 2>/dev/null
32 19 * * 1-5 /usr/local/bin/heroku run --app floating-stream-17786 python stock.py 13 1>/dev/null 2>/dev/null
2 21 * * 1-5 /usr/local/bin/heroku run --app floating-stream-17786 python stock.py 14 1>/dev/null 2>/dev/null
32 22 * * 1-5 /usr/local/bin/heroku run --app floating-stream-17786 python stock.py 15 1>/dev/null 2>/dev/null
