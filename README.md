# Rooftop Beat

リズムに合わせて屋上を駆けるパルクール音ゲー。

## 遊ぶ

GitHub Pages で公開した URL を開くだけで遊べます。

## いじる

1. `start.command` をダブルクリック（初回は右クリック →「開く」）。ブラウザで `http://localhost:8765/` が開きます。
2. `rooftop-beat.html` を編集して保存 → ブラウザを再読み込みすると反映されます。
3. 公開版に反映するときは `git add -A && git commit -m "変更内容" && git push`。1〜2分で URL 側も更新されます。

`rooftop-beat.html` をそのままダブルクリックで開くと、曲ファイルを読み込めない（ブラウザの制限）ので、`start.command` から起動してください。

## ファイル

| ファイル | 中身 |
|---|---|
| `rooftop-beat.html` | ゲーム本体（HTML・CSS・JS がすべてこの1枚に入っています） |
| `pupa.mp3` / `outside.mp4` | 内蔵ステージの曲（手元だけ。git には入れていないので、公開URLではこの2ステージは表示されません） |
| `index.html` | 入口のページ（`rooftop-beat.html` を読み込むだけ）。公開URLもローカルもここから開く |
| `start.command` | ローカルサーバーを立てて `index.html` を開く |

## コードの地図（rooftop-beat.html）

- `STAGES` / `SONGS` … ステージ一覧と内蔵曲の設定（BPM・最初の拍・小節ごとの音量）
- `WIN` … 判定の幅（秒）。`PPB` … 1拍あたりの横の距離
- `genSeg` … 自動譜面の作り方（屋上の長さ・ジャンプ・溜め・配管・壁キック・壁ジャンプの出る確率）
- `buildChart` … エディタで置いたノーツを屋上に変換するルールと、置けない時のエラー文
- `pressAt` / `release` / `update` … 入力と動き・判定
- `drawPlatforms` / `drawShaft` / `drawRunner` / `drawLane` … 描画
- `analyzeBuffer` … 取り込んだ曲の BPM と拍の位置の自動解析
- エディタは `ED` で始まる関数群

## みんなの譜面（Supabase）

エディタの「みんなに公開」で譜面と曲を上げると、メニューの「みんなの譜面」から誰でも遊べます。サーバーには [Supabase](https://supabase.com)（無料枠）を使います。

### 最初の設定（1回だけ）

1. Supabase にサインアップして、新しいプロジェクトを作る（リージョンは Tokyo がおすすめ）。
2. 左メニューの **SQL Editor** を開き、`supabase/setup.sql` の中身を全部貼り付けて **Run**。表・曲置き場・ルールがまとめて作られます。
3. **Project Settings → API**（または「Connect」）で次の2つをコピーする。
   - Project URL（`https://xxxx.supabase.co`）
   - 公開用のキー（`anon` / `public`、または `sb_publishable_` で始まるもの）。**`service_role` / `secret` のキーは使わないでください。**
4. `rooftop-beat.html` の `const SUPABASE = { url, key }` に貼り付けて push。

### しくみ

- 譜面は `charts` 表、曲ファイルは `songs` という置き場（1曲15MBまで）に入ります。
- アカウントなしで誰でも見る・遊ぶ・公開ができます。公開をやめられるのは、公開したのと同じブラウザだけです（ブラウザに保存した合言葉で確認）。
- 曲ファイルも誰でも再生・ダウンロードできる状態になるので、公開してよい曲だけにしてください。
- 荒らしが出たら、Supabase の Table Editor で `charts` の行を消せば一覧から消えます。
- claude.ai 版ではこの機能は使えません（外部のサーバーに接続できないため）。公開URL かローカルで使ってください。

### 管理者モード

「みんなの譜面」を管理する人は、ゲームの **設定 → 管理者** からログインすると、一覧で次の操作ができます。

- **非表示 / 再表示**：非表示にした譜面はほかの人の一覧から消えます（管理者には「非表示中」で見えます）
- **名前を変える**：曲名と作者名を書き換えます
- **削除**：譜面と曲ファイルを完全に消します

最初の設定（1回だけ）：

1. Supabase の **Authentication → Users → Add user → Create new user** で、管理者のメールとパスワードを作る（**Auto Confirm User** にチェック）。
2. `supabase/admin.sql` の `'あなたのメールアドレス'` を 1 のメールに書き換え、全体を **SQL Editor** で **Run**。最後に管理者のメールが表示されれば成功。
3. （おすすめ）**Authentication → Sign In / Providers** で **Allow new users to sign up** をオフにする。オンのままでも、管理者表に入っていない人は何もできません。

管理者を増やすときは、1 と 2 をそのメールでもう一度行います。誰が管理者かはサーバー側の `admins` 表で決まるので、コードを読んでも管理者にはなれません。

## 保存について

マイ曲（取り込んだ曲と譜面）はブラウザの中に保存されます。公開URL・`localhost:8765`・claude.ai 版では、それぞれ別々に保存されます（ベストスコアや判定オフセットも同様）。
