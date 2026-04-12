# DESIGN.md — ZekkaLog

舌下免疫療法の服薬記録 iOS アプリ「ZekkaLog」のデザイン仕様書。  
AI（Claude 等）が SwiftUI 実装を行う際に参照する設計ガイドとして機能する。

---

## 1. Visual Theme & Atmosphere

### アプリの世界観

毎日の服薬という小さなルーティンを、ストレスなく続けられるようサポートするアプリ。  
医療アプリとしての信頼性を持ちながら、生活に自然に溶け込むデザインを目指す。

### デザインキーワード

- **清潔感** — 余白を十分に取り、視覚的なノイズを排除する
- **信頼性** — 不必要な装飾を避け、iOS 標準パターンを尊重する
- **日常に馴染む** — 毎日使うものとして違和感のないシンプルさ
- **落ち着き** — 派手なアニメーションや強い色は使わない
- **明快さ** — 1 画面 1 タスクを原則とし、迷わせない

### 情報密度

低〜中。1 画面に表示する情報を絞り込み、余白を活かしたレイアウトにする。

### デザイン哲学

- Apple Human Interface Guidelines (HIG) に準拠する
- カスタム実装よりも UIKit/SwiftUI 標準コンポーネントを優先する
- システムカラー・SF Symbols を活用し、ダークモード・アクセシビリティに自動対応させる

---

## 2. Color Palette & Roles

背景・テキストはシステムカラーのみで構成する。アクセントカラーのみカスタム定義する。

### アクセントカラー（カスタム）

| モード | Hex | sRGB | 説明 |
|---|---|---|---|
| Light | `#0891B2` | R:0.031 G:0.569 B:0.698 | 落ち着いた水色（シアン） |
| Dark | `#22D3EE` | R:0.133 G:0.827 B:0.933 | 暗背景での視認性を確保した明るい水色 |

- 定義場所: `Assets.xcassets/AccentColor.colorset`
- 参照方法: SwiftUI では `.tint` ShapeStyle / `Color.accentColor` で自動適用される
- アプリ全体への適用: `WindowGroup` レベルで自動的に tint として使われる

### 背景色

| Role | SwiftUI | UIKit 相当 | 用途 |
|---|---|---|---|
| Background | `.background` / `Color(.systemBackground)` | `systemBackground` | 全画面ベース |
| Secondary Background | `Color(.secondarySystemBackground)` | `secondarySystemBackground` | カード・ボタン背景 |
| Tertiary Background | `Color(.tertiarySystemBackground)` | `tertiarySystemBackground` | ネストしたカード |
| Grouped Background | `Color(.systemGroupedBackground)` | `systemGroupedBackground` | `Form` / `List` の背景 |

### テキスト色

| Role | SwiftUI | 用途 |
|---|---|---|
| Primary Text | `.primary` / `Color(.label)` | 主要テキスト |
| Secondary Text | `.secondary` / `Color(.secondaryLabel)` | 補足・説明テキスト |
| Tertiary Text | `Color(.tertiaryLabel)` | プレースホルダー等 |

### アクセント・状態色

| Role | SwiftUI | 用途 |
|---|---|---|
| Tint (Accent) | `.tint` / `Color.accentColor` | インタラクティブ要素（最小限の使用）。カスタムシアン `#0891B2` |
| Success | `Color.green` | 服薬済み状態の表示 |
| Destructive | `Color.red` | エラー・削除操作 |

> **原則**: アクセントカラー（tint）の使用は最小限にとどめる。  
> ユーザーの目を引く必要があるのは「服薬済み（green）」と「タップできる要素（tint）」のみ。

---

## 3. Typography Rules

### フォント

- **フォントファミリー**: `SF Pro`（iOS デフォルト。指定不要、`Font` のみで自動適用される）
- **日本語フォント**: `ヒラギノ角ゴシック`（iOS デフォルト。同様に指定不要）
- **カスタムフォント**: 使用しない

### サイズ・ウェイト体系（Dynamic Type）

