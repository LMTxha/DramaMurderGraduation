# DramaMurderGraduation

`DramaMurderGraduation` 是一个基于 `.NET Framework 4.8.1 + ASP.NET Web Forms + C# + SQL Server LocalDB` 的剧本杀门店运营与玩家服务系统。项目围绕门店日常经营、内容展示、在线预约、订单管理、会员钱包、后台审核、DM 场控、好友互动和观战玩法等业务场景展开，目标是提供一个可本地启动、可稳定运行、可持续扩展的综合型 Web 应用。

项目采用传统 Web Forms 页面结构，使用 ADO.NET 直接访问数据库，页面与业务逻辑分层较清晰，适合继续迭代页面功能、业务规则和数据结构。

## 项目概览

- 解决方案文件：`DramaMurderGraduation.sln`
- Web 项目：`DramaMurderGraduation.Web`
- 默认数据库：
  - `DramaMurderGraduationDb.mdf`
  - `DramaMurderGraduationDb_log.ldf`
- 主要配置文件：`DramaMurderGraduation.Web/Web.config`
- 数据初始化与迁移入口：`DramaMurderGraduation.Web/Data/SqlDatabaseInitializer.cs`

## 系统包含的核心模块

### 1. 门店展示与内容浏览

- 首页展示站点信息、公告、精选剧本、近期场次、用户评价和基础运营指标
- 剧本列表支持按关键词、题材、人数、难度等条件筛选
- 剧本详情页展示封面、简介、角色阵容、场次信息和评论数据
- 房间场次页集中展示门店房间、预约场次和相关排期内容
- 门店联系页提供门店介绍、联系信息和业务引导入口

### 2. 用户账户与身份体系

- 注册、登录、退出、忘记密码、密码重置
- 当前用户身份上下文管理
- 用户审核状态与角色能力控制
- 安全中心与个人设置
- 头像、通知、基础资料等个人配置项

### 3. 预约、订单与售后

- 在线预约下单
- 订单详情查看
- 订单沟通记录
- 预约状态跟踪
- 到店核销码与签到凭证
- 售后状态、退款链路与关联记录

### 4. 钱包与充值审核

- 用户钱包余额展示
- 钱包流水记录
- 充值申请提交
- 管理端充值审核
- 充值订单号、交易关联、异常流水审计

### 5. 后台审核与运营管理

- 管理员审核工作台 `AdminReview.aspx`
- 用户审核、充值审核、预约审核、评论审核等聚合视图
- 数据分析页 `Analytics.aspx`
- 不同角色能力控制，例如后台访问、分析访问、DM 主持权限等

### 6. DM 游戏与互动玩法

- DM 主持台
- 游戏大厅、游戏房间、游戏结果页
- 角色卡、线索、阶段推进、行动日志等游戏过程页面
- 观战模式、直播列表、互动聊天等扩展页面

### 7. 社交与互动功能

- 好友系统
- 私聊与群聊页面
- 动态/社区/评论扩展
- 玩家中心与好友主页
- 转账、礼物、通知等互动能力

## 主要页面入口

以下页面是当前项目中较核心的业务入口：

- `Default.aspx`：首页
- `ScriptsList.aspx`：剧本列表
- `ScriptDetails.aspx`：剧本详情
- `Rooms.aspx`：房间与场次
- `Booking.aspx`：在线预约
- `OrderDetails.aspx`：订单详情
- `Wallet.aspx`：钱包与余额
- `AdminReview.aspx`：后台审核中心
- `Analytics.aspx`：运营分析
- `DmDashboard.aspx`：DM 主持台
- `PlayerHub.aspx`：玩家中心
- `Friends.aspx`：好友互动
- `Spectator.aspx`：观战功能入口

## 目录结构说明

```text
DramaMurderGraduation/
├─ DramaMurderGraduation.sln
├─ DramaMurderGraduationDb.mdf
├─ DramaMurderGraduationDb_log.ldf
├─ README.md
├─ Tools/
└─ DramaMurderGraduation.Web/
   ├─ App_Code/
   ├─ App_Data/
   ├─ Content/
   ├─ Data/
   ├─ Database/
   ├─ Models/
   ├─ Scripts/
   ├─ Uploads/
   ├─ *.aspx / *.master
   ├─ Global.asax
   ├─ Web.config
   └─ setup-database.ps1
```

### 关键目录职责

- `Data/`：仓储与数据访问逻辑，包含账户、内容、功能、数据库初始化等
- `Models/`：页面与业务使用的数据模型
- `Database/`：初始化 SQL、种子数据和增量变更脚本
- `Scripts/`：前端脚本
- `Content/`：样式、静态资源
- `Uploads/`：上传文件目录

## 技术栈

