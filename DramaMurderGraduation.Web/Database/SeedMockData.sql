SET NOCOUNT ON;

IF OBJECT_ID(N'dbo.ShowcasePages', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ShowcasePages
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        PageKey NVARCHAR(120) NOT NULL UNIQUE,
        PageName NVARCHAR(120) NOT NULL,
        Eyebrow NVARCHAR(60) NOT NULL,
        HeroTitle NVARCHAR(200) NOT NULL,
        HeroSummary NVARCHAR(600) NOT NULL,
        HeroDescription NVARCHAR(1000) NOT NULL,
        BadgeText NVARCHAR(100) NOT NULL,
        PrimaryActionText NVARCHAR(80) NULL,
        PrimaryActionUrl NVARCHAR(200) NULL,
        SecondaryActionText NVARCHAR(80) NULL,
        SecondaryActionUrl NVARCHAR(200) NULL
    );
END
GO

IF OBJECT_ID(N'dbo.ShowcaseStats', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ShowcaseStats
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        ShowcasePageId INT NOT NULL,
        StatLabel NVARCHAR(80) NOT NULL,
        StatValue NVARCHAR(80) NOT NULL,
        SortOrder INT NOT NULL CONSTRAINT DF_ShowcaseStats_SortOrder DEFAULT(1),
        CONSTRAINT FK_ShowcaseStats_Page FOREIGN KEY (ShowcasePageId) REFERENCES dbo.ShowcasePages(Id)
    );
END
GO

IF OBJECT_ID(N'dbo.ShowcaseSections', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ShowcaseSections
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        ShowcasePageId INT NOT NULL,
        SectionTitle NVARCHAR(160) NOT NULL,
        SectionSummary NVARCHAR(600) NOT NULL,
        LayoutCode NVARCHAR(40) NULL,
        SortOrder INT NOT NULL CONSTRAINT DF_ShowcaseSections_SortOrder DEFAULT(1),
        CONSTRAINT FK_ShowcaseSections_Page FOREIGN KEY (ShowcasePageId) REFERENCES dbo.ShowcasePages(Id)
    );
END
GO

IF OBJECT_ID(N'dbo.ShowcaseEntries', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ShowcaseEntries
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        ShowcaseSectionId INT NOT NULL,
        Title NVARCHAR(160) NOT NULL,
        Summary NVARCHAR(600) NOT NULL,
        TagText NVARCHAR(80) NOT NULL,
        MetaPrimary NVARCHAR(120) NULL,
        MetaSecondary NVARCHAR(120) NULL,
        MetaTertiary NVARCHAR(120) NULL,
        ImageUrl NVARCHAR(300) NULL,
        ActionText NVARCHAR(80) NULL,
        ActionUrl NVARCHAR(200) NULL,
        AccentValue NVARCHAR(80) NULL,
        SortOrder INT NOT NULL CONSTRAINT DF_ShowcaseEntries_SortOrder DEFAULT(1),
        CONSTRAINT FK_ShowcaseEntries_Section FOREIGN KEY (ShowcaseSectionId) REFERENCES dbo.ShowcaseSections(Id)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Genres)
BEGIN
    INSERT INTO dbo.Genres(Name, Description)
    VALUES
    (N'本格推理', N'线索清晰、动机闭环，适合喜欢还原真相的玩家。'),
    (N'情感沉浸', N'角色关系浓度高，重视演绎、代入与情绪表达。'),
    (N'机制阵营', N'包含阵营对抗、任务推进和多阶段信息差。'),
    (N'恐怖惊悚', N'灯光、音效和场景压迫感更强，适合沉浸体验。');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SiteSettings)
BEGIN
    INSERT INTO dbo.SiteSettings(SiteName, HeroTitle, HeroSubtitle, WelcomeText, AboutTitle, AboutContent, Address, BusinessHours, ContactPhone, ContactWeChat)
    VALUES
    (N'雾城剧本研究所', N'剧本杀门店运营系统', N'剧本展示、在线预约、房间管理、游戏推进与玩家社区一体化', N'所有核心业务数据均来自 SQL Server LocalDB，适合毕业设计演示和本地调试。', N'系统说明', N'系统覆盖剧本库、场次预约、玩家中心、DM 游戏房、观战与数据看板等模块。', N'苏州市工业园区星幕路 18 号', N'周一至周日 10:00 - 23:30', N'400-0512-1314', N'MistLab1314');
