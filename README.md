# Minecraft Server Container Kit
マインクラフトをDockerコンテナーで簡単に起動するためのキット
  
## 手順
1. このリポジトリのクローンまたは既存のMinecraftディレクトリ直下にこのリポジトリの中身を配置
2. __クローンした場合のみ__ Minecraftサーバのjarファイルをリポジトリディレクトリ直下に配置
3. `docker-compose.yml` 内の `MC_XMX` 及び `MC_XMS` をメモリ容量にあわせて調節(`-Xmx`及び`-Xms`引数に相当)
4. `docker-compose.yml` 内の `MC_JAR` を配置したMinecraftサーバのjarファイルの名前に変更
5. `docker-compose build` コマンドを実行してイメージをビルド
6. `docker-compose up -d` でサーバを起動
  
## 設定やサーバファイルの変更
Minecraftディレクトリ内のファイルを直接変更し、完了後 `docker-compose restart` でサーバの再起動を実行