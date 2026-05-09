# DramaMurderGraduation 项目流程图

本文档根据当前项目源码整理，适合放入论文、答辩文档或 PPT。项目主体是 `DramaMurderGraduation.Web`，技术栈为 `.NET Framework 4.8.1 + ASP.NET Web Forms + C# + SQL Server LocalDB`。

## 1. 系统架构流程图

```mermaid
flowchart TB
    User["用户 / 管理员 / DM"] --> Browser["浏览器"]
    Browser --> Master["Site.Master<br/>统一导航、用户状态、页面布局"]
    Master --> Page["Web Forms 页面<br/>*.aspx + *.aspx.cs"]

    Page --> Auth["AuthManager<br/>Session 登录态与角色权限"]
    Page --> Repo["Repository 数据访问层"]
    Page --> Model["Models<br/>页面数据模型"]
    Page --> Static["Content / Scripts / Uploads<br/>样式、脚本、上传资源"]

    Repo --> AccountRepo["AccountRepository<br/>账号、钱包、好友、礼物"]
    Repo --> ContentRepo["ContentRepository<br/>剧本、场次、预约、售后、通知"]
    Repo --> GameRepo["GameRepository<br/>游戏房间、角色、线索、投票、结算"]
    Repo --> FeatureRepo["FeatureRepository<br/>推荐、分析、观战、能力值"]
    Repo --> FriendRepo["FriendWorkspaceRepository<br/>群聊、便签、桌面设置"]

    AccountRepo --> Db["DbHelper<br/>创建 SqlConnection"]
    ContentRepo --> Db
    GameRepo --> Db
    FeatureRepo --> Db
    FriendRepo --> Db

    Db --> Sql["SQL Server LocalDB<br/>DramaMurderGraduationDb"]
    Sql --> Files["DramaMurderGraduationDb.mdf / .ldf"]

    Global["Global.asax.cs<br/>Application_Start"] --> Init["SqlDatabaseInitializer.EnsureDatabase"]
    Init --> Sql
```

## 2. 项目启动与数据库初始化流程

```mermaid
flowchart TD
    A["IIS Express / ASP.NET 应用启动"] --> B["Global.asax.cs<br/>Application_Start"]
    B --> C["SqlDatabaseInitializer.EnsureDatabase()"]
    C --> D["读取 Web.config<br/>连接字符串、数据库名、数据库目录"]
    D --> E{"数据库是否存在?"}
    E -- "已存在" --> H["检查核心表结构"]
    E -- "不存在，但 mdf/ldf 存在" --> F["附加本地数据库文件"]
    E -- "不存在，且无文件" --> G["创建 LocalDB 数据库"]
    F --> H
    G --> H
    H --> I{"表结构是否完整?"}
    I -- "不完整" --> J["执行 Database/DramaMurder.sql"]
    I -- "完整" --> K["执行增量迁移检查"]
    J --> K
    K --> L["写入 SchemaMigrations 记录"]
    L --> M["站点进入可访问状态"]
```

## 3. 系统核心业务总流程

```mermaid
flowchart LR
    A["游客访问首页"] --> B["浏览剧本库、房间场次、评价、门店信息"]
    B --> C["注册账号"]
    C --> D["后台审核用户"]
    D --> E{"审核通过?"}
    E -- "否" --> C
    E -- "是" --> F["登录系统"]
    F --> G["钱包充值 / 获取优惠券"]
    G --> H["选择剧本和场次"]
    H --> I["提交预约"]
    I --> J["系统校验容量、余额、优惠券"]
    J --> K["扣费并生成预约订单"]
    K --> L["后台确认预约 / 到店核销"]
    L --> M["进入 GameLobby / GameRoom"]
    M --> N["DM 控场：开局、阶段、线索、投票、结算"]
    N --> O["玩家评价、复购推荐、好友互动"]
```

## 4. 登录、注册与权限控制流程

```mermaid
flowchart TD
    A["用户提交注册表单<br/>Register.aspx"] --> B["Register.aspx.cs<br/>btnRegister_Click"]
    B --> C["AccountRepository.Register"]
    C --> D["Users 新增账号<br/>RoleCode=Player<br/>ReviewStatus=Pending"]
    D --> E["管理员进入 AdminReview.aspx"]
    E --> F["AccountRepository.ReviewUser<br/>审核通过或驳回"]
    F --> G["用户登录 Login.aspx"]
    G --> H["AccountRepository.Authenticate<br/>校验用户名、密码哈希、审核状态"]
    H --> I{"认证通过?"}
    I -- "否" --> J["返回错误提示并记录登录日志"]
    I -- "是" --> K["AuthManager.SignIn<br/>写入 Session 当前用户"]
    K --> L["根据角色跳转默认页面"]
    L --> M{"访问受保护页面"}
    M --> N["RequireApprovedUser<br/>普通玩家页面"]
    M --> O["RequireAdminConsole<br/>后台审核页面"]
    M --> P["RequireGameManager<br/>DM 主持台 / 游戏管理"]
```

## 5. 在线预约与交易流程

```mermaid
flowchart TD
    A["玩家进入 Booking.aspx"] --> B["AuthManager.RequireApprovedUser"]
    B --> C["加载可预约场次<br/>GetUpcomingSessions"]
    C --> D["加载余额、优惠券、历史订单、候补列表"]
    D --> E["玩家选择场次并提交预约"]
    E --> F["页面层校验<br/>联系人、手机号、人数、场次"]
    F --> G["ContentRepository.CreateReservation"]
    G --> H["开启 SQL 事务"]
    H --> I["锁定场次容量<br/>防止并发超卖"]
    I --> J{"剩余名额是否足够?"}
    J -- "否" --> X["回滚事务<br/>提示名额不足"]
    J -- "是" --> K["校验优惠券和订单金额"]
    K --> L{"钱包余额是否足够?"}
    L -- "否" --> Y["回滚事务<br/>提示充值"]
    L -- "是" --> M["扣减 Users.Balance"]
    M --> N["写入 WalletTransactions 钱包流水"]
    N --> O["写入 Reservations 预约订单<br/>生成核销码"]
    O --> P["更新优惠券 / 候补状态"]
    P --> Q["提交事务"]
    Q --> R["跳转 GameLobby.aspx?reservationId=..."]
```

