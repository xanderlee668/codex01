# SnowboardSwap 雪板集市

一个使用 SwiftUI 构建的 iOS 二手雪板交易示例应用，提供类似于咸鱼等二手平台的核心体验：浏览雪板列表、筛选、收藏、发布以及与卖家沟通。

## 功能亮点

- 🔍 **列表 & 筛选**：按地点、关键词、交易方式与成色快速定位目标雪板。
- ❤️ **收藏**：在列表或详情页切换收藏状态，随时关注心仪雪板。
- 📝 **发布**：通过表单录入标题、价格、成色、交易方式等信息。
- 💬 **沟通**：内置消息线程界面，支持与卖家建立对话并发送消息。
- 👤 **卖家卡片**：展示卖家评分与成交次数，便于评估信誉。

## 目录结构

```
SnowboardSwap/
├── SnowboardSwap.xcodeproj     # Xcode 工程文件
├── Models/                     # 数据模型与样例数据
├── ViewModels/                 # 视图模型
├── Views/                      # SwiftUI 界面
├── Resources/                  # 资源（Assets、Info.plist）
├── Preview Content/            # SwiftUI 预览资源
├── SnowboardSwapApp.swift      # App 入口
└── README.md
```

## 在 macOS 上运行

1. **准备环境**
   - 安装 [Xcode](https://developer.apple.com/xcode/) 15 或以上版本（会自动包含 Swift 5.9+ 工具链与 iOS 模拟器）。
   - 第一次使用 Xcode 时，建议先打开一次 `Xcode.app`，在弹出的许可协议中选择同意，并等待其安装附加组件。

2. **获取代码**
   - 通过 `git clone` 将仓库克隆到本地：
     ```bash
     git clone <你的仓库地址>
     cd SnowboardSwap
     ```
   - 如果你已经获取到压缩包，直接在 Finder 中解压即可。

3. **打开工程**
   - 双击 `SnowboardSwap/SnowboardSwap.xcodeproj`，或在终端执行：
     ```bash
     open SnowboardSwap/SnowboardSwap.xcodeproj
     ```
   - Xcode 会自动解析工程。等待左上角状态栏的索引进度完成后再继续下一步。

4. **选择运行目标**
   - 在 Xcode 左上角的 Scheme 选择器中，确保选中 `SnowboardSwap`，并挑选一个可用的模拟器设备（例如 *iPhone 15*）。

5. **构建并运行**
   - 直接按 `Cmd + R`，或点击 Xcode 左上角的 ▶️ 按钮即可在模拟器启动应用。
   - 如果偏好命令行构建，可在终端执行：
     ```bash
     xcodebuild -scheme SnowboardSwap -destination 'platform=iOS Simulator,name=iPhone 15'
     ```

6. **真机调试（可选）**
   - 将 iPhone 连接到 Mac，在 Xcode 中通过 `Window ▸ Devices and Simulators` 添加设备。
   - 使用个人 Apple ID 配置开发者证书后，即可将 Scheme 目标切换为你的设备并运行。

> ⚠️ 应用内置假数据用于演示，发布与消息功能为本地模拟，不会调用真实网络接口。

## 后续扩展建议

- 接入真实后端接口，实现登录、图片上传与订单跟踪。
- 增加聊天记录持久化与推送通知。
- 使用 Core Data 或 CloudKit 保存收藏与草稿。
- 引入地图或定位功能，展示附近可面交的雪板。

欢迎根据自身需求继续扩展！