END
GO

DECLARE @PasswordHash NVARCHAR(64) = N'8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92';

IF NOT EXISTS (SELECT 1 FROM dbo.Users)
BEGIN
    INSERT INTO dbo.Users(Username, PasswordHash, DisplayName, Email, Phone, RoleCode, ReviewStatus, ReviewRemark, Balance, CreatedAt, ReviewedAt)
    VALUES
    (N'admin', @PasswordHash, N'系统管理员', N'admin@dramamurder.local', N'13800000000', N'Admin', N'Approved', N'默认管理员账号', 2000, GETDATE(), GETDATE()),
    (N'dm01', @PasswordHash, N'门店 DM 阿岚', N'dm01@dramamurder.local', N'13800000001', N'DM', N'Approved', N'门店主持人账号', 1500, GETDATE(), GETDATE()),
    (N'user1', @PasswordHash, N'玩家一号', N'user1@dramamurder.local', N'13800001001', N'Player', N'Approved', N'演示玩家账号', 1200, GETDATE(), GETDATE()),
    (N'user2', @PasswordHash, N'玩家二号', N'user2@dramamurder.local', N'13800001002', N'Player', N'Approved', N'演示玩家账号', 1200, GETDATE(), GETDATE()),
    (N'user3', @PasswordHash, N'玩家三号', N'user3@dramamurder.local', N'13800001003', N'Player', N'Approved', N'演示玩家账号', 1200, GETDATE(), GETDATE()),
    (N'user4', @PasswordHash, N'玩家四号', N'user4@dramamurder.local', N'13800001004', N'Player', N'Approved', N'演示玩家账号', 1200, GETDATE(), GETDATE()),
    (N'user5', @PasswordHash, N'玩家五号', N'user5@dramamurder.local', N'13800001005', N'Player', N'Approved', N'演示玩家账号', 1200, GETDATE(), GETDATE()),
    (N'user6', @PasswordHash, N'玩家六号', N'user6@dramamurder.local', N'13800001006', N'Player', N'Approved', N'演示玩家账号', 1200, GETDATE(), GETDATE());
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.PlayerProfiles)
BEGIN
    INSERT INTO dbo.PlayerProfiles(UserId, DisplayName, DisplayTitle, Motto, AvatarUrl, FavoriteGenre, JoinDays, CompletedScripts, WinRate, ReputationLevel)
    SELECT Id, DisplayName, N'雾城认证玩家', N'今晚也要还原真相', N'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80', N'本格推理', 30 + Id, 4 + Id, 60 + Id, N'银牌侦探'
    FROM dbo.Users
    WHERE RoleCode = N'Player';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.PlayerAbilities)
BEGIN
    INSERT INTO dbo.PlayerAbilities(UserId, DeductionPower, ObservationPower, CreativityPower, CollaborationPower, ExecutionPower)
    SELECT Id, 72 + Id, 68 + Id, 66 + Id, 75 + Id, 70 + Id
    FROM dbo.Users
    WHERE RoleCode = N'Player';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Announcements)
BEGIN
    INSERT INTO dbo.Announcements(Title, Summary, PublishDate, IsImportant)
    VALUES
    (N'五一假期场次已开放预约', N'热门本《潮声熄灯时》《长安夜宴》新增晚场，请提前锁定座位。', '2026-04-23', 1),
    (N'新手拼车专区上线', N'每周三、周四开放 4-6 人轻推理拼车，方便新玩家快速组局。', '2026-04-20', 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Scripts)
