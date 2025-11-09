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

## 🧩 后端接口对接文档

以下文档基于当前 Swift 网络层（`Sources/Networking/APIClient.swift`）整理，后端（推荐 Spring Boot 3 + Spring Security + JPA）可按照此规范实现接口，即可与 iOS 客户端互通。所有接口均以 `JSON` 作为请求体/响应体，字段命名需使用 `snake_case`。

### 1. 统一配置

| 项目 | 说明 |
| --- | --- |
| Base URL | `http://localhost:8080/api`（部署后替换域名） |
| 鉴权 | 登录后返回的 JWT，后续接口通过 `Authorization: Bearer <token>` 携带 |
| Content-Type | `application/json` |
| 日期格式 | ISO-8601（例如 `2024-05-20T10:00:00Z`） |

> 建议在 Spring Boot 中使用 `@RestController` 并统一加上 `/api` 前缀，例如 `@RequestMapping("/api")`，同时配置 `OncePerRequestFilter`/`AuthenticationFilter` 解析 JWT。

### 2. 鉴权模块 `/api/auth`

#### 2.1 注册 `POST /api/auth/register`

**Request Body**

```json
{
  "email": "user@example.com",
  "password": "123456",
  "display_name": "Snow Rider"
}
```

**Response 200**（注册成功后直接登录）

```json
{
  "token": "<JWT>",
  "user": {
    "user_id": "uuid",
    "email": "user@example.com",
    "display_name": "Snow Rider",
    "location": "London",
    "bio": "Love riding",
    "rating": 4.8,
    "deals_count": 12
  }
}
```

业务要点：

- `display_name` 必填且唯一性校验可选；
- 返回的 `token` 需在 `Authorization` 头中可被解析；
- `user` 内的字段与前端展示直接关联，缺失会回退为默认值。

#### 2.2 登录 `POST /api/auth/login`

**Request Body**：与注册相同但仅包含 `email`、`password`。

**Response 200**：同上，返回 `token + user`。

- 登录失败时请返回 401/422 状态码，并在响应体中附带 `message` 字段便于提示。

#### 2.3 获取当前用户 `GET /api/auth/me`

- 请求需携带 `Authorization: Bearer <token>`；
- 返回的 `user` 结构同登录响应；
- 主要用于 App 冷启动时恢复会话，若 Token 失效返回 401。

### 3. 列表模块 `/api/listings`

#### 3.1 查询列表 `GET /api/listings`

**Response 200**

```json
[
  {
    "listing_id": "uuid",
    "title": "Burton Custom X",
    "description": "轻度使用，附送固定器",
    "condition": "like_new",         // new / like_new / good / worn
    "price": 450.0,
    "location": "London",
    "trade_option": "face_to_face",  // face_to_face / courier / hybrid
    "is_favorite": false,
    "image_url": "https://.../board.jpg",
    "seller": {
      "seller_id": "uuid",
      "display_name": "Pro Rider",
      "rating": 4.9,
      "deals_count": 32
    }
  }
]
```

业务要点：

- 需校验 JWT；
- `condition`、`trade_option` 字段必须使用上述枚举值（全小写、下划线）；
- `seller` 信息为前端展示所需，未评分时可返回 `null`，客户端会回退为 0。

#### 3.2 创建列表 `POST /api/listings`

**Request Body**

```json
{
  "title": "Burton Custom X",
  "description": "轻度使用，附送固定器",
  "condition": "like_new",
  "price": 450.0,
  "location": "London",
  "trade_option": "face_to_face",
  "is_favorite": false,
  "image_url": "https://.../board.jpg"
}
```

业务要点：

- 后端根据 JWT 中的用户信息补充 `seller` 与 `listing_id`；
- 成功时返回与查询接口相同结构的 `Listing`；
- 若价格、字段缺失等校验失败，请返回 422 并附带错误描述。

### 4. 错误响应约定

- 建议统一返回：

```json
{
  "message": "错误提示",
  "error_code": "OPTIONAL_CODE"
}
```

- 未登录/Token 过期：`401 Unauthorized`；
- 权限不足：`403 Forbidden`；
- 请求参数错误：`422 Unprocessable Entity`；
- 服务器异常：`500 Internal Server Error`。

通过以上接口，即可完成 App 目前的登录、注册、会话恢复、列表查询与发布流程。如果后续扩展聊天、收藏、行程等能力，可在 `/api/messages`、`/api/favorites`、`/api/trips` 下扩展更多端点。
