# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ZekkaLog は iOS/iPadOS アプリ（Bundle ID: `dev.homura10059.ZekkaLog`）。SwiftUI + SwiftData で構築されている。

- **Platform**: iOS & iPadOS (TARGETED_DEVICE_FAMILY = 1,2)
- **Deployment Target**: iOS 26.2
- **Swift Version**: 5.0

## Build & Test Commands

このプロジェクトは Xcode プロジェクト（`.xcodeproj`）で管理されている。CLI でのビルド・テストには `xcodebuild` を使用する。

```bash
# ビルド（シミュレータ向け）
xcodebuild build -project ZekkaLog.xcodeproj -scheme ZekkaLog -destination 'platform=iOS Simulator,name=iPhone 16'

# 全テスト実行
xcodebuild test -project ZekkaLog.xcodeproj -scheme ZekkaLog -destination 'platform=iOS Simulator,name=iPhone 16'

# 単体テストのみ（ZekkaLogTests ターゲット）
xcodebuild test -project ZekkaLog.xcodeproj -scheme ZekkaLog -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing ZekkaLogTests

# 特定のテストメソッドを実行
xcodebuild test -project ZekkaLog.xcodeproj -scheme ZekkaLog -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing 'ZekkaLogTests/ZekkaLogTests/テスト名'
```

## Architecture

### Tech Stack
- **SwiftUI**: UI 全体
- **SwiftData**: 永続化レイヤー（`@Model`, `ModelContainer`, `ModelContext`, `@Query` マクロを使用）

### 現在の構成（初期テンプレート状態）

```
ZekkaLog/
├── ZekkaLogApp.swift   # @main エントリポイント。ModelContainer を初期化して WindowGroup に注入
├── ContentView.swift   # NavigationSplitView ベースのリスト画面
└── Item.swift          # SwiftData の @Model クラス（timestamp: Date のみ）

ZekkaLogTests/          # Swift Testing フレームワーク（import Testing）使用
ZekkaLogUITests/        # XCTest ベースの UI テスト
```

### テストフレームワーク
- **Unit Tests**: Swift Testing（`import Testing`, `@Test`, `#expect`）
- **UI Tests**: XCTest（`XCUIApplication`）