## 6. 后台审核与运营管理流程

```mermaid
flowchart TB
    A["后台用户访问 AdminReview.aspx"] --> B["AuthManager.RequireAdminConsole"]
    B --> C["ApplyCapabilityState<br/>按角色开启能力"]
    C --> D["BindAll<br/>聚合后台待办数据"]

    D --> E["用户审核 / 角色调整"]
    D --> F["充值审核 / 财务导出"]
    D --> G["预约确认 / 到店核销"]
    D --> H["售后退款 / 申诉处理"]
    D --> I["评论审核 / 管理回复"]
    D --> J["剧本投稿审核"]
    D --> K["排期、房间、公告、优惠券管理"]

    E --> E1["AccountRepository.ReviewUser / UpdateUserRole"]
    F --> F1["AccountRepository.ReviewRechargeRequest"]
    G --> G1["ContentRepository.ReviewReservation / CheckInReservationByCode"]
    H --> H1["ContentRepository.ReviewAfterSaleRequest"]
    I --> I1["ContentRepository.ModerateReview"]
    J --> J1["ContentRepository.ReviewScriptSubmission"]
    K --> K1["ContentRepository.CreateAdminSession / UpdateRoomStatus / CreateAnnouncement / IssueCoupon"]

    E1 --> L["写入 SQL Server 并刷新后台列表"]
    F1 --> L
    G1 --> L
    H1 --> L
    I1 --> L
    J1 --> L
    K1 --> L
```

## 7. DM 主持与游戏房间流程

```mermaid
flowchart TD
    A["DM 进入 DmDashboard.aspx"] --> B["AuthManager.RequireGameManager"]
    B --> C["加载 DM 场次日程<br/>GetDmSessions"]
    C --> D["DM 接受主持任务 / 进入房间"]
    D --> E["GameRoom.aspx?reservationId=..."]
    E --> F["校验预约归属或 DM 权限"]
    F --> G["GameRepository.EnsureSessionGameData"]
    G --> H["初始化游戏状态<br/>SessionGameStates"]
    G --> I["分配角色<br/>SessionCharacterAssignments"]
    G --> J["准备线索<br/>ScriptClues / SessionClueUnlocks"]

    H --> K["前端轮询 GetRoomState"]
    I --> K
    J --> K
    K --> L["返回房间快照<br/>参与者、聊天、阶段、角色、线索、行动、投票"]

    L --> M["玩家操作<br/>准备、聊天、搜证、投票"]
    L --> N["DM 操作<br/>开局、推进阶段、广播、发线索、设置真相、计时、结算"]
    M --> K
    N --> K
    N --> O["FinishGame<br/>生成战绩和结算结果"]
    O --> P["GameResult.aspx<br/>查看复盘结果"]
```

## 8. 玩家中心与社交流程

```mermaid
flowchart LR
    A["玩家登录后"] --> B["PlayerHub.aspx<br/>玩家中心"]
    B --> C["档案、能力值、成就、战绩"]
    B --> D["预约时间线、订单状态、通知"]
    B --> E["复购推荐、活动入口"]
    B --> F["Friends.aspx<br/>好友工作台"]

    F --> G["好友申请 / 好友列表"]
    F --> H["私聊 / 附件 / 位置 / 语音"]
    F --> I["群聊 / 快捷便签"]
    F --> J["动态 / 点赞 / 评论"]
    F --> K["礼物 / 转账 / 红包"]

    G --> L["AccountRepository"]
    H --> L
    J --> L
    K --> L
    I --> M["FriendWorkspaceRepository"]
    L --> N["SQL Server"]
    M --> N
```

## 9. 主要源码对应关系

| 流程节点 | 主要源码 |
| --- | --- |
| 应用启动与建库 | `DramaMurderGraduation.Web/Global.asax.cs`、`DramaMurderGraduation.Web/Data/SqlDatabaseInitializer.cs` |
| 统一数据库连接 | `DramaMurderGraduation.Web/Data/DbHelper.cs` |
| 登录、注册、权限 | `DramaMurderGraduation.Web/Login.aspx.cs`、`DramaMurderGraduation.Web/Register.aspx.cs`、`DramaMurderGraduation.Web/Data/AuthManager.cs` |
| 账号、钱包、好友 | `DramaMurderGraduation.Web/Data/AccountRepository.cs` |
| 剧本、场次、预约、售后 | `DramaMurderGraduation.Web/Data/ContentRepository.cs`、`DramaMurderGraduation.Web/Booking.aspx.cs` |
| 后台审核 | `DramaMurderGraduation.Web/AdminReview.aspx.cs` |
| DM 主持台 | `DramaMurderGraduation.Web/DmDashboard.aspx.cs` |
| 游戏房间 | `DramaMurderGraduation.Web/GameRoom.aspx.cs`、`DramaMurderGraduation.Web/Data/GameRepository.cs` |
| 玩家中心与推荐 | `DramaMurderGraduation.Web/PlayerHub.aspx.cs`、`DramaMurderGraduation.Web/Data/FeatureRepository.cs` |
| 好友工作台 | `DramaMurderGraduation.Web/Friends.aspx.cs`、`DramaMurderGraduation.Web/Data/FriendWorkspaceRepository.cs` |
