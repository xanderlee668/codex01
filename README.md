# SnowboardSwap 雪板集市

一个使用 SwiftUI 构建的 iOS 二手雪板交易示例应用，涵盖浏览、筛选、收藏、发布、图片上传和站内私信等核心体验，帮助你快速演示二手交易平台的基础功能。界面采用「夜间玻璃」风格，在模拟器或真机上都能获得沉浸式体验。

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

- 🔍 **列表与筛选**：支持按地点、关键词、交易方式、成色等条件筛选雪板，并会对卖家昵称一起进行检索。
- 🖼️ **多图发布**：发布雪具时一次最多选择 6 张照片，支持预览、删除与自动压缩，兼容 iOS 16+ Photos Picker。
- ❤️ **收藏与同步**：在列表或详情页切换收藏状态，界面与消息线程会自动保持同步。
- 📝 **个人资料**：在左上角头像入口查看个人信息、修改资料、变更密码或退出登录。
- 💬 **站内私信**：演示互相关注后的私信体验，包含简单的会话记录与跟进逻辑。
- 🧭 **夜间玻璃风格**：统一封装渐变背景、玻璃卡片、按钮样式，提供半透明夜间配色与动效反馈。

> 应用使用本地假数据演示流程，发布与消息不会调用真实接口。代码里已加入中文注释，便于理解关键流程。

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

5. **阅读代码**
   - 主要逻辑位于 `Sources/` 目录，根据 `Models`、`ViewModels`、`Views` 分类存放；
   - 关键业务（如图片上传、筛选逻辑、登录与个人资料）均已添加中文注释，查找对应文件即可快速定位；
   - 如果需要修改 UI 风格，可从 `Sources/Views/NightStyle.swift` 入手，里面封装了统一的渐变、玻璃卡片与按钮样式。

6. **真机调试（可选）**
   - 在 `Window ▸ Devices and Simulators` 中添加已连接的 iPhone；
   - 使用 Apple ID 配置开发者证书后即可运行到真机。

## 📦 后续扩展建议

- 接入真实后端接口，实现登录、图片上传、下单等功能。
- 使用 Core Data / CloudKit 持久化收藏与聊天记录。
- 加入推送通知或即时通信能力。
- 集成定位或地图，展示可面交地点。

欢迎根据需求继续扩展 SnowboardSwap！