BEGIN
    DECLARE @AdminId INT = (SELECT TOP 1 Id FROM dbo.Users WHERE Username = N'admin');

    INSERT INTO dbo.Scripts(GenreId, Name, Slogan, StoryBackground, FullScriptContent, CoverImage, DurationMinutes, PlayerMin, PlayerMax, Difficulty, Price, IsFeatured, Status, AuthorName, CreatorUserId, AuditStatus, AuditComment, SubmittedAt, ReviewedAt, KillerCharacterName, TruthSummary)
    VALUES
    (1, N'潮声熄灯时', N'停电后的第七分钟，所有人都听见了第二次潮声。', N'海边疗养院旧案重启，玩家需要在互相矛盾的口供中找出延时投毒的真凶。', N'第一幕：抵达疗养院。第二幕：停电与潮声。第三幕：复盘旧案。', N'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80', 240, 6, 6, N'进阶', 198.00, 1, N'开放预约', N'顾沉', @AdminId, N'Approved', N'模拟数据', GETDATE(), GETDATE(), N'许青禾', N'凶手利用保温壶完成延时投毒，并借停电制造密室错觉。'),
    (2, N'长安夜宴', N'一场庆功夜宴之后，满城灯火都成了掩饰。', N'盛唐宫宴发生离奇命案，玩家需要在身份立场与阵营合作之间还原真相。', N'宫宴开场、暗号交换、阵营对抗、终局复盘。', N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', 300, 6, 7, N'阵营', 228.00, 1, N'开放预约', N'沈知卿', @AdminId, N'Approved', N'模拟数据', GETDATE(), GETDATE(), N'乐师温照', N'乐师利用错拍暗号调动同盟，在换盏时完成下毒。'),
    (3, N'白塔精神病院', N'如果医生开始重复病人的噩梦，谁还分得清现实。', N'闭院多年的精神病院重启夜间观察实验，灯光和录音持续侵蚀判断。', N'病历、镜面、录音和药单共同指向一次被隐藏的实验。', N'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=1200&q=80', 240, 5, 6, N'高压', 218.00, 0, N'开放预约', N'夏南', @AdminId, N'Approved', N'模拟数据', GETDATE(), GETDATE(), N'值班医生林澈', N'所谓治疗实验实为记忆诱导，凶手借药物和镜面编号重写证词。');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ScriptCharacters)
BEGIN
    DECLARE @ScriptOne INT = (SELECT Id FROM dbo.Scripts WHERE Name = N'潮声熄灯时');
    DECLARE @ScriptTwo INT = (SELECT Id FROM dbo.Scripts WHERE Name = N'长安夜宴');

    INSERT INTO dbo.ScriptCharacters(ScriptId, Name, Gender, AgeRange, Profession, Personality, SecretLine, Description)
    VALUES
    (@ScriptOne, N'许青禾', N'女', N'25-30', N'前台', N'克制敏锐', N'她比任何人都熟悉死者作息。', N'疗养院前台，旧案受害者的妹妹。'),
    (@ScriptOne, N'顾远山', N'男', N'50-60', N'院长', N'强势保守', N'他一直在掩盖八年前的事故。', N'疗养院院长，也是本案死者。'),
    (@ScriptOne, N'林澈', N'男', N'30-35', N'医生', N'冷静理性', N'他的病历缺失了一页。', N'夜班医生，掌握部分药物记录。'),
    (@ScriptOne, N'周岚', N'女', N'28-35', N'记者', N'执着直接', N'她不是第一次来疗养院。', N'调查旧案的独立记者。'),
    (@ScriptOne, N'陆鸣', N'男', N'35-40', N'维修员', N'沉默务实', N'停电并非完全偶然。', N'负责线路检修的维修员。'),
    (@ScriptOne, N'陈砚', N'男', N'24-28', N'患者家属', N'敏感冲动', N'他带来的照片改变了时间线。', N'旧案相关患者的家属。'),
    (@ScriptTwo, N'温照', N'男', N'25-30', N'乐师', N'温和谨慎', N'错拍三声是行动暗号。', N'夜宴乐师，掌握乐曲暗号。'),
    (@ScriptTwo, N'李观澜', N'男', N'30-40', N'将军', N'果断强硬', N'兵符离库并不简单。', N'庆功宴主宾。'),
    (@ScriptTwo, N'裴照夜', N'女', N'25-35', N'女官', N'周密克制', N'她负责所有酒盏。', N'宫宴内务负责人。');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms)
BEGIN
    INSERT INTO dbo.Rooms(Name, Theme, Capacity, Description, ImageUrl, Status)
    VALUES
    (N'长夜 B 厅', N'海边疗养院', 6, N'适合本格推理和沉浸复盘，支持灯光分区。', N'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80', N'可预约'),
    (N'朱雀宫宴厅', N'古风阵营', 8, N'圆桌与屏风布局，适合阵营对抗和古风演绎。', N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'可预约'),
    (N'白塔观察室', N'惊悚实验', 6, N'弱光、音效和监控屏组合，适合高压体验。', N'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=1200&q=80', N'维护中');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Sessions)
