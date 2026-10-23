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

## 保存について

マイ曲（取り込んだ曲と譜面）はブラウザの中に保存されます。公開URL・`localhost:8765`・claude.ai 版では、それぞれ別々に保存されます（ベストスコアや判定オフセットも同様）。
