# Minecraft Spigot Server Container Kit
![current_ver](https://img.shields.io/badge/Server%20Version-1.18.1-blueviolet)  
SpigotマインクラフトサーバをDockerコンテナーで簡単に起動するためのキット
  
## 手順
1. このリポジトリのクローンまたは既存のMinecraftディレクトリ直下にこのリポジトリの中身を配置
2. `docker-compose.yml` 内の `MC_XMX` 及び `MC_XMS` をメモリ容量にあわせて調節(`-Xmx`及び`-Xms`引数に相当)
3. `docker compose build` コマンドを実行してイメージをビルド
4. `docker compose up -d` でサーバを起動
  
## 詳細
- 既存の `jar` ファイルは利用されません。削除してください
- バージョンを変更したい場合は `Dockerfile` 内の `spigot_ver` 変数で変更できます。変更後に手順3番のビルドを実施してください
  
## 設定やサーバファイルの変更
Minecraftディレクトリ内のファイルを直接変更し、完了後 `docker compose restart` でサーバの再起動を実行
