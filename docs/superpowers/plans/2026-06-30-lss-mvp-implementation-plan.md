# 极简记账 MVP 实施计划

日期：2026-06-30

对应规格：`docs/superpowers/specs/2026-06-30-lss-mvp-design.md`

## 前提

目标平台为 iOS 17+。实现采用 SwiftUI + SwiftData，本地离线存储，不做账号、云同步、预算、OCR 和通知正文读取。

当前目录尚未包含 Xcode 工程。第一步需要创建 iOS App 工程，产品名使用“极简记账”，内部英文标识建议使用 `LSS`。

## 阶段 1：创建工程骨架

目标：得到一个可在 Xcode 打开并运行的 SwiftUI iOS 工程。

任务：

1. 创建 iOS App 工程。
2. 设置最低系统版本为 iOS 17。
3. 启用 SwiftUI 生命周期。
4. 引入 SwiftData model container。
5. 配置 App Display Name 为“极简记账”。
6. 注册 URL Scheme：`lss`。

验收：

- App 能在模拟器启动。
- 默认页面能正常显示。
- `Info.plist` 或 target 配置中包含 `lss` URL Scheme。

## 阶段 2：实现数据模型

目标：建立可持久化的交易记录模型。

任务：

1. 新增 `Transaction` SwiftData 模型。
2. 定义字段：
   - `id: UUID`
   - `amount: Decimal`
   - `type: TransactionType`
   - `category: TransactionCategory`
   - `note: String`
   - `source: TransactionSource`
   - `createdAt: Date`
   - `updatedAt: Date`
3. 定义枚举：
   - `TransactionType.expense`
   - `TransactionCategory.food`
   - `TransactionCategory.daily`
   - `TransactionCategory.other`
   - `TransactionSource.shortcut`
   - `TransactionSource.manual`
4. 为分类提供中文展示文案：餐饮、日用、其他。
5. 为模型提供创建默认快捷指令记录的初始化入口。

验收：

- App 启动时 SwiftData container 可正常加载。
- 可以在预览或调试代码中创建一条 `Transaction`。
- 分类展示文案稳定映射。

## 阶段 3：实现 URL Scheme 解析与落库

目标：App 能通过 `lss://record?amount=12.5` 自动新增记录。

任务：

1. 在 App 入口处理 `.onOpenURL`。
2. 新增 `RecordURLParser`，解析：
   - host/path 是否为 `record`。
   - `amount` 参数。
   - `category` 参数。
   - `source` 参数。
3. 实现金额校验：
   - 缺少金额：失败。
   - 非数字：失败。
   - 小于等于 0：失败。
4. 实现分类容错：
   - 缺失或非法分类按 `food` 处理。
5. 实现来源容错：
   - 缺失按 `shortcut` 处理。
   - 非法来源按 `shortcut` 处理。
6. 解析成功后写入 SwiftData。
7. 解析失败时打开补记页，并传递错误提示。
8. 写入成功后导航到今日页，并记录刚新增的 `Transaction.id` 用于高亮。

验收：

- 打开 `lss://record?amount=12.5` 后新增餐饮记录。
- 打开 `lss://record?amount=8&category=daily` 后新增日用记录。
- `amount=0`、`amount=abc`、缺少 `amount` 时不新增记录。
- 非法分类仍可新增餐饮记录。

## 阶段 4：实现今日页

目标：完成 MVP 的核心查看和确认页面。

任务：

1. 创建 `TodayView`。
2. 查询当天 00:00 至次日 00:00 的交易记录。
3. 计算今日总额。
4. 计算三分类金额与占比。
5. 实现今日流水列表，按 `createdAt` 倒序展示。
6. 快捷指令新增记录后，将该记录置顶显示在倒序列表中。
7. 对刚新增记录高亮 1.5 秒。
8. 添加右上角新增按钮，打开补记页。
9. 支持点击流水进入编辑页。
10. 支持左滑删除流水。

验收：

- 今日总额等于今日流水金额之和。
- 分类占比只展示餐饮、日用、其他。
- 新增、修改、删除后统计即时刷新。
- 快捷指令新增记录可被用户立即看到。

## 阶段 5：实现编辑/补记页

目标：支持晚上补记和纠错。

任务：

1. 创建 `TransactionFormView`，同时支持新增和编辑。
2. 表单字段：
   - 金额输入。
   - 分类选择：餐饮、日用、其他。
   - 备注输入。
   - 时间选择。
3. 新增模式：
   - 默认时间为当前时间。
   - 默认分类为餐饮。
   - 保存后返回今日页。
4. 编辑模式：
   - 加载已有记录。
   - 保存时更新 `updatedAt`。
   - 提供删除入口。
5. 金额校验：
   - 空值、非数字、小于等于 0 时不能保存。
   - 显示明确错误提示。

验收：

- 可以手动新增记录。
- 可以修改金额、分类、备注、时间。
- 可以删除记录。
- 金额非法时不会写入脏数据。

## 阶段 6：快捷指令配置说明

目标：提供用户可照着创建的快捷指令步骤。

任务：

1. 在文档中新增快捷指令创建步骤。
2. 步骤包括：
   - 添加“询问输入”动作，提示“本次消费金额”。
   - 添加“URL”动作，内容为 `lss://record?amount=输入结果`。
   - 添加“打开 URL”动作。
3. 说明可将快捷指令放到锁屏、控制中心或主屏。

验收：

- 用户可以照文档创建快捷指令。
- 快捷指令输入金额后能打开 App 并新增记录。

## 阶段 7：测试与验收

目标：保证 MVP 主链路稳定。

任务：

1. 为 URL 解析器添加单元测试。
2. 为今日统计逻辑添加单元测试。
3. 手动验证 URL Scheme。
4. 手动验证新增、编辑、删除流程。
5. 手动验证快捷指令流程。

建议测试用例：

- `lss://record?amount=12.5`
- `lss://record?amount=8&category=daily`
- `lss://record?amount=6&category=other`
- `lss://record?amount=abc`
- `lss://record?amount=0`
- `lss://record`
- `lss://record?amount=9&category=bad`

最终验收：

- 用户付款后可以通过快捷指令输入金额并在 3 秒内完成记账。
- App 自动进入今日页。
- 今日页能展示总额、分类占比和流水。
- 用户可以在 App 内补记、编辑和删除记录。

## 实施顺序

推荐按以下顺序实现：

1. 创建工程骨架。
2. 实现 SwiftData 模型。
3. 实现 URL 解析器，并先用单元测试锁住规则。
4. 接入 `.onOpenURL` 和落库。
5. 实现今日页。
6. 实现编辑/补记页。
7. 写快捷指令配置说明。
8. 做端到端手动验收。

这个顺序优先打通核心链路，再补齐页面能力。核心链路通了之后，即使 UI 还很朴素，也已经可以验证产品最重要的 3 秒记账目标。
