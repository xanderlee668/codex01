# SnowboardSwap 雪板集市

一个使用 SwiftUI 构建的 iOS 二手雪板交易示例应用，涵盖浏览、筛选、收藏、发布和站内私信等核心体验，帮助你快速演示二手交易平台的基础功能。

## 📁 目录结构

```
codex01/
├── SnowboardSwap.xcodeproj      # Xcode 工程文件
├── Sources/                     # Swift 代码（入口、Models、ViewModels、Views）
│   ├── SnowboardSwapApp.swift   # App 入口
│   ├── Models/                  # 数据模型与样例数据
│   ├── ViewModels/              # 视图模型
│   └── Views/                   # SwiftUI 页面
├── Resources/                   # Info.plist 与 Assets 资源
├── Preview Content/             # SwiftUI 预览资源
└── README.md                    # 项目说明
```

## ✨ 功能亮点

- 🔍 **列表与筛选**：支持按地点、关键词、交易方式、成色等条件筛选雪板。
- ❤️ **收藏**：在列表或详情页切换收藏状态，快速关注目标雪板。
- 📝 **发布**：填写标题、价格、成色、交易方式等信息模拟发布。
- 💬 **消息**：内置消息线程示例，展示与卖家往来的会话界面。
- 👤 **卖家信息**：查看卖家评分与成交次数，便于评估信誉。

> 应用内置本地假数据用于演示，发布与消息不会调用真实接口。

## 🛠️ 环境要求

- macOS 13 或更新版本
- [Xcode 15](https://developer.apple.com/xcode/)（包含 Swift 5.9 工具链与 iOS 17 模拟器）

首次启动 Xcode 时需同意许可协议并等待附加组件安装完成。

## 🚀 运行步骤

1. **克隆仓库**
   ```bash
   git clone <你的仓库地址>
   cd codex01
   ```

2. **打开工程**
   - Finder 中双击 `SnowboardSwap.xcodeproj`；或
   - 终端执行：
     ```bash
     open SnowboardSwap.xcodeproj
     ```

3. **选择 Scheme 与设备**
   - 确保左上角 Scheme 选择器中是 `SnowboardSwap`；
   - 选择一个 iOS 模拟器（例如 *iPhone 15*）。

4. **构建并运行**
   - 按 `⌘R` 或点击 ▶️ 按钮运行；
   - 若使用命令行：
     ```bash
     xcodebuild -scheme SnowboardSwap -destination 'platform=iOS Simulator,name=iPhone 15'
     ```

5. **真机调试（可选）**
   - 在 `Window ▸ Devices and Simulators` 中添加已连接的 iPhone；
   - 使用 Apple ID 配置开发者证书后即可运行到真机。

## 📦 后续扩展建议

- 接入真实后端接口，实现登录、图片上传、下单等功能。
- 使用 Core Data / CloudKit 持久化收藏与聊天记录。
- 加入推送通知或即时通信能力。
- 集成定位或地图，展示可面交地点。

欢迎根据需求继续扩展 SnowboardSwap！
