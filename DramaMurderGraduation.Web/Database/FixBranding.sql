UPDATE dbo.SiteSettings
SET SiteName = N'雾城剧本研究所',
    HeroTitle = N'雾城剧本杀门店运营系统',
    HeroSubtitle = N'集剧本展示、角色查询、在线预约与创作发布于一体的沉浸式剧本杀平台。',
    WelcomeText = N'本站展示的剧本、角色、房间、场次、点评与预约记录全部由数据库驱动，帮助玩家快速了解门店内容并完成选本组局。',
    AboutTitle = N'为什么玩家喜欢这里',
    AboutContent = N'系统围绕真实剧本杀门店业务设计，覆盖剧本展示、角色浏览、房间管理、场次预约、创作者投稿和玩家口碑六个模块。页面内容全部读取数据库，能够持续支撑门店运营、内容上新与审核管理。';
GO

UPDATE dbo.Announcements
SET Title = N'创作者投稿通道开放',
    Summary = N'认证作者可在创作中心提交完整剧本与角色信息，管理员审核后即可上架到剧本库。',
    PublishDate = '2026-03-18',
    IsImportant = 1
WHERE Id = 3;
GO

UPDATE dbo.Reviews
SET Content = N'还原逻辑特别完整，线索回收得很漂亮，适合喜欢慢盘真相的玩家。',
    HighlightTag = N'高还原'
WHERE Id = 1;
GO

UPDATE dbo.Reviews
SET Content = N'情感线很扎实，NPC 带入感强，房间氛围和演绎节奏都很在线。',
    HighlightTag = N'高沉浸'
WHERE Id = 2;
GO

UPDATE dbo.Reviews
SET Content = N'角色关系很细，适合熟人车，预约流程也很顺，拼车组局体验不错。',
    HighlightTag = N'角色拉扯'
WHERE Id = 7;
GO

UPDATE dbo.Reviews
SET Content = N'从剧本到房间都很完整，古风氛围、阵营博弈和演绎落点都很有记忆点。',
    HighlightTag = N'古风沉浸'
WHERE Id = 8;
GO