BEGIN
    INSERT INTO dbo.Sessions(ScriptId, RoomId, SessionDateTime, HostName, BasePrice, MaxPlayers, Status)
    SELECT s.Id, r.Id, '2026-04-25T19:30:00', N'门店 DM 阿岚', s.Price, s.PlayerMax, N'开放预约'
    FROM dbo.Scripts s
    CROSS APPLY (SELECT TOP 1 Id FROM dbo.Rooms WHERE Name = N'长夜 B 厅') r
    WHERE s.Name = N'潮声熄灯时';

    INSERT INTO dbo.Sessions(ScriptId, RoomId, SessionDateTime, HostName, BasePrice, MaxPlayers, Status)
    SELECT s.Id, r.Id, '2026-04-26T14:00:00', N'门店 DM 阿岚', s.Price, s.PlayerMax, N'开放预约'
    FROM dbo.Scripts s
    CROSS APPLY (SELECT TOP 1 Id FROM dbo.Rooms WHERE Name = N'朱雀宫宴厅') r
    WHERE s.Name = N'长安夜宴';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.WalletTransactions)
BEGIN
    INSERT INTO dbo.WalletTransactions(UserId, TransactionType, Amount, BalanceAfter, Summary, CreatedAt)
    SELECT Id, N'系统赠送', 1200, Balance, N'模拟账号初始化余额', GETDATE()
    FROM dbo.Users
    WHERE RoleCode = N'Player';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Reservations)
BEGIN
    DECLARE @DemoSessionId INT = (SELECT TOP 1 Id FROM dbo.Sessions ORDER BY Id);

    INSERT INTO dbo.Reservations(SessionId, UserId, ContactName, Phone, PlayerCount, UnitPrice, TotalAmount, PaymentStatus, PaymentTransactionId, Remark, CreatedAt, Status)
    SELECT @DemoSessionId, u.Id, u.DisplayName, u.Phone, 1, 198.00, 198.00, N'已支付',
           (SELECT TOP 1 Id FROM dbo.WalletTransactions wt WHERE wt.UserId = u.Id ORDER BY wt.Id),
           N'系统模拟同车玩家', GETDATE(), N'已确认'
    FROM dbo.Users u
    WHERE u.Username IN (N'user1', N'user2', N'user3', N'user4', N'user5', N'user6');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Reviews)
BEGIN
    INSERT INTO dbo.Reviews(ScriptId, ReviewerName, Rating, Content, ReviewDate, HighlightTag)
    SELECT Id, N'南风', 5, N'线索闭环完整，复盘很有说服力。', DATEADD(DAY, -3, GETDATE()), N'高还原' FROM dbo.Scripts WHERE Name = N'潮声熄灯时'
    UNION ALL
    SELECT Id, N'见山', 5, N'古风阵营对抗很适合多人演示。', DATEADD(DAY, -2, GETDATE()), N'阵营对抗' FROM dbo.Scripts WHERE Name = N'长安夜宴'
    UNION ALL
    SELECT Id, N'七月', 4, N'灯光与音效压迫感很强。', DATEADD(DAY, -1, GETDATE()), N'氛围沉浸' FROM dbo.Scripts WHERE Name = N'白塔精神病院';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.GameStages)
BEGIN
    INSERT INTO dbo.GameStages(StageKey, StageName, StageDescription, SortOrder, DurationMinutes)
    VALUES
    (N'opening', N'开场导入', N'DM 介绍背景，玩家确认身份并完成破冰。', 1, 20),
    (N'investigation', N'线索搜证', N'围绕案发现场、人物关系和关键物证展开调查。', 2, 35),
    (N'deduction', N'集中推理', N'交换线索、拼接时间线并锁定核心嫌疑。', 3, 30),
    (N'ending', N'终局复盘', N'完成投凶、动机还原和结局展示。', 4, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SessionGameStates)
