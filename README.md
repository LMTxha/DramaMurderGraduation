# DramaMurderGraduation

这是一个使用 `.NET Framework 4.8.1 + ASP.NET Web Forms + C# + SQL Server LocalDB` 开发的剧本杀门店运营系统。

## 项目位置

- 解决方案：`D:\毕业设计\code\code\DramaMurderGraduation\DramaMurderGraduation.sln`
- Web 项目：`D:\毕业设计\code\code\DramaMurderGraduation\DramaMurderGraduation.Web`

## 主要功能

- 首页动态展示公告、精选剧本、近期场次、玩家点评和站点统计
- 剧本库支持关键词与题材筛选
- 剧本详情支持角色阵容、可预约场次、历史点评展示
- 房间场次页展示主题房间与未来排期
- 在线预约页支持写入数据库并显示最近预约记录
- 玩家点评页支持按剧本筛选并统计平均评分

## 数据库说明

- 数据库使用 `MSSQLLocalDB`
- 业务数据来自 `App_Data\DramaMurderGraduationDb.mdf`
- 初始化脚本：`Database\DramaMurder.sql`
- 首次启动网站时会自动建库并写入种子数据
- 如需手动重建数据库，可运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\setup-database.ps1 -Reset
```

## 运行方式

1. 用 Visual Studio 2022 打开 `DramaMurderGraduation.sln`
2. 将 `DramaMurderGraduation.Web` 设为启动项目
3. 按 `F5` 或 `Ctrl+F5` 运行

## 技术特点

- 使用 ADO.NET 进行数据库访问
- 所有业务展示数据从数据库读取
- LocalDB 自动初始化，便于本地快速部署与调试
- 页面采用 `MasterPage + Repeater + Web Forms` 结构实现动态渲染
## 2026-04-08 新增动态游戏模块

- 游戏房间新增“剧情阶段、角色卡、线索板、行动记录”四个动态区域
- 角色分配、阶段推进、公共线索、个人线索和行动日志均从数据库读取
- 新增数据表：`GameStages`、`SessionGameStates`、`SessionCharacterAssignments`、`ScriptClues`、`SessionClueUnlocks`、`SessionActionLogs`
- 玩家可以在房间内标记就位、提交调查行动、推进阶段，并触发线索解锁
- 页面采用 `WebMethod + JavaScript + SQL Server` 方式完成无刷新动态交互，适合毕业设计答辩演示