| Style | SwiftUI 指定 | 用途 |
|---|---|---|
| Large Title | `.font(.largeTitle)` | ナビゲーションバー大タイトル（自動） |
| Title 2 Semibold | `.font(.title2).fontWeight(.semibold)` | 画面内の主見出し（「今日の服薬」） |
| Title 3 Semibold | `.font(.title3).fontWeight(.semibold)` | カード内の薬品名ラベル |
| Body | `.font(.body)` | リスト行・本文テキスト |
| Subheadline | `.font(.subheadline)` | 案内テキスト・セクション説明 |
| Caption | `.font(.caption)` | タイムスタンプ・補足情報 |
| Caption 2 | `.font(.caption2)` | 最小補足（使用は限定的に） |

### Dynamic Type 対応

- すべてのテキストは Dynamic Type に対応させる
- 固定サイズ（`.font(.system(size: 14))`）は使用しない
- アクセシビリティサイズでの折り返しを考慮したレイアウトにする

### 行間・禁則

- 行間・禁則処理は iOS 標準に委ねる（`.lineSpacing()` の独自設定は不要）

---

## 4. Component Specs

### MedicationButton（服薬ボタン）

服薬タブのメインアクション。薬品ごとに1つ表示される。

```swift
// 形状
RoundedRectangle(cornerRadius: 16)

// 背景色
// 通常: Color(.secondarySystemBackground)
// 服薬済み: Color.green.opacity(0.1)

// ボーダー
// 通常: なし
// 服薬済み: Color.green.opacity(0.4), lineWidth: 1

// 内側パディング: 16pt（全方向）
// アイコンサイズ: 32pt、フレーム幅: 48pt
// ボタン横幅: .frame(maxWidth: .infinity)

// 状態
// - 未服薬: 通常スタイル、タップ可能
// - 服薬済み: green スタイル、disabled（.disabled(true)）
```

### RecordRow（履歴リスト行）

履歴タブの各服薬記録。

```swift
// アイコン: SF Symbols、32pt フレーム、.tint カラー
// 縦パディング: .padding(.vertical, 4)
// チェックマーク: "checkmark.circle.fill"、Color.green
// タイムスタンプ: .font(.caption)、.foregroundStyle(.secondary)
```

### TimerRing（タイマー進捗リング）

TimerView 内の円形プログレス表示。

- **服薬フェーズ**: 60秒カウントダウン
- **インターバルフェーズ**: 300秒（5分）カウントダウン（両方服薬時のみ）
- 背景色リング + 進捗リングの2重構造
- 完了時: `checkmark.circle.fill` アイコンに切り替え

### Tab Bar

3タブ構成。SwiftUI `TabView` 標準スタイルを使用。

| タブ | ラベル | SF Symbol |
|---|---|---|
| 服薬 | 服薬 | `pills.fill` |
| 履歴 | 履歴 | `list.bullet` |
| 設定 | 設定 | `gearshape.fill` |

### ContentUnavailableView

履歴が空の場合のフォールバック表示。SwiftUI 標準コンポーネントを使用。

```swift
ContentUnavailableView(
    "服薬記録がありません",
    systemImage: "pills",
    description: Text("服薬タブから記録を開始してください")
)
```

---

## 5. Layout Principles

### 間隔スケール

| Token | Value | SwiftUI 指定例 | 用途 |
|---|---|---|---|
| XS | 4pt | `.padding(4)` | 行内要素間の微調整 |
| S | 8pt | `.padding(8)` | コンパクトな余白 |
| M | 16pt | `.padding()` / `.padding(16)` | 標準水平・垂直パディング |
| L | 24pt | `.padding(24)` | セクション間隔 |
| XL | 32pt | `.padding(32)` | 大セクション間・上部余白 |

> SwiftUI の `.padding()` デフォルト値は 16pt。M スペースには引数なしで使える。

### 水平マージン

- 標準: `.padding(.horizontal)` = 16pt
- リストコンテンツ: `List` / `Form` の標準マージン（自動）

### 角丸

- カード・ボタン: `cornerRadius: 16`
- 小さいコンポーネント: `cornerRadius: 12`

### Safe Area

SwiftUI のデフォルト動作に委ねる（`.ignoresSafeArea()` は使用しない）。

### ナビゲーション構造

```
TabView
├── 服薬タブ
│   └── NavigationStack
│       └── MedicationSelectionView
│           └── (destination) TimerView
├── 履歴タブ
│   └── NavigationStack
│       └── RecordListView
└── 設定タブ
    └── NavigationStack
        └── SettingsView
```

