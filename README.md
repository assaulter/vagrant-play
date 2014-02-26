# playが実行できる環境を作る
## vagrant関係の導入
https://www.virtualbox.org/wiki/Downloadsでvbをダウンロード

vagrantを導入。僕は公式からイメージを落としてきた(Mac用)

### centOSをダウンロード

```
$ vagrant up
```

Vagrantfileに記述してあるので、勝手にcentOSを拾ってきます。変更したい場合はVagrantfileを編集。

### sshでvagrant上のcentOSにアクセス出来るようにする
```
$ vagrant ssh-config --host play >> ~/.ssh/config
$ ssh play
```
playがホスト名。適当に変えていいけど覚えておくこと。後述する、サーバーにchefをインストールする際に使用します。

## chefをインストールする
```
$ gen i chef --no-ri --no-rdoc
```
## knifeの設定
```
$ knife configure
```
全部エンターでおｋ

公開されているcookbookをダウンロードするには、Opscode Communityにユーザ登録し、秘密鍵をダウンロードしておく必要があります。秘密鍵をDownloadしたら、~/.chef/username.pemにパーミッション600で保存しておきましょう。更にknife configureで生成した~/.chef/knife.rbに以下の記述が無かったら、追記します。

```
$ vim ~/.chef/knife.rb

client_key       '/Users/tsuchikazu/.chef/username.pem' #この行追加
```

## knife-soloをインストールする
```
$ gem i knife-solo --no-fi --no-rdoc
```

## vagrant上のcentOSにchefをインストールする
```
$ knife solo prepare play
```
melodyはホスト名

## Javaをバージョン指定して導入する(opscode::javaを使う)
Berksfileに追加

```
cookbook 'java'
```

javaのバージョンを指定する(詳細はhttps://github.com/socrata-cookbooks/javaとか、インストールしたcookbookのattributes/default.rbを見ると、設定できる箇所が分かる)

```
# node/play.json
"java": {
    "install_flavor": "oracle",
    "jdk_version": "7",
    "oracle": {
      "accept_oracle_download_terms": true
    }
  }
```

実行結果

```
[vagrant@localhost ~]$ java -version
java version "1.7.0_51"
Java(TM) SE Runtime Environment (build 1.7.0_51-b13)
Java HotSpot(TM) 64-Bit Server VM (build 24.51-b03, mixed mode)
```

## Playをインストールするcookbookを書く

```
# ひな形作成
knife cookbook create play-install -o site-cookbooks
```
typesafeからzipを取ってきて解凍、コマンドのリンクを張る(詳細はplay-install/resipes/default.rbを参照)

## iptablesの設定

https://github.com/rtkwlf/cookbook-simple-iptables

http://tsuchikazu.net/vps_chef_solo/

LWRP型のcookbookなので、cookbookを作成してrecipeからLWRP呼び出します。

## chef-soloをknifeで実行する

```
$ knife solo cook play
```