# 极简记账

极简记账是一个 SwiftUI + SwiftData 的 iOS MVP。核心目标是付款后通过快捷指令输入金额，并在 3 秒内完成本地记账。

## 功能

- 通过 URL Scheme 快速记账：`jijianbook://record?amount=12.5`
- 快捷指令入账默认分类为餐饮
- 固定三类：餐饮、日用、其他
- 今日页展示今日总额、分类占比和流水列表
- 支持手动补记、编辑和删除
- 数据完全本地存储

## 技术栈

- iOS 17+
- SwiftUI
- SwiftData
- GitHub Actions macOS runner 编译和测试

## 快捷指令

快捷指令配置见：

[docs/shortcuts/quick-record-shortcut.md](docs/shortcuts/quick-record-shortcut.md)

最小 URL 示例：

```text
jijianbook://record?amount=12.5
```

可选分类：

```text
jijianbook://record?amount=8&category=daily
jijianbook://record?amount=6&category=other
```

## 打开工程

在 macOS 上使用 Xcode 打开：

```bash
open JijianBook.xcodeproj
```

或者运行测试：

```bash
xcodebuild test \
  -project JijianBook.xcodeproj \
  -scheme JijianBook \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGNING_ALLOWED=NO
```

## 文档

- [MVP 设计](docs/superpowers/specs/2026-06-30-jijian-book-mvp-design.md)
- [实施计划](docs/superpowers/plans/2026-06-30-jijian-book-mvp-implementation-plan.md)