---

## 6. Depth & Elevation

### 基本方針

Shadow（影）は原則使用しない。背景色の階層（レイヤー差）で奥行きを表現する。

### 背景色レイヤー

```
systemBackground          ← 最背面（画面ベース）
  └── secondarySystemBackground  ← カード・ボタン背景
        └── tertiarySystemBackground  ← ネスト要素（必要な場合のみ）
```

### Material（将来拡張）

現状未使用。必要に応じて `.ultraThinMaterial` / `.regularMaterial` を検討。  
ただし、過度な使用はシンプルさを損なうため避ける。

---

## 7. Do's and Don'ts

### Do

- iOS HIG のパターン（`NavigationStack`, `TabView`, `List`, `Form`）を忠実に使う
- 背景・テキストはシステムカラー（`.primary`, `.secondary`, `Color(.systemBackground)` 等）を優先する
- アクセントカラーは `AccentColor` アセットに定義されたシアン (`#0891B2`) を使う（`.tint` / `Color.accentColor` で参照）
- SF Symbols を積極的に活用し、アイコンの自作は避ける
- 服薬済み状態は `Color.green` で一貫して表現する
- ユーザー設定は `@AppStorage` で永続化する
- SwiftData の `@Query` マクロでデータをリアクティブに取得する
- `ContentUnavailableView` を空状態のフォールバックに使う
- Dynamic Type に対応したフォント指定にする

### Don't

- カスタムフォントを導入しない（SF Pro / ヒラギノ角ゴシックで十分）
- 固定フォントサイズ（`.font(.system(size: N))`）を使わない
- アニメーションを派手にしない（医療系の落ち着いた雰囲気を優先）
- 1 画面に複数の主要アクションを並べない（1 画面 1 タスク）
- `Color.accentColor` を多用しない（tint は最小限）
- `.ignoresSafeArea()` を不必要に使わない
- `UIColor` ではなく `Color` の SwiftUI API を使う（UIKit との混在を減らす）

---

## 8. Responsive Behavior

### デバイス対応

| デバイス | 対応方針 |
|---|---|
| iPhone（主ターゲット） | 縦持ち・1カラム。`TabView` ベースのナビゲーション |
| iPad | 同一コードで動作。将来的に `NavigationSplitView` への移行を検討 |

### タッチターゲット

最低 **44×44pt**（Apple HIG 基準）を確保する。  
ボタンの視覚サイズが小さくても `.frame(minWidth: 44, minHeight: 44)` または `.contentShape()` で確保。

### フォントスケール

Dynamic Type に完全委任。固定サイズ禁止。  
アクセシビリティ「大きな文字」設定時にレイアウトが崩れないよう、`HStack` より `VStack` を柔軟に使う。

### 向き（Orientation）

縦持ち（Portrait）を主体として設計する。横持ちは SwiftUI 自動対応に委ねる。

---

## 9. Agent Prompt Guide

### このファイルの使い方

AI（Claude 等）が新しい画面・コンポーネントを実装する際に、このファイルを参照させることで  
アプリ全体のデザインの一貫性を保つ。

### 実装依頼時のプロンプト例

```
DESIGN.md を参照して、以下の仕様で実装してください。

【守るべきルール】
- 背景・テキストはシステムカラーのみ使用
- アクセントカラーは AccentColor アセットのシアン（.tint / Color.accentColor）を使用
- 角丸は原則 cornerRadius: 16
- 服薬済み状態は Color.green で表現
- SF Symbols を積極活用
- Dynamic Type 対応（固定フォントサイズ禁止）
- タッチターゲット最低 44×44pt
- 1 画面 1 タスクの原則
```

### コンポーネント追加時のチェックリスト

- [ ] 背景・テキストはシステムカラーのみ使用しているか
- [ ] アクセントカラーは `.tint` / `Color.accentColor` で参照しているか（直接 hex 指定していないか）
- [ ] Dynamic Type 対応のフォント指定か
- [ ] タッチターゲットが 44×44pt 以上か
- [ ] 空状態（Empty State）を `ContentUnavailableView` で処理しているか
- [ ] 服薬済み状態を `Color.green` で表現しているか
- [ ] ダークモードで表示が崩れないか（Xcode Preview で確認）