BEGIN
    INSERT INTO dbo.SessionGameStates(SessionId, CurrentStageId, StartedAt, UpdatedAt, GameStartedAt)
    SELECT TOP 1 se.Id, gs.Id, GETDATE(), GETDATE(), GETDATE()
    FROM dbo.Sessions se
    CROSS APPLY (SELECT TOP 1 Id, DurationMinutes FROM dbo.GameStages WHERE StageKey = N'opening') gs
    ORDER BY se.Id;
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SessionCharacterAssignments)
BEGIN
    DECLARE @DemoSessionId INT = (SELECT TOP 1 Id FROM dbo.Sessions ORDER BY Id);
    DECLARE @DemoScriptId INT = (SELECT ScriptId FROM dbo.Sessions WHERE Id = @DemoSessionId);

    ;WITH ReservationRows AS
    (
        SELECT Id, ROW_NUMBER() OVER (ORDER BY Id) AS RowNumber
        FROM dbo.Reservations
        WHERE SessionId = @DemoSessionId
    ),
    CharacterRows AS
    (
        SELECT Id, ROW_NUMBER() OVER (ORDER BY Id) AS RowNumber
        FROM dbo.ScriptCharacters
        WHERE ScriptId = @DemoScriptId
    )
    INSERT INTO dbo.SessionCharacterAssignments(SessionId, ReservationId, CharacterId, IsReady, CreatedAt)
    SELECT @DemoSessionId, r.Id, c.Id, 0, GETDATE()
    FROM ReservationRows r
    INNER JOIN CharacterRows c ON c.RowNumber = r.RowNumber;
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ScriptClues)
BEGIN
    DECLARE @ScriptId INT = (SELECT Id FROM dbo.Scripts WHERE Name = N'潮声熄灯时');
    DECLARE @OpeningStageId INT = (SELECT Id FROM dbo.GameStages WHERE StageKey = N'opening');
    DECLARE @InvestigationStageId INT = (SELECT Id FROM dbo.GameStages WHERE StageKey = N'investigation');

    INSERT INTO dbo.ScriptClues(ScriptId, StageId, Title, Summary, Detail, ClueType, IsPublic, SortOrder)
    VALUES
    (@ScriptId, @OpeningStageId, N'迟到的遗书', N'所有人都收到同一封迟到十五年的遗书复印件。', N'落款时间与疗养院停电记录不一致，说明有人篡改了寄出时间。', N'文书', 1, 1),
    (@ScriptId, @InvestigationStageId, N'苦味红茶', N'茶杯残液苦味明显高于平时。', N'死者平时会加蜂蜜，案发当晚却直接饮茶，中毒时间因此提前。', N'物证', 1, 2),
    (@ScriptId, @InvestigationStageId, N'被撕掉标签的药瓶', N'维修间里有一个残留药味的空瓶。', N'药瓶不属于维修工具，说明有人试图转移嫌疑。', N'药物', 0, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages)
BEGIN
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES
    (N'游戏首页', N'游戏首页', N'GAME', N'沉浸式剧本杀游戏首页', N'展示玩家身份、场次进度、线索入口和实时协作。', N'页面数据来自 ShowcasePages、ShowcaseSections、ShowcaseEntries 和 ShowcaseStats，适合毕业设计答辩展示。', N'动态数据驱动', N'进入游戏房间', N'GameRoom.aspx?reservationId=1', N'查看剧本库', N'ScriptsList.aspx'),
    (N'数据分析看板', N'数据分析看板', N'ANALYTICS', N'门店运营数据分析看板', N'聚合预约、收入、完成率和玩家行为指标。', N'用模拟数据呈现门店运营趋势，支持后续扩展真实报表。', N'运营视角', N'查看场次', N'Rooms.aspx', N'返回首页', N'Default.aspx');

    DECLARE @PageId INT = (SELECT Id FROM dbo.ShowcasePages WHERE PageKey = N'游戏首页');
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder)
    VALUES (@PageId, N'演示玩家', N'6', 1), (@PageId, N'游戏阶段', N'4', 2), (@PageId, N'公共线索', N'2', 3), (@PageId, N'隐藏线索', N'1', 4);

    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES (@PageId, N'核心演示模块', N'展示角色分配、线索解锁、行动日志和终局复盘。', N'', 1);

    DECLARE @SectionId INT = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder)
    VALUES
    (@SectionId, N'角色分配', N'同一场次自动绑定玩家预约与角色卡。', N'游戏房', N'6 人车', N'无重复角色', N'支持 DM 管理', N'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=1200&q=80', N'进入房间', N'GameRoom.aspx?reservationId=1', N'自动分配', 1),
    (@SectionId, N'线索板', N'公共线索与隐藏线索按阶段解锁。', N'线索', N'阶段推进', N'私密线索', N'复盘可追溯', N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'查看线索', N'GameRoom.aspx?reservationId=1', N'动态解锁', 2);
END
GO