- 后端框架：ASP.NET Web Forms
- 运行时：.NET Framework 4.8.1
- 语言：C#
- 数据访问：ADO.NET / `System.Data.SqlClient`
- 数据库：SQL Server LocalDB
- 前端：HTML、CSS、JavaScript
- 页面组织：`MasterPage + Web Forms + Repeater + Server Controls`

## 运行环境要求

建议本地具备以下环境：

- Visual Studio 2022
- `.NET Framework 4.8.1` Targeting Pack
- SQL Server LocalDB
- IIS Express
- Windows PowerShell

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/LMTxha/DramaMurderGraduation.git
cd DramaMurderGraduation
```

### 2. 打开解决方案

使用 Visual Studio 2022 打开：

```text
DramaMurderGraduation.sln
```

### 3. 设置启动项目

- 将 `DramaMurderGraduation.Web` 设置为启动项目
- 运行配置选择 `IIS Express`

### 4. 检查数据库配置

默认配置位于 `DramaMurderGraduation.Web/Web.config`：

```xml
<connectionStrings>
  <add name="DramaMurderDb"
       connectionString="Data Source=(LocalDB)\MSSQLLocalDB;Initial Catalog=DramaMurderGraduationDb;Integrated Security=True;Connect Timeout=30;MultipleActiveResultSets=True"
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

相关应用设置：

- `DatabaseName=DramaMurderGraduationDb`
- `DatabaseDirectory=D:\毕业设计\dramamurder`
- `AiDefaultProvider=nvidia`

如果你的本地目录与仓库默认目录不同，需要根据实际路径调整 `DatabaseDirectory` 或连接字符串。

### 5. 初始化数据库

项目启动时会执行：

- `Global.asax.cs`
- `SqlDatabaseInitializer.EnsureDatabase()`

系统会在启动时检查数据库是否存在、是否需要执行建库或增量迁移。

如果你需要手动重建数据库，可以在 `DramaMurderGraduation.Web` 目录运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\setup-database.ps1 -Reset
```

如果需要恢复测试数据，还可以使用：

```powershell
.\reset-demo-data.ps1
```

或：

```cmd
reset-demo-data.cmd
```

### 6. 启动项目

在 Visual Studio 中按 `F5` 或 `Ctrl+F5` 运行。

## 默认账号

当前仓库中常用的管理员测试账号为：

- 用户名：`admin`
- 密码：`admin123456`

如果你已经重置数据库或改动过种子数据，请以当前数据库中的实际账号信息为准。

## 数据库与初始化机制

### 数据来源

- 主数据库文件位于仓库根目录
- 初始化脚本位于 `DramaMurderGraduation.Web/Database/`
- 项目启动时会自动检查结构差异并补齐增量字段或表

### 初始化特点

- 支持首次启动自动建库
- 支持增量迁移标记
- 使用 `SchemaMigrations` 记录执行结果
- 允许在本地开发环境重复运行并保持结构一致

## 开发说明

### 编译与页面校验

本项目除了普通编译，还建议执行一次 ASP.NET 预编译检查，以尽早发现以下问题：

- `.aspx` / `.master` 标记与 `.designer.cs` 不一致
- `runat="server"` 控件缺失
- 页面代码后置引用了未声明字段
- 服务器端表达式缺少对应属性

### 常见开发注意事项

- Web Forms 页面改动时，标记文件、代码后置和设计器文件要保持一致
- 新增模型属性后，要同步检查仓储映射和页面使用处
- 修改数据库字段后，要同步更新初始化脚本和读取逻辑
- 针对可选 SQL 字段，优先采用安全读取方式，避免运行期因缺列抛异常
- `README`、数据库脚本、模型定义和页面逻辑要一起维护，避免仓库远端与本地状态不一致

## AI 与扩展能力

项目中包含 AI 相关页面与配置，例如：

- `AiSearch.aspx`
- `AiGatewayClient.cs`
- `AiDefaultProvider`
- `AiDefaultSystemPrompt`

这部分功能默认保留扩展位。若要接入真实模型服务，需要根据所选服务商补充实际接口配置与密钥管理。

## 当前仓库适用场景

该项目适合用于以下工作：

- 本地功能开发与调试
- 门店运营类系统原型扩展
- Web Forms 项目维护与重构
- 业务流程验证
- 数据结构与后台管理流程验证

## 后续可继续完善的方向

- 补充更完整的自动化测试
- 为关键仓储增加独立 smoke test
- 统一页面编码与文本资源
- 梳理未完成的扩展页并区分正式页面与概念页
- 增加部署说明与生产环境配置模板

## 仓库地址

- GitHub: <https://github.com/LMTxha/DramaMurderGraduation.git>
