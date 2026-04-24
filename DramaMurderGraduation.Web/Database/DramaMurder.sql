SET NOCOUNT ON;

IF OBJECT_ID(N'dbo.SchemaMigrations', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SchemaMigrations
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        MigrationKey NVARCHAR(120) NOT NULL,
        Description NVARCHAR(200) NULL,
        ScriptChecksum NVARCHAR(64) NOT NULL,
        StartedAt DATETIME NOT NULL CONSTRAINT DF_SchemaMigrations_StartedAt DEFAULT(GETDATE()),
        CompletedAt DATETIME NULL,
        Succeeded BIT NOT NULL CONSTRAINT DF_SchemaMigrations_Succeeded DEFAULT(0),
        ErrorMessage NVARCHAR(MAX) NULL,
        UpdatedAt DATETIME NOT NULL CONSTRAINT DF_SchemaMigrations_UpdatedAt DEFAULT(GETDATE())
    );

    CREATE UNIQUE INDEX UX_SchemaMigrations_MigrationKey ON dbo.SchemaMigrations(MigrationKey);
END
GO
IF OBJECT_ID(N'dbo.Genres', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Genres
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Name NVARCHAR(50) NOT NULL,
        Description NVARCHAR(200) NOT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.TodayRecommendations', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TodayRecommendations
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Title NVARCHAR(80) NOT NULL,
        Summary NVARCHAR(240) NOT NULL,
        CoverImage NVARCHAR(300) NOT NULL,
        PlayerCount INT NOT NULL,
        Difficulty NVARCHAR(20) NOT NULL,
        Rating DECIMAL(4,2) NOT NULL,
        HighlightTag NVARCHAR(40) NOT NULL,
        DestinationUrl NVARCHAR(200) NOT NULL,
        SortOrder INT NOT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.Challenges', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Challenges
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Title NVARCHAR(100) NOT NULL,
        Description NVARCHAR(240) NOT NULL,
        CoverImage NVARCHAR(300) NOT NULL,
        EndTime DATETIME NOT NULL,
        RewardSummary NVARCHAR(200) NOT NULL,
        StatusTag NVARCHAR(40) NOT NULL,
        RouteUrl NVARCHAR(200) NOT NULL,
        SortOrder INT NOT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.LiveSessions', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.LiveSessions
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Title NVARCHAR(100) NOT NULL,
        Summary NVARCHAR(240) NOT NULL,
        HostName NVARCHAR(50) NOT NULL,
        ViewerCount INT NOT NULL,
        CoverImage NVARCHAR(300) NOT NULL,
        RouteUrl NVARCHAR(200) NOT NULL,
        StatusText NVARCHAR(30) NOT NULL,
        HeatScore INT NOT NULL,
        SortOrder INT NOT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.MembershipPlans', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.MembershipPlans
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Name NVARCHAR(60) NOT NULL,
        Price DECIMAL(10,2) NOT NULL,
        BillingCycle NVARCHAR(30) NOT NULL,
        Description NVARCHAR(200) NOT NULL,
        BenefitSummary NVARCHAR(300) NOT NULL,
        HighlightText NVARCHAR(40) NOT NULL,
        SortOrder INT NOT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.IdentityOptions', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.IdentityOptions
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Name NVARCHAR(40) NOT NULL,
        Description NVARCHAR(200) NOT NULL,
        AbilityFocus NVARCHAR(100) NOT NULL,
        RecommendedFor NVARCHAR(100) NOT NULL,
        SortOrder INT NOT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Users
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Username NVARCHAR(50) NOT NULL,
        PasswordHash NVARCHAR(64) NOT NULL,
        DisplayName NVARCHAR(50) NOT NULL,
        Email NVARCHAR(100) NOT NULL,
        Phone NVARCHAR(30) NOT NULL,
        RoleCode NVARCHAR(20) NOT NULL,
        ReviewStatus NVARCHAR(20) NOT NULL,
        ReviewRemark NVARCHAR(200) NULL,
        Balance DECIMAL(10,2) NOT NULL CONSTRAINT DF_Users_Balance DEFAULT(0),
        CreatedAt DATETIME NOT NULL,
        ReviewedAt DATETIME NULL
    );
END
GO

IF OBJECT_ID(N'dbo.PlayerProfiles', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PlayerProfiles
    (
        UserId INT NOT NULL PRIMARY KEY,
        DisplayName NVARCHAR(50) NOT NULL,
        DisplayTitle NVARCHAR(50) NOT NULL,
        Motto NVARCHAR(200) NOT NULL,
        AvatarUrl NVARCHAR(300) NOT NULL,
        FavoriteGenre NVARCHAR(50) NOT NULL,
        JoinDays INT NOT NULL,
        CompletedScripts INT NOT NULL,
        WinRate DECIMAL(5,2) NOT NULL,
        ReputationLevel NVARCHAR(40) NOT NULL,
        CONSTRAINT FK_PlayerProfiles_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id)
    );
END
GO

IF OBJECT_ID(N'dbo.PlayerAbilities', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PlayerAbilities
    (
        UserId INT NOT NULL PRIMARY KEY,
        DeductionPower INT NOT NULL,
        ObservationPower INT NOT NULL,
        CreativityPower INT NOT NULL,
        CollaborationPower INT NOT NULL,
        ExecutionPower INT NOT NULL,
        CONSTRAINT FK_PlayerAbilities_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id)
    );
END
GO

IF OBJECT_ID(N'dbo.Achievements', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Achievements
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        UserId INT NOT NULL,
        Title NVARCHAR(80) NOT NULL,
        Description NVARCHAR(200) NOT NULL,
        RarityTag NVARCHAR(30) NOT NULL,
        ProgressValue INT NOT NULL,
        ProgressTotal INT NOT NULL,
        EarnedAt DATETIME NULL,
        SortOrder INT NOT NULL,
        CONSTRAINT FK_Achievements_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id)
    );
END
GO

IF OBJECT_ID(N'dbo.AnalyticsSnapshots', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AnalyticsSnapshots
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        SnapshotDate DATETIME NOT NULL,
        ActiveUsers INT NOT NULL,
        AverageSessionMinutes DECIMAL(10,2) NOT NULL,
        TotalBookings INT NOT NULL,
        RevenueAmount DECIMAL(12,2) NOT NULL,
        ConversionRate DECIMAL(5,2) NOT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.HeatmapZones', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.HeatmapZones
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ZoneName NVARCHAR(50) NOT NULL,
        HeatLevel INT NOT NULL,
        PeakPeriod NVARCHAR(40) NOT NULL,
        Summary NVARCHAR(200) NOT NULL,
        SortOrder INT NOT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.CompletionInsights', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.CompletionInsights
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        MetricType NVARCHAR(40) NOT NULL,
        Name NVARCHAR(80) NOT NULL,
        ValueDecimal DECIMAL(10,2) NOT NULL,
        Summary NVARCHAR(200) NOT NULL,
        SortOrder INT NOT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.EconomyInsights', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.EconomyInsights
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        CategoryName NVARCHAR(60) NOT NULL,
        MetricName NVARCHAR(80) NOT NULL,
        MetricValue DECIMAL(12,2) NOT NULL,
        TrendText NVARCHAR(100) NOT NULL,
        SortOrder INT NOT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.SpectatorModes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SpectatorModes
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Name NVARCHAR(60) NOT NULL,
        Description NVARCHAR(200) NOT NULL,
        SceneText NVARCHAR(120) NOT NULL,
        SortOrder INT NOT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.SpectatorRooms', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SpectatorRooms
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Title NVARCHAR(100) NOT NULL,
        ScriptName NVARCHAR(80) NOT NULL,
        HostName NVARCHAR(50) NOT NULL,
        ViewerCount INT NOT NULL,
        HeatScore INT NOT NULL,
        CoverImage NVARCHAR(300) NOT NULL,
        RoomStatus NVARCHAR(30) NOT NULL,
        RouteCode NVARCHAR(50) NOT NULL,
        SortOrder INT NOT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.SpectatorMessages', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SpectatorMessages
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        SpectatorRoomId INT NOT NULL,
        SenderName NVARCHAR(50) NOT NULL,
        Content NVARCHAR(200) NOT NULL,
        BadgeText NVARCHAR(30) NOT NULL,
        SentAt DATETIME NOT NULL,
        CONSTRAINT FK_SpectatorMessages_SpectatorRooms FOREIGN KEY (SpectatorRoomId) REFERENCES dbo.SpectatorRooms(Id)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.TodayRecommendations)
BEGIN
    INSERT INTO dbo.TodayRecommendations(Title, Summary, CoverImage, PlayerCount, Difficulty, Rating, HighlightTag, DestinationUrl, SortOrder)
    VALUES
    (N'闀垮畨澶滃', N'鍙ら闃佃惀鏈儹闂ㄦ帹鑽愶紝閫傚悎鎯充綋楠岄珮娌夋蹈鍜屽闃佃惀鍗氬紙鐨勭帺瀹跺洟闃熴€?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', 8, N'杩涢樁', 4.8, N'鍙ら鐑帹', N'ScriptDetails.aspx?id=4', 1),
    (N'鐧藉绮剧鐥呴櫌', N'楂樺帇鎯婃倸棰樻潗浠ｈ〃浣滐紝绾跨储瀵嗛泦锛屾埧闂存皼鍥磋〃鐜板己鐑堛€?, N'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=1200&q=80', 6, N'楂樺帇', 4.9, N'鎯婃倸鐖嗘', N'ScriptDetails.aspx?id=5', 2),
    (N'鏄熸捣鍥炲搷', N'绉戝够鏈哄埗涓庡彊浜嬬粨鍚堬紝閫傚悎姣曚笟璁捐灞曠ず鈥滃墽鎯?鐜╂硶鈥濆鍚堢郴缁熴€?, N'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?auto=format&fit=crop&w=1200&q=80', 7, N'鏈哄埗', 4.7, N'鏈哄埗鎺ㄨ崘', N'ScriptDetails.aspx?id=6', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Challenges)
BEGIN
    INSERT INTO dbo.Challenges(Title, Description, CoverImage, EndTime, RewardSummary, StatusTag, RouteUrl, SortOrder)
    VALUES
    (N'涓囧湥鑺傚菇褰卞彜鍫℃寫鎴?, N'闄愭椂鎸戞垬鐜╂硶锛岀帺瀹堕渶瑕佸湪鍥哄畾鍥炲悎鍐呭畬鎴愬彜鍫¤皽棰樺苟瑙ｉ攣闅愯棌缁撳眬銆?, N'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80', DATEADD(DAY, 12, GETDATE()), N'涓撳睘澶村儚妗嗐€佺█鏈夐亾鍏枫€佽崳瑾夊媼绔?, N'鍗冲皢缁撴潫', N'Discover.aspx', 1),
    (N'鏂版墜鎷艰溅鎺ㄧ悊鍛?, N'闈㈠悜鏂扮帺瀹剁殑杞绘帹鐞嗙粍灞€娲诲姩锛岄檷浣庡叆鍧戦棬妲涘苟鎻愬崌鎴块棿杞寲鐜囥€?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', DATEADD(DAY, 20, GETDATE()), N'鏂版墜绀煎寘銆佷綋楠屽埜銆佹垚闀垮窘绔?, N'鐑棬娲诲姩', N'Discover.aspx', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.LiveSessions)
BEGIN
    INSERT INTO dbo.LiveSessions(Title, Summary, HostName, ViewerCount, CoverImage, RouteUrl, StatusText, HeatScore, SortOrder)
    VALUES
    (N'闀垮畨澶滃鐩存挱澶嶇洏', N'DM 姝ｅ湪甯﹁浼楀洖鐪嬪叧閿樀钀ョ炕鐩樿妭鐐癸紝閫傚悎灞曠ず瑙傛垬妯″紡銆?, N'MC 瀛愯】', 326, N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'Spectator.aspx?roomId=1', N'鐩存挱涓?, 95, 1),
    (N'鐧藉绮剧鐥呴櫌灏栧彨澶?, N'娌夋蹈寮忛珮鍘嬪満闈㈠洖鏀撅紝瀹炴椂寮瑰箷浜掑姩鐑害杈冮珮銆?, N'MC 鏈ㄧ櫧', 281, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'Spectator.aspx?roomId=2', N'鐩存挱涓?, 88, 2),
    (N'鏄熸捣鍥炲搷鏈哄埗璁茶В', N'灞曠ず澶嶆潅鏈哄埗鏈浣曢€氳繃鍔ㄦ€侀〉闈㈣繘琛屾祦绋嬪寲鍛堢幇銆?, N'MC 娲涘窛', 198, N'https://images.unsplash.com/photo-1462331940025-496dfbfc7564?auto=format&fit=crop&w=1200&q=80', N'Spectator.aspx?roomId=3', N'棰勭害鐩存挱', 79, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.MembershipPlans)
BEGIN
    INSERT INTO dbo.MembershipPlans(Name, Price, BillingCycle, Description, BenefitSummary, HighlightText, SortOrder)
    VALUES
    (N'閾跺崱浼氬憳', 29.90, N'姣忔湀', N'閫傚悎楂橀棰勭害鐜╁锛屼韩鍙楀熀纭€鎶樻墸涓庝紭鍏堥€氱煡銆?, N'棰勭害 95 鎶樸€佹椿鍔ㄤ紭鍏堟姤鍚嶃€佹瘡鏈?1 寮犳嫾杞﹀埜', N'鍏ラ棬鎺ㄨ崘', 1),
    (N'閲戝崱浼氬憳', 59.90, N'姣忔湀', N'闈㈠悜鏍稿績鐜╁锛屽己鍖栫鍒╀笌鎴愰暱浣撶郴銆?, N'棰勭害 9 鎶樸€佷笓灞炲鏈嶃€佹瘡鏈?2 寮犱富棰樹綋楠屽埜', N'鏈€鍙楁杩?, 2),
    (N'鍒涗綔鑰呬細鍛?, 99.00, N'姣忔湀', N'闈㈠悜鍓ф湰浣滆€呬笌楂樼骇鐢ㄦ埛锛屾敮鎸佹姇绋垮拰鏁版嵁闈㈡澘鏉冮檺銆?, N'鍒涗綔鑰呭伐浣滃彴銆佺増鏈鐞嗐€佹敹鐩婂垎鎴愬垎鏋?, N'鍒涗綔鑰呬笓浜?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.IdentityOptions)
BEGIN
    INSERT INTO dbo.IdentityOptions(Name, Description, AbilityFocus, RecommendedFor, SortOrder)
    VALUES
    (N'鎺ㄧ悊渚︽帰', N'鎿呴暱淇℃伅鏁村悎涓庣煕鐩炬媶瑙ｏ紝閫傚悎鏈牸鍜岀‖鏍哥帺瀹躲€?, N'鎺ㄧ悊銆佽瀵熴€佹椂闂寸嚎澶嶇洏', N'鍠滄鐩橀€昏緫鐨勭帺瀹?, 1),
    (N'鎴忕簿瑙掕壊', N'鎿呴暱鎯呯华甯﹀姩鍜岃鑹叉矇娴革紝閫傚悎鎯呮劅鏈拰婕旂粠鏈€?, N'娌夋蹈銆佽〃杈俱€佽鑹插叧绯?, N'鍠滄浠ｅ叆鍜屾紨缁庣殑鐜╁', 2),
    (N'鎺у満涓绘寔', N'閫傚悎鎵挎媴缁勭粐涓庢矡閫氫换鍔★紝淇濊瘉澶氫汉鍗忎綔浣撻獙銆?, N'鍗忎綔銆佹墽琛屻€佹帶鑺傚', N'鍠滄甯﹂槦鍜岀粍缁囩殑鐜╁', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.PlayerProfiles)
BEGIN
    INSERT INTO dbo.PlayerProfiles(UserId, DisplayName, DisplayTitle, Motto, AvatarUrl, FavoriteGenre, JoinDays, CompletedScripts, WinRate, ReputationLevel)
    SELECT Id, N'绯荤粺绠＄悊鍛?, N'闆惧煄棣栧腑瑙傚療鍛?, N'鎵€鏈夊姩鎬佸唴瀹归兘搴旇鏉ヨ嚜鏁版嵁搴擄紝鑰屼笉鏄啓姝诲湪椤甸潰閲屻€?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80', N'鏈牸鎺ㄧ悊', 365, 48, 92.50, N'SS 绾ф帹鐞嗚€?
    FROM dbo.Users
    WHERE Username = N'admin';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.PlayerAbilities)
BEGIN
    INSERT INTO dbo.PlayerAbilities(UserId, DeductionPower, ObservationPower, CreativityPower, CollaborationPower, ExecutionPower)
    SELECT Id, 92, 88, 76, 84, 90
    FROM dbo.Users
    WHERE Username = N'admin';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Achievements)
BEGIN
    INSERT INTO dbo.Achievements(UserId, Title, Description, RarityTag, ProgressValue, ProgressTotal, EarnedAt, SortOrder)
    SELECT Id, N'鐪熺浉杩樺師鑰?, N'绱瀹屾垚 30 鍦哄畬鏁存帹鐞嗗苟淇濇寔楂樿瘎鍒嗐€?, N'浼犺', 30, 30, DATEADD(DAY, -30, GETDATE()), 1 FROM dbo.Users WHERE Username = N'admin'
    UNION ALL
    SELECT Id, N'绾跨储鐚庝汉', N'绱瑙﹀彂 120 鏉＄嚎绱㈣В閿佷簨浠躲€?, N'鍙茶瘲', 120, 120, DATEADD(DAY, -12, GETDATE()), 2 FROM dbo.Users WHERE Username = N'admin'
    UNION ALL
    SELECT Id, N'娌夋蹈琛ㄦ紨瀹?, N'鍦ㄦ儏鎰熸湰涓幏寰?10 娆￠珮娌夋蹈璇勪环銆?, N'绋€鏈?, 8, 10, NULL, 3 FROM dbo.Users WHERE Username = N'admin';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.AnalyticsSnapshots)
BEGIN
    INSERT INTO dbo.AnalyticsSnapshots(SnapshotDate, ActiveUsers, AverageSessionMinutes, TotalBookings, RevenueAmount, ConversionRate)
    VALUES(DATEADD(HOUR, -2, GETDATE()), 268, 142.50, 86, 16880.00, 37.40);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.HeatmapZones)
BEGIN
    INSERT INTO dbo.HeatmapZones(ZoneName, HeatLevel, PeakPeriod, Summary, SortOrder)
    VALUES
    (N'绾跨储鏉垮尯鍩?, 95, N'19:30 - 21:00', N'鐜╁鍋滅暀鏃堕棿鏈€闀匡紝璇存槑绾跨储鏉挎槸鏍稿績浜掑姩鍖哄煙銆?, 1),
    (N'瑙掕壊鍗″尯鍩?, 84, N'寮€鍦哄墠 10 鍒嗛挓', N'杩涘叆鎴块棿鍚庣殑棣栨鏌ョ湅闆嗕腑鍦ㄨ鑹插崱涓庝汉鐗╁叧绯昏鏄庛€?, 2),
    (N'璇煶鑱婂ぉ鍖哄煙', 72, N'鎺ㄧ悊闃舵', N'闆嗕腑鎺ㄧ悊鏃朵簰鍔ㄩ鐜囨樉钁楁彁鍗囥€?, 3),
    (N'棰勭害椤甸潰', 66, N'17:00 - 19:00', N'鏅氶棿杞寲鐜囪緝楂橈紝閫傚悎鎶曟斁棣栭〉鎺ㄨ崘浣嶃€?, 4);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.CompletionInsights)
BEGIN
    INSERT INTO dbo.CompletionInsights(MetricType, Name, ValueDecimal, Summary, SortOrder)
    VALUES
    (N'鍓ф湰瀹屾垚鐜?, N'闀垮畨澶滃', 91.50, N'闃佃惀鏈腑鐨勫畬鎴愮巼琛ㄧ幇绋冲畾锛岄€傚悎鎺ㄨ崘缁欑啛浜鸿溅闃熴€?, 1),
    (N'鍓ф湰瀹屾垚鐜?, N'鐧藉绮剧鐥呴櫌', 86.20, N'楂樺帇鏈€€鍑虹巼鐣ラ珮锛屼絾鍙ｇ鍙嶉闈炲父闆嗕腑銆?, 2),
    (N'璋滈閫氳繃鐜?, N'鍙ゅ牎瀵嗛棬鏈哄叧', 78.00, N'鏈哄叧鍨嬭皽棰橀€氳繃鐜囬€備腑锛岃兘浣撶幇鍔ㄦ€侀毦搴﹁皟鑺備环鍊笺€?, 3),
    (N'璋滈閫氳繃鐜?, N'璁板繂纰庣墖鎷兼帴', 64.50, N'閫傚悎浣滀负 AI 璋滈鍔╂墜鎺ㄨ崘浼樺寲瀵硅薄銆?, 4);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.EconomyInsights)
BEGIN
    INSERT INTO dbo.EconomyInsights(CategoryName, MetricName, MetricValue, TrendText, SortOrder)
    VALUES
    (N'铏氭嫙缁忔祹', N'鏈湀閬撳叿浜ゆ槗棰?, 6280.00, N'杈冧笂鍛ㄥ闀?12.4%', 1),
    (N'鍒涗綔鑰呮敹鐩?, N'鍓ф湰鍒嗘垚姹?, 11860.00, N'鎯呮劅鏈姇绋挎敹鐩婁笂鍗囨槑鏄?, 2),
    (N'浼氬憳璁㈤槄', N'娲昏穬璁㈤槄閲戦', 3980.00, N'閾跺崱杞噾鍗℃瘮鐜囨彁鍗?, 3),
    (N'瑙傛垬鏀跺叆', N'浜掑姩绀肩墿鏀跺叆', 1260.00, N'鐩存挱瑙傛垬闂寸儹搴︽媺鍔ㄦ槑鏄?, 4);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SpectatorModes)
BEGIN
    INSERT INTO dbo.SpectatorModes(Name, Description, SceneText, SortOrder)
    VALUES
    (N'鍏ㄦ櫙瑙傛垬', N'閫傚悎鏌ョ湅鎴块棿鏁翠綋鎺ㄨ繘涓?DM 鑺傚鎺у埗銆?, N'鏌ョ湅鍏ㄦ埧鐘舵€佷笌涓绘祦绋?, 1),
    (N'瑙掕壊璺熸媿', N'鑱氱劍鍗曚釜鐜╁鐨勭嚎绱㈣幏寰楀拰鎺ㄧ悊杩囩▼銆?, N'閫傚悎澶嶇洏鍏抽敭瑙掕壊璺嚎', 2),
    (N'寮瑰箷浜掑姩', N'瑙備紬鍙互鍙戦€佽交閲忚瘎璁轰笌姘涘洿浜掑姩銆?, N'澧炲己鐩存挱涓庡洿瑙傚弬涓庢劅', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SpectatorRooms)
BEGIN
    INSERT INTO dbo.SpectatorRooms(Title, ScriptName, HostName, ViewerCount, HeatScore, CoverImage, RoomStatus, RouteCode, SortOrder)
    VALUES
    (N'闀垮畨澶滃瀹炴椂瑙傛垬闂?, N'闀垮畨澶滃', N'MC 瀛愯】', 326, 95, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鐩存挱涓?, N'WATCH-1001', 1),
    (N'鐧藉绮剧鐥呴櫌鎯婃倸澶?, N'鐧藉绮剧鐥呴櫌', N'MC 鏈ㄧ櫧', 281, 88, N'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=1200&q=80', N'鐩存挱涓?, N'WATCH-1002', 2),
    (N'鏄熸捣鍥炲搷鏈哄埗灞曠ず鍦?, N'鏄熸捣鍥炲搷', N'MC 娲涘窛', 198, 79, N'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?auto=format&fit=crop&w=1200&q=80', N'棰勭害寮€鏀?, N'WATCH-1003', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SpectatorMessages)
BEGIN
    INSERT INTO dbo.SpectatorMessages(SpectatorRoomId, SenderName, Content, BadgeText, SentAt)
    VALUES
    (1, N'瑙備紬闃挎緶', N'杩欎竴杞弽杞ソ婕備寒锛岀嚎绱㈠洖鏀跺緱寰堝畬鏁淬€?, N'楂樿兘', DATEADD(MINUTE, -18, GETDATE())),
    (1, N'璋滈鐮旂┒鍛?, N'DM 杩欓噷鐨勮妭濂忔帶鍒跺緢閫傚悎鍐欒繘绛旇京灞曠ず銆?, N'鍒嗘瀽', DATEADD(MINUTE, -12, GETDATE())),
    (2, N'鎯婃倸鐖卞ソ鑰?, N'鐧藉鐨勬皼鍥寸伅鍜岃闊宠仈鍔ㄥお鏈夊帇杩劅浜嗐€?, N'姘涘洿', DATEADD(MINUTE, -10, GETDATE())),
    (3, N'鏈哄埗鎺х帺瀹?, N'杩欎釜绌洪棿绔欐湰寰堥€傚悎灞曠ず澶氶樁娈垫祦绋嬮〉闈€?, N'鎺ㄨ崘', DATEADD(MINUTE, -8, GETDATE()));
END
GO

IF OBJECT_ID(N'dbo.SiteSettings', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SiteSettings
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        SiteName NVARCHAR(100) NOT NULL,
        HeroTitle NVARCHAR(150) NOT NULL,
        HeroSubtitle NVARCHAR(200) NOT NULL,
        WelcomeText NVARCHAR(500) NOT NULL,
        AboutTitle NVARCHAR(120) NOT NULL,
        AboutContent NVARCHAR(MAX) NOT NULL,
        Address NVARCHAR(200) NOT NULL,
        BusinessHours NVARCHAR(100) NOT NULL,
        ContactPhone NVARCHAR(30) NOT NULL,
        ContactWeChat NVARCHAR(50) NOT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Users
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Username NVARCHAR(50) NOT NULL,
        PasswordHash NVARCHAR(64) NOT NULL,
        DisplayName NVARCHAR(50) NOT NULL,
        Email NVARCHAR(100) NOT NULL,
        Phone NVARCHAR(30) NOT NULL,
        RoleCode NVARCHAR(20) NOT NULL,
        ReviewStatus NVARCHAR(20) NOT NULL,
        ReviewRemark NVARCHAR(200) NULL,
        Balance DECIMAL(10,2) NOT NULL CONSTRAINT DF_Users_Balance DEFAULT(0),
        CreatedAt DATETIME NOT NULL,
        ReviewedAt DATETIME NULL
    );
END
GO

IF COL_LENGTH(N'dbo.Users', N'Balance') IS NULL
BEGIN
    ALTER TABLE dbo.Users ADD Balance DECIMAL(10,2) NOT NULL CONSTRAINT DF_Users_Balance_Legacy DEFAULT(0);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Users_Username' AND object_id = OBJECT_ID(N'dbo.Users'))
BEGIN
    CREATE UNIQUE INDEX UX_Users_Username ON dbo.Users(Username);
END
GO

IF OBJECT_ID(N'dbo.Announcements', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Announcements
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Title NVARCHAR(120) NOT NULL,
        Summary NVARCHAR(300) NOT NULL,
        PublishDate DATE NOT NULL,
        IsImportant BIT NOT NULL DEFAULT(0)
    );
END
GO

IF OBJECT_ID(N'dbo.WalletTransactions', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.WalletTransactions
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        UserId INT NOT NULL,
        TransactionType NVARCHAR(30) NOT NULL,
        Amount DECIMAL(10,2) NOT NULL,
        BalanceAfter DECIMAL(10,2) NOT NULL,
        Summary NVARCHAR(200) NOT NULL,
        CreatedAt DATETIME NOT NULL,
        CONSTRAINT FK_WalletTransactions_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id)
    );
END
GO

IF OBJECT_ID(N'dbo.RechargeRequests', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.RechargeRequests
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        UserId INT NOT NULL,
        PaymentMethod NVARCHAR(20) NOT NULL,
        Amount DECIMAL(10,2) NOT NULL,
        PaymentAccount NVARCHAR(80) NULL,
        RequestStatus NVARCHAR(20) NOT NULL,
        ReviewRemark NVARCHAR(200) NULL,
        WalletTransactionId INT NULL,
        SubmittedAt DATETIME NOT NULL,
        ReviewedAt DATETIME NULL,
        ReviewedByUserId INT NULL,
        CONSTRAINT FK_RechargeRequests_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id)
    );
END
GO

IF COL_LENGTH(N'dbo.RechargeRequests', N'WalletTransactionId') IS NULL
BEGIN
    ALTER TABLE dbo.RechargeRequests ADD WalletTransactionId INT NULL;
END
GO

IF COL_LENGTH(N'dbo.RechargeRequests', N'ReviewedByUserId') IS NULL
BEGIN
    ALTER TABLE dbo.RechargeRequests ADD ReviewedByUserId INT NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_RechargeRequests_WalletTransactions')
BEGIN
    ALTER TABLE dbo.RechargeRequests
    ADD CONSTRAINT FK_RechargeRequests_WalletTransactions FOREIGN KEY (WalletTransactionId) REFERENCES dbo.WalletTransactions(Id);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_RechargeRequests_ReviewedByUsers')
BEGIN
    ALTER TABLE dbo.RechargeRequests
    ADD CONSTRAINT FK_RechargeRequests_ReviewedByUsers FOREIGN KEY (ReviewedByUserId) REFERENCES dbo.Users(Id);
END
GO

IF OBJECT_ID(N'dbo.Scripts', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Scripts
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        GenreId INT NOT NULL,
        Name NVARCHAR(80) NOT NULL,
        Slogan NVARCHAR(180) NOT NULL,
        StoryBackground NVARCHAR(MAX) NOT NULL,
        CoverImage NVARCHAR(300) NOT NULL,
        DurationMinutes INT NOT NULL,
        PlayerMin INT NOT NULL,
        PlayerMax INT NOT NULL,
        Difficulty NVARCHAR(30) NOT NULL,
        Price DECIMAL(10,2) NOT NULL,
        IsFeatured BIT NOT NULL DEFAULT(0),
        Status NVARCHAR(30) NOT NULL,
        AuthorName NVARCHAR(50) NOT NULL,
        CONSTRAINT FK_Scripts_Genres FOREIGN KEY (GenreId) REFERENCES dbo.Genres(Id)
    );
END
GO

IF COL_LENGTH(N'dbo.Scripts', N'CreatorUserId') IS NULL
BEGIN
    ALTER TABLE dbo.Scripts ADD CreatorUserId INT NULL;
END
GO

IF COL_LENGTH(N'dbo.Scripts', N'AuditStatus') IS NULL
BEGIN
    ALTER TABLE dbo.Scripts ADD AuditStatus NVARCHAR(20) NOT NULL CONSTRAINT DF_Scripts_AuditStatus DEFAULT(N'Approved');
END
GO

IF COL_LENGTH(N'dbo.Scripts', N'AuditComment') IS NULL
BEGIN
    ALTER TABLE dbo.Scripts ADD AuditComment NVARCHAR(300) NULL;
END
GO

IF COL_LENGTH(N'dbo.Scripts', N'SubmittedAt') IS NULL
BEGIN
    ALTER TABLE dbo.Scripts ADD SubmittedAt DATETIME NULL;
END
GO

IF COL_LENGTH(N'dbo.Scripts', N'ReviewedAt') IS NULL
BEGIN
    ALTER TABLE dbo.Scripts ADD ReviewedAt DATETIME NULL;
END
GO

IF COL_LENGTH(N'dbo.Scripts', N'FullScriptContent') IS NULL
BEGIN
    ALTER TABLE dbo.Scripts ADD FullScriptContent NVARCHAR(MAX) NULL;
END
GO

IF COL_LENGTH(N'dbo.Scripts', N'KillerCharacterName') IS NULL
BEGIN
    ALTER TABLE dbo.Scripts ADD KillerCharacterName NVARCHAR(50) NULL;
END
GO

IF COL_LENGTH(N'dbo.Scripts', N'TruthSummary') IS NULL
BEGIN
    ALTER TABLE dbo.Scripts ADD TruthSummary NVARCHAR(MAX) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Scripts_Users')
BEGIN
    ALTER TABLE dbo.Scripts
    ADD CONSTRAINT FK_Scripts_Users FOREIGN KEY (CreatorUserId) REFERENCES dbo.Users(Id);
END
GO

IF OBJECT_ID(N'dbo.ScriptCharacters', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ScriptCharacters
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ScriptId INT NOT NULL,
        Name NVARCHAR(50) NOT NULL,
        Gender NVARCHAR(20) NOT NULL,
        AgeRange NVARCHAR(20) NOT NULL,
        Profession NVARCHAR(50) NOT NULL,
        Personality NVARCHAR(100) NOT NULL,
        SecretLine NVARCHAR(100) NOT NULL,
        Description NVARCHAR(300) NOT NULL,
        CONSTRAINT FK_ScriptCharacters_Scripts FOREIGN KEY (ScriptId) REFERENCES dbo.Scripts(Id)
    );
END
GO

IF OBJECT_ID(N'dbo.Rooms', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Rooms
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Name NVARCHAR(80) NOT NULL,
        Theme NVARCHAR(60) NOT NULL,
        Capacity INT NOT NULL,
        Description NVARCHAR(300) NOT NULL,
        ImageUrl NVARCHAR(300) NOT NULL,
        Status NVARCHAR(30) NOT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.Sessions', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Sessions
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ScriptId INT NOT NULL,
        RoomId INT NOT NULL,
        SessionDateTime DATETIME NOT NULL,
        HostName NVARCHAR(50) NOT NULL,
        BasePrice DECIMAL(10,2) NOT NULL,
        MaxPlayers INT NOT NULL,
        Status NVARCHAR(30) NOT NULL,
        CONSTRAINT FK_Sessions_Scripts FOREIGN KEY (ScriptId) REFERENCES dbo.Scripts(Id),
        CONSTRAINT FK_Sessions_Rooms FOREIGN KEY (RoomId) REFERENCES dbo.Rooms(Id)
    );
END
GO

IF OBJECT_ID(N'dbo.Reservations', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Reservations
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        SessionId INT NOT NULL,
        UserId INT NULL,
        ContactName NVARCHAR(50) NOT NULL,
        Phone NVARCHAR(30) NOT NULL,
        PlayerCount INT NOT NULL,
        UnitPrice DECIMAL(10,2) NULL,
        TotalAmount DECIMAL(10,2) NULL,
        PaymentStatus NVARCHAR(30) NOT NULL CONSTRAINT DF_Reservations_PaymentStatus DEFAULT(N'绾夸笅纭'),
        PaymentTransactionId INT NULL,
        Remark NVARCHAR(400) NULL,
        CreatedAt DATETIME NOT NULL,
        Status NVARCHAR(30) NOT NULL,
        CONSTRAINT FK_Reservations_Sessions FOREIGN KEY (SessionId) REFERENCES dbo.Sessions(Id)
    );
END
GO

IF COL_LENGTH(N'dbo.Reservations', N'UserId') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations ADD UserId INT NULL;
END
GO

IF COL_LENGTH(N'dbo.Reservations', N'UnitPrice') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations ADD UnitPrice DECIMAL(10,2) NULL;
END
GO

IF COL_LENGTH(N'dbo.Reservations', N'TotalAmount') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations ADD TotalAmount DECIMAL(10,2) NULL;
END
GO

IF COL_LENGTH(N'dbo.Reservations', N'PaymentStatus') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations ADD PaymentStatus NVARCHAR(30) NOT NULL CONSTRAINT DF_Reservations_PaymentStatus_Legacy DEFAULT(N'绾夸笅纭');
END
GO

IF COL_LENGTH(N'dbo.Reservations', N'PaymentTransactionId') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations ADD PaymentTransactionId INT NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Reservations_Users')
BEGIN
    ALTER TABLE dbo.Reservations
    ADD CONSTRAINT FK_Reservations_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Reservations_WalletTransactions')
BEGIN
    ALTER TABLE dbo.Reservations
    ADD CONSTRAINT FK_Reservations_WalletTransactions FOREIGN KEY (PaymentTransactionId) REFERENCES dbo.WalletTransactions(Id);
END
GO

IF OBJECT_ID(N'dbo.ReservationWaitlists', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ReservationWaitlists
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        SessionId INT NOT NULL,
        UserId INT NOT NULL,
        ContactName NVARCHAR(50) NOT NULL,
        Phone NVARCHAR(30) NOT NULL,
        PlayerCount INT NOT NULL,
        Note NVARCHAR(300) NULL,
        Status NVARCHAR(20) NOT NULL CONSTRAINT DF_ReservationWaitlists_Status DEFAULT(N'Pending'),
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_ReservationWaitlists_CreatedAt DEFAULT(GETDATE()),
        CONSTRAINT FK_ReservationWaitlists_Sessions FOREIGN KEY (SessionId) REFERENCES dbo.Sessions(Id),
        CONSTRAINT FK_ReservationWaitlists_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ReservationWaitlists_UserStatus' AND object_id = OBJECT_ID(N'dbo.ReservationWaitlists'))
BEGIN
    CREATE INDEX IX_ReservationWaitlists_UserStatus ON dbo.ReservationWaitlists(UserId, Status, CreatedAt DESC);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ReservationWaitlists_SessionStatus' AND object_id = OBJECT_ID(N'dbo.ReservationWaitlists'))
BEGIN
    CREATE INDEX IX_ReservationWaitlists_SessionStatus ON dbo.ReservationWaitlists(SessionId, Status, CreatedAt DESC);
END
GO

IF OBJECT_ID(N'dbo.Reviews', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Reviews
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ScriptId INT NOT NULL,
        ReviewerName NVARCHAR(50) NOT NULL,
        Rating INT NOT NULL,
        Content NVARCHAR(500) NOT NULL,
        ReviewDate DATETIME NOT NULL,
        HighlightTag NVARCHAR(50) NOT NULL,
        CONSTRAINT FK_Reviews_Scripts FOREIGN KEY (ScriptId) REFERENCES dbo.Scripts(Id)
    );
END
GO

IF OBJECT_ID(N'dbo.RoomMessages', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.RoomMessages
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        SessionId INT NOT NULL,
        ReservationId INT NOT NULL,
        UserId INT NULL,
        SenderName NVARCHAR(50) NOT NULL,
        MessageType NVARCHAR(20) NOT NULL,
        Content NVARCHAR(MAX) NULL,
        MediaData NVARCHAR(MAX) NULL,
        DurationSeconds INT NULL,
        SentAt DATETIME NOT NULL,
        CONSTRAINT FK_RoomMessages_Sessions FOREIGN KEY (SessionId) REFERENCES dbo.Sessions(Id),
        CONSTRAINT FK_RoomMessages_Reservations FOREIGN KEY (ReservationId) REFERENCES dbo.Reservations(Id),
        CONSTRAINT FK_RoomMessages_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id)
    );
END
GO

IF OBJECT_ID(N'dbo.RoomPresence', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.RoomPresence
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        SessionId INT NOT NULL,
        ReservationId INT NOT NULL,
        UserId INT NULL,
        DisplayName NVARCHAR(50) NOT NULL,
        CameraEnabled BIT NOT NULL CONSTRAINT DF_RoomPresence_CameraEnabled DEFAULT(0),
        MicrophoneEnabled BIT NOT NULL CONSTRAINT DF_RoomPresence_MicrophoneEnabled DEFAULT(0),
        VideoSnapshot NVARCHAR(MAX) NULL,
        UpdatedAt DATETIME NOT NULL,
        CONSTRAINT FK_RoomPresence_Sessions FOREIGN KEY (SessionId) REFERENCES dbo.Sessions(Id),
        CONSTRAINT FK_RoomPresence_Reservations FOREIGN KEY (ReservationId) REFERENCES dbo.Reservations(Id),
        CONSTRAINT FK_RoomPresence_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_RoomPresence_ReservationId' AND object_id = OBJECT_ID(N'dbo.RoomPresence'))
BEGIN
    CREATE UNIQUE INDEX UX_RoomPresence_ReservationId ON dbo.RoomPresence(ReservationId);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Genres)
BEGIN
    INSERT INTO dbo.Genres(Name, Description)
    VALUES
    (N'鏈牸鎺ㄧ悊', N'绾跨储娓呮櫚銆佸姩鏈洪棴鐜紝閫傚悎鍠滄杩樺師鐪熺浉鐨勭帺瀹躲€?),
    (N'鎯呮劅娌夋蹈', N'瑙掕壊鍏崇郴娴撳害楂橈紝閲嶈婕旂粠涓庝唬鍏ャ€?),
    (N'鎭愭€栨儕鎮?, N'姘涘洿鍘嬭揩鎰熷己锛岄€傚悎杩芥眰鍒烘縺浣撻獙鐨勫皬闃熴€?),
    (N'鍙ら闃佃惀', N'鏉冭皨涓庨殣钘忚韩浠戒氦缁囷紝閫傚悎绀句氦鍗氬紙銆?),
    (N'绉戝够鏈哄埗', N'涓栫晫瑙傛柊棰栵紝鏈哄埗浠诲姟鍜屽绾垮彊浜嬪苟閲嶃€?);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SiteSettings)
BEGIN
    INSERT INTO dbo.SiteSettings
    (
        SiteName, HeroTitle, HeroSubtitle, WelcomeText, AboutTitle, AboutContent, Address, BusinessHours, ContactPhone, ContactWeChat
    )
    VALUES
    (
        N'闆惧煄鍓ф湰鐮旂┒鎵€',
        N'闆惧煄鍓ф湰鏉€闂ㄥ簵杩愯惀绯荤粺',
        N'闆嗗墽鏈睍绀恒€佽鑹叉煡璇€佸湪绾块绾︿笌鍒涗綔鍙戝竷浜庝竴浣撶殑娌夋蹈寮忓墽鏈潃骞冲彴銆?,
        N'鏈珯灞曠ず鐨勫墽鏈€佽鑹层€佹埧闂淬€佸満娆°€佺偣璇勪笌棰勭害璁板綍鍏ㄩ儴鐢辨暟鎹簱椹卞姩锛屽府鍔╃帺瀹跺揩閫熶簡瑙ｉ棬搴楀唴瀹瑰苟瀹屾垚閫夋湰缁勫眬銆?,
        N'涓轰粈涔堢帺瀹跺枩娆㈣繖閲?,
        N'绯荤粺鍥寸粫鐪熷疄鍓ф湰鏉€闂ㄥ簵涓氬姟璁捐锛岃鐩栧墽鏈睍绀恒€佽鑹叉祻瑙堛€佹埧闂寸鐞嗐€佸満娆￠绾︺€佸垱浣滆€呮姇绋垮拰鐜╁鍙ｇ鍏釜妯″潡銆傞〉闈㈠唴瀹瑰叏閮ㄨ鍙栨暟鎹簱锛岃兘澶熸寔缁敮鎾戦棬搴楄繍钀ャ€佸唴瀹逛笂鏂颁笌瀹℃牳绠＄悊銆?,
        N'姹熻嫃鐪佽嫃宸炲競宸ヤ笟鍥尯鏄熷箷璺?18 鍙?,
        N'鍛ㄤ竴鑷冲懆鏃?10:00 - 23:30',
        N'400-0512-1314',
        N'MistLab1314'
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username = N'admin')
BEGIN
    INSERT INTO dbo.Users
    (
        Username,
        PasswordHash,
        DisplayName,
        Email,
        Phone,
        RoleCode,
        ReviewStatus,
        ReviewRemark,
        CreatedAt,
        ReviewedAt
    )
    VALUES
    (
        N'admin',
        N'ac0e7d037817094e9e0b4441f9bae3209d67b02fa484917065f71b16109a1a78',
        N'绯荤粺绠＄悊鍛?,
        N'admin@dramamurder.local',
        N'13800000000',
        N'Admin',
        N'Approved',
        N'绯荤粺榛樿绠＄悊鍛樿处鍙?,
        GETDATE(),
        GETDATE()
    );
END
GO

UPDATE dbo.Users
SET Balance = ISNULL(Balance, 0);
GO

IF EXISTS (SELECT 1 FROM dbo.Users WHERE Username = N'admin' AND Balance = 0)
   AND NOT EXISTS
   (
       SELECT 1
       FROM dbo.WalletTransactions wt
       INNER JOIN dbo.Users u ON u.Id = wt.UserId
       WHERE u.Username = N'admin'
         AND wt.TransactionType = N'绯荤粺璧犻€?
   )
BEGIN
    UPDATE dbo.Users SET Balance = 1000 WHERE Username = N'admin';

    INSERT INTO dbo.WalletTransactions(UserId, TransactionType, Amount, BalanceAfter, Summary, CreatedAt)
    SELECT Id, N'绯荤粺璧犻€?, 1000, 1000, N'绠＄悊鍛樻祴璇曡处鎴峰垵濮嬩綑棰?, GETDATE()
    FROM dbo.Users
    WHERE Username = N'admin';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Announcements)
BEGIN
    INSERT INTO dbo.Announcements(Title, Summary, PublishDate, IsImportant)
    VALUES
    (N'娓呮槑鍋囨湡鍦烘宸插紑鏀?, N'鐑棬鏈€婇暱瀹夊瀹淬€嬨€婄櫧濉旂簿绁炵梾闄€嬫柊澧炴櫄鍦猴紝璇峰敖鏃╅绾︺€?, '2026-04-01', 1),
    (N'鏂版墜鍙嬪ソ鎷艰溅涓撳尯涓婄嚎', N'姣忓懆涓夈€佸懆鍥涘紑鏀?4-6 浜鸿交鎺ㄧ悊鎷艰溅锛岃绗竴娆℃潵闂ㄥ簵鐨勭帺瀹舵洿瀹规槗缁勫眬銆?, '2026-03-28', 0),
    (N'鍒涗綔鑰呮姇绋块€氶亾寮€鏀?, N'璁よ瘉浣滆€呭彲鍦ㄥ垱浣滀腑蹇冩彁浜ゅ畬鏁村墽鏈笌瑙掕壊淇℃伅锛岀鐞嗗憳瀹℃牳鍚庡嵆鍙笂鏋跺埌鍓ф湰搴撱€?, '2026-03-18', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Scripts)
BEGIN
    INSERT INTO dbo.Scripts
    (
        GenreId, Name, Slogan, StoryBackground, CoverImage, DurationMinutes, PlayerMin, PlayerMax, Difficulty, Price, IsFeatured, Status, AuthorName, CreatorUserId, AuditStatus, AuditComment, SubmittedAt, ReviewedAt
    )
    VALUES
    (1, N'婕暱鐨勫憡鍒?, N'涓€灏佽繜鍒颁簡鍗佷簲骞寸殑閬椾功锛屾妸涓冧釜浜洪噸鏂版媺鍥炲懡妗堝綋澶溿€?, N'娴疯竟鐤楀吇闄㈡棫妗堥噸鍚皟鏌ワ紝鎵€鏈変汉閮戒互涓鸿嚜宸卞彧鏄湪琛ュ畬璁板繂锛岀洿鍒版湁浜哄彂鐜版瘡娈佃蹇嗛兘灏戜簡涓€鍒嗛挓銆傜帺瀹堕渶瑕佸湪澶氶噸涓嶅湪鍦鸿瘉鏄庝笌褰兼璇曟帰涓壘鍑虹湡姝ｇ殑鎿嶇洏鑰呫€?, N'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?auto=format&fit=crop&w=1200&q=80', 240, 6, 7, N'杩涢樁', 168.00, 1, N'寮€鏀鹃绾?, N'椤炬矇', NULL, N'Approved', N'鍒濆鏁版嵁', GETDATE(), GETDATE()),
    (2, N'灞辨渤鏃呴', N'鍦ㄦ毚闆ㄥ皝璺殑澶滈噷锛屾渶鎯崇寮€鐨勪汉鍙嶈€岀涓嶅紑銆?, N'涓冧綅浣忓琚洶鍦ㄥ北闂存梾棣嗭紝鏃呴鑰佹澘琚彂鐜版浜庡偍钘忓銆傞殢鐫€鍙戠數鏈轰竴娆℃璺抽椄锛屽ぇ瀹堕€愭笎鎰忚瘑鍒拌繖骞朵笉鏄竴鍦哄伓鐒惰仛浼氾紝鑰屾槸涓€鍦虹簿蹇冨竷缃殑蹇冪悊瀹″垽銆?, N'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80', 300, 6, 8, N'娌夋蹈', 198.00, 1, N'寮€鏀鹃绾?, N'鏅忓窛', NULL, N'Approved', N'鍒濆鏁版嵁', GETDATE(), GETDATE()),
    (3, N'闆鹃殣娓彛', N'姣忎竴鑹樻繁澶滈潬宀哥殑璐ц疆锛岄兘鍦ㄨ繍閫佷竴涓笉鑳借鍑哄彛鐨勭瀵嗐€?, N'浜屽崄涓栫邯鍒濈殑娓彛鍩庡競锛岀绉樿揣杞€佸け韪鍛樹笌榛戝府璐︽湰浜ょ粐鍦ㄤ竴璧枫€傜帺瀹跺皢閫氳繃鐮佸ご銆侀厭棣嗐€佹捣鍏充笁鏉＄嚎绱㈤摼鎷煎悎鍑烘斂娌昏皨鏉€鑳屽悗鐨勭湡姝ｅ彈鐩婅€呫€?, N'https://images.unsplash.com/photo-1473448912268-2022ce9509d8?auto=format&fit=crop&w=1200&q=80', 270, 6, 6, N'纭牳', 188.00, 0, N'寮€鏀鹃绾?, N'鏋楁硦', NULL, N'Approved', N'鍒濆鏁版嵁', GETDATE(), GETDATE()),
    (4, N'闀垮畨澶滃', N'涓€鍦哄簡鍔熷瀹村悗锛屾弧鍩庣伅鐏兘鎴愪簡鎺╅グ銆?, N'鐩涘攼骞撮棿锛屽嚡鏃嬩箣澶滅殑瀹鍙戠敓绂诲鍛芥銆傚皢鍐涖€佷箰甯堛€佸浣裤€佷緧濂冲拰閽﹀ぉ鐩戝悇鎬€蹇冧簨锛岀帺瀹惰鍦ㄨ韩浠界珛鍦轰笌瀹跺浗鎶夋嫨涔嬮棿瀹屾垚闃佃惀鍗忎綔涓庡鎶椼€?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', 300, 7, 8, N'杩涢樁', 208.00, 1, N'寮€鏀鹃绾?, N'娌堢煡鍗?, NULL, N'Approved', N'鍒濆鏁版嵁', GETDATE(), GETDATE()),
    (3, N'鐧藉绮剧鐥呴櫌', N'濡傛灉鍖荤敓寮€濮嬮噸澶嶇梾浜虹殑鍣╂ⅵ锛岃皝杩樺垎寰楁竻鐜板疄銆?, N'闂櫌澶氬勾鐨勭櫧濉旂簿绁炵梾闄㈤噸鍚闂磋瀵熷疄楠屻€傚叚鍚嶅彈璇曡€呭湪涓嶅悓鐥呮埧閱掓潵锛屾瘡涓汉閮藉甫鐫€琚鏀硅繃鐨勭梾鍘嗗拰涓嶅畬鏁寸殑鎯婃亹璁板繂銆傜伅鍏夈€佸綍闊冲拰闀滈潰鏈哄埗灏嗘寔缁镜铓€鐜╁鍒ゆ柇銆?, N'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=1200&q=80', 240, 5, 6, N'楂樺帇', 218.00, 1, N'寮€鏀鹃绾?, N'澶忓', NULL, N'Approved', N'鍒濆鏁版嵁', GETDATE(), GETDATE()),
    (5, N'鏄熸捣鍥炲搷', N'褰撹蹇嗚涓婁紶鑷宠建閬撶珯锛屼汉绫荤涓€娆″浼氬悜杩囧幓鐢宠鐪熺浉銆?, N'杩戞湭鏉ヨ建閬撶┖闂寸珯鏀跺埌鏉ヨ嚜涓夊勾鍓嶇殑寮傚父淇″彿锛屼竷鍚嶇爺绌跺憳闇€瑕侀€氳繃浠诲姟鏈哄埗澶嶅師浜嬫晠鐪熺浉銆傛瘡涓汉鎷ユ湁涓嶅悓鐨勬潈闄愬拰璁板繂纰庣墖锛岀湡鐩稿彲鑳芥潵鑷畻娉曪紝涔熷彲鑳芥潵鑷汉蹇冦€?, N'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?auto=format&fit=crop&w=1200&q=80', 270, 6, 7, N'鏈哄埗', 228.00, 0, N'寮€鏀鹃绾?, N'娲涘鸡', NULL, N'Approved', N'鍒濆鏁版嵁', GETDATE(), GETDATE());
END
GO

UPDATE dbo.Scripts
SET AuditStatus = ISNULL(NULLIF(AuditStatus, N''), N'Approved'),
    SubmittedAt = ISNULL(SubmittedAt, GETDATE()),
    ReviewedAt = CASE WHEN AuditStatus = N'Approved' AND ReviewedAt IS NULL THEN GETDATE() ELSE ReviewedAt END;
GO

UPDATE dbo.Scripts
SET KillerCharacterName = CASE Id
        WHEN 1 THEN N'椤惧康'
        WHEN 2 THEN N'璁哥闈?
        WHEN 3 THEN N'瑁存浮'
        WHEN 4 THEN N'鏌冲惈绔?
        WHEN 5 THEN N'椤炬厧'
        WHEN 6 THEN N'鍞愮牃鑸?
        WHEN 9 THEN N'璁搁潚绂?
        ELSE KillerCharacterName
    END,
    TruthSummary = CASE Id
        WHEN 1 THEN N'鐪熸鐨勬搷鐩樿€呭埄鐢ㄧ枟鍏婚櫌鐩戞帶缂哄け涓庤蹇嗗亸宸帺鐩栦簡鏃ф鐪熺浉锛岄【蹇靛€熷尶鍚嶅綍闊充笌閬椾功鏃堕棿宸攣瀹氫簡琚埢鎰忓垹闄ょ殑涓€鍒嗛挓銆?
        WHEN 2 THEN N'灞遍棿鏃呴骞堕潪鍗曠函鐨勬毚闆ㄥ瘑瀹わ紝璁哥闈掓彁鍓嶆帴瑙﹀案浣撳苟鍙備笌淇グ姝诲洜锛岀湡姝ｈ璁″缓绔嬪湪鍋滅數銆佸鐢ㄩ棬鍗″拰寤惰繜鎶ユ涔嬩笂銆?
        WHEN 3 THEN N'娓彛璋嬫潃鑳屽悗鏄啗闇€浜ゆ槗涓庢斂鍟嗗嬀杩烇紝瑁存浮涓€鐩存彙鏈夌湡瀹炴竻鍗曞苟璇曞浘閫氳繃鎹㈠矖鍜岄粦甯处鏈浆绉荤湡姝ｅ彈鐩婅€呫€?
        WHEN 4 THEN N'搴嗗姛澶滃鐨勫懡妗堟湰璐ㄦ槸鏉冨姏閲嶇粍锛屾煶鍚珷鍒╃敤涔愯氨鏆楀彿銆佹槦鐩樼己鍙ｄ笌澶栦娇瀵嗕俊锛屾妸绉佷汉鎭╂€ㄥ寘瑁呮垚瀹环娣蜂贡涓殑蹇呯劧姝讳骸銆?
        WHEN 5 THEN N'鐧藉绮剧鐥呴櫌鐨勬亹鎯у苟闈炴潵鑷够瑙夛紝鑰屾槸鏉ヨ嚜琚汉涓烘搷鎺х殑鍖荤枟瀹為獙銆傞【鎱庨€氳繃灏佸瓨瀹為獙銆佺┖鐧借嵂鍗曞拰闀滈潰缂栧彿鎺╃洊浜嗙湡姝ｆ鍥犮€?
        WHEN 6 THEN N'绌洪棿绔欎簨鏁呬笉鏄郴缁熷け鎺э紝鑰屾槸鏈変汉鏁呮剰璁╃郴缁熻儗閿呫€傚攼鐮氳垷鍊熷姪涓绘帶鏉冮檺涓庡紓甯告眰鏁戜俊鍙凤紝闅愯棌浜嗗洟闃熷喅绛栦腑鐨勮嚧鍛戒竴鐜€?
        WHEN 9 THEN N'椤捐繙灞辨浜庤闈掔棰勫厛甯冪疆鐨勬瘨鑼讹紝鎵€璋撳瘑瀹ゅ彧鏄鑰呬緷涔犳儻鐙嚜鍙嶉攣瑙傛櫙瀹ゅ舰鎴愮殑鍋囪薄銆傜湡姝ｉ渶瑕佽繕鍘熺殑鏄叓骞村墠璁告槑鍧犳捣鏃ф銆?
        ELSE TruthSummary
    END
WHERE Id IN (1, 2, 3, 4, 5, 6, 9)
  AND (KillerCharacterName IS NULL OR TruthSummary IS NULL OR KillerCharacterName = N'' OR TruthSummary = N'');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ScriptCharacters)
BEGIN
    INSERT INTO dbo.ScriptCharacters(ScriptId, Name, Gender, AgeRange, Profession, Personality, SecretLine, Description)
    VALUES
    (1, N'娌堢牃', N'鐢?, N'28', N'寰嬪笀', N'鍐烽潤鍏嬪埗', N'澶辨晥閬楀槺', N'鏇捐礋璐ｆ棫妗堥仐浜у垎閰嶏紝瀵规鍙戝綋鏅氱殑鐩戞帶缂哄け寮傚父鏁忔劅銆?),
    (1, N'椤惧康', N'濂?, N'26', N'璁拌€?, N'鏁忛攼鎵ф嫍', N'鍖垮悕褰曢煶', N'鍗佷簲骞村墠鏇惧湪鐤楀吇闄㈤檮杩戝け韪紝鎺屾彙涓€娈垫湭鍏紑閲囪銆?),
    (1, N'闄嗚繜', N'鐢?, N'31', N'澶栫鍖荤敓', N'鐞嗘€у瑷€', N'琚垹鐥呭巻', N'涓庢鑰呮湁涓€娈靛彧瀛樺湪浜庣梾鍘嗕腑鐨勮仈绯汇€?),
    (2, N'娓╅仴', N'濂?, N'24', N'閽㈢惔鏁欏笀', N'娓╂煍闅愬繊', N'鍋滅數鍓嶇殑鐞村０', N'濂硅寰楀懡妗堝彂鐢熷墠鍚浜嗗苟涓嶅瓨鍦ㄧ殑鏃嬪緥銆?),
    (2, N'瀛ｄ慨杩?, N'鐢?, N'33', N'鏃呴鑰佹澘', N'娌夌ǔ闃插', N'閽ュ寵灏戜簡涓€鎶?, N'浠栧０绉拌嚜宸辨帶鍒跺叏鏃呴锛屽嵈浠庝笉鎻愰偅闂村缁堜笂閿佺殑 204銆?),
    (2, N'璁哥闈?, N'濂?, N'29', N'娉曞尰', N'鍐烽潤鏋滄柇', N'浼€犳鍥?, N'鐪嬩技涓撲笟涓珛锛屽疄鍒欐瘮鎵€鏈変汉閮芥洿鏃╃湅杩囧案浣撱€?),
    (3, N'瑁存浮', N'鐢?, N'35', N'娴峰叧绋芥煡', N'绮炬槑鑰佺粌', N'娑堝け鐨勬竻鍗?, N'浠栨墜閲屾彙鐫€璐ц疆鐨勭湡瀹炶浇璐у崟锛屽嵈杩熻繜涓嶈偗浜ゅ嚭銆?),
    (3, N'鑻忔緶', N'濂?, N'27', N'鎶ラ缂栬緫', N'澶栨煍鍐呭垰', N'鐓х墖搴曠墖', N'鎷嶄笅杩囨鍙戠爜澶寸殑閲嶈韬奖锛屽嵈琚揩闅愮瀿銆?),
    (3, N'闇嶄复', N'鐢?, N'30', N'鐮佸ご宸ュご', N'璁蹭箟姘?, N'澶滃崐鎹㈠矖', N'鐭ラ亾閭ｈ墭鑸逛綍鏃堕潬宀革紝涔熺煡閬撹皝涓嶈鍑虹幇鍦ㄧ爜澶淬€?),
    (4, N'璋㈡竻鏃?, N'鐢?, N'32', N'鍑棆灏嗗啗', N'鍌茶€屽厠鍒?, N'鍏电鍘诲悜', N'琛ㄩ潰椋庡厜鏃犻檺锛屽疄鍒欑珯鍦ㄤ竴鍦烘洿澶х殑鏀挎不婕╂丁涓績銆?),
    (4, N'椤炬櫄璇?, N'濂?, N'23', N'瀹环涔愬笀', N'鑱収鏁忔劅', N'閿欐媿涓夊０', N'鍛芥鍓嶅瀹存洸璋辫浜烘敼鍔紝鍙湁濂瑰惉鍑轰簡寮傛牱銆?),
    (4, N'鏌冲惈绔?, N'鐢?, N'29', N'閽﹀ぉ鐩戜富绨?, N'璋ㄦ厧鍦嗚瀺', N'鏄熺洏缂哄彛', N'浠栧彂鐜颁簡鏈変汉鍒╃敤澶╄薄涔嬪悕鎺╃洊鍒烘潃鏃舵満銆?),
    (5, N'闄堝簭', N'鐢?, N'27', N'蹇冪悊鍖荤敓', N'骞抽潤鍘嬫姂', N'閲嶅姊﹀', N'姊﹂噷鎬昏兘棰勮鐥呬汉鐨勬亹鎯э紝鍗存棤娉曡В閲婅嚜宸变负浣曞悓姝ュ仛姊︺€?),
    (5, N'鏋楄敁', N'濂?, N'25', N'鎶ゅ＋闀?, N'寮哄娍璐熻矗', N'绌虹櫧鑽崟', N'濂圭煡閬撳摢涓€闂寸梾鎴挎渶鍗遍櫓锛屼篃鐭ラ亾璋佹浘缁忎笉璇ヨ鏀舵不銆?),
    (5, N'椤炬厧', N'鐢?, N'34', N'闄㈤暱鍔╃悊', N'闃撮儊瀹℃厧', N'灏佸瓨瀹為獙', N'闂櫌鐪熺浉涓庝粬淇濈鐨勬棫妗ｆ绱у瘑鐩歌繛銆?),
    (6, N'鍞愮牃鑸?, N'鐢?, N'29', N'绯荤粺宸ョ▼甯?, N'鐞嗘櫤楂樻晥', N'涓绘帶鏉冮檺', N'鎷ユ湁杞ㄩ亾绔欐渶楂樼骇鍒潈闄愶紝鍗翠篃鍥犳鎴愪负鏈€澶у珜鐤戜汉銆?),
    (6, N'鍛ㄦ槧', N'濂?, N'28', N'璁板繂鐮旂┒鍛?, N'娓╁拰鍧氬畾', N'璁板繂澶囦唤', N'濂规帉鎻′簡涓夊勾鍓嶄簨鏁呭墠鏈€鍚庝竴娆″浠界殑鍏ュ彛銆?),
    (6, N'浣曠尽', N'鐢?, N'31', N'鑸ぉ蹇冪悊瀹?, N'鍠勪簬瑙傚療', N'鎯呯华鏃ュ織', N'浠栨瘮浠讳綍浜洪兘娓呮鍥㈤槦宕╂簝濮嬩簬鍝竴娆′簤鎵с€?);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms)
BEGIN
    INSERT INTO dbo.Rooms(Name, Theme, Capacity, Description, ImageUrl, Status)
    VALUES
    (N'闆炬腐 A 鍘?, N'鐢靛奖绾ф矇娴?, 8, N'閫傚悎鏈牸涓庢儏鎰熸湰锛屾敮鎸佺幆缁曞０銆佹姇褰变笌绾跨储澧欒仈鍔ㄣ€?, N'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=1200&q=80', N'鍚敤涓?),
    (N'闀垮 B 鍘?, N'鍙ら鏈哄叧', 8, N'鍙ら涓撶敤鍦烘櫙鍘咃紝鏀寔鐏厜鍒囨崲銆佹殫闂ㄤ笌鏈哄叧闊虫晥銆?, N'https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=1200&q=80', N'鍚敤涓?),
    (N'鐧藉 C 鍘?, N'鎯婃倸娌夋蹈', 6, N'鐢ㄤ簬鎭愭€栨儕鎮氭湰锛屾嫢鏈夊鍖哄煙澹板満鍜屽畾鍚戠伅鏁堛€?, N'https://images.unsplash.com/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=1200&q=80', N'鍚敤涓?);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Sessions)
BEGIN
    INSERT INTO dbo.Sessions(ScriptId, RoomId, SessionDateTime, HostName, BasePrice, MaxPlayers, Status)
    VALUES
    (1, 1, DATEADD(HOUR, 6, GETDATE()), N'MC 闃胯景', 168.00, 7, N'寮€鏀鹃绾?),
    (2, 1, DATEADD(DAY, 1, DATEADD(HOUR, 11, GETDATE())), N'MC 闃跨懚', 198.00, 8, N'寮€鏀鹃绾?),
    (4, 2, DATEADD(DAY, 1, DATEADD(HOUR, 16, GETDATE())), N'MC 瀛愯】', 208.00, 8, N'寮€鏀鹃绾?),
    (5, 3, DATEADD(DAY, 2, DATEADD(HOUR, 18, GETDATE())), N'MC 鏈ㄧ櫧', 218.00, 6, N'寮€鏀鹃绾?),
    (3, 1, DATEADD(DAY, 2, DATEADD(HOUR, 13, GETDATE())), N'MC 鑰佸懆', 188.00, 6, N'寮€鏀鹃绾?),
    (6, 2, DATEADD(DAY, 3, DATEADD(HOUR, 15, GETDATE())), N'MC 娲涘窛', 228.00, 7, N'寮€鏀鹃绾?),
    (4, 2, DATEADD(DAY, 4, DATEADD(HOUR, 10, GETDATE())), N'MC 瀛愯】', 208.00, 8, N'寮€鏀鹃绾?),
    (2, 1, DATEADD(DAY, 4, DATEADD(HOUR, 18, GETDATE())), N'MC 闃跨懚', 198.00, 8, N'寮€鏀鹃绾?),
    (5, 3, DATEADD(DAY, 5, DATEADD(HOUR, 19, GETDATE())), N'MC 鏈ㄧ櫧', 218.00, 6, N'寮€鏀鹃绾?);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Reservations)
BEGIN
    INSERT INTO dbo.Reservations(SessionId, ContactName, Phone, PlayerCount, Remark, CreatedAt, Status)
    VALUES
    (1, N'闄堝悓瀛?, N'13800001111', 4, N'鎯冲畨鎺掓柊鎵嬪紩瀵笺€?, DATEADD(DAY, -2, GETDATE()), N'宸茬‘璁?),
    (2, N'鏉庡悓瀛?, N'13900002222', 6, N'鍥㈤槦鍥㈠缓灞€銆?, DATEADD(DAY, -1, GETDATE()), N'寰呯‘璁?),
    (4, N'鐜嬪悓瀛?, N'13700003333', 5, N'鎯冲潗闈犻棬浣嶇疆銆?, DATEADD(HOUR, -9, GETDATE()), N'寰呯‘璁?);
END
GO

UPDATE r
SET r.UnitPrice = se.BasePrice,
    r.TotalAmount = se.BasePrice * r.PlayerCount,
    r.PaymentStatus = CASE WHEN r.PaymentStatus IS NULL OR r.PaymentStatus = N'' OR r.PaymentStatus = N'绾夸笅纭' THEN N'宸叉敮浠? ELSE r.PaymentStatus END
FROM dbo.Reservations r
INNER JOIN dbo.Sessions se ON se.Id = r.SessionId
WHERE r.UnitPrice IS NULL
   OR r.TotalAmount IS NULL
   OR r.PaymentStatus IS NULL
   OR r.PaymentStatus = N'';
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Reviews)
BEGIN
    INSERT INTO dbo.Reviews(ScriptId, ReviewerName, Rating, Content, ReviewDate, HighlightTag)
    VALUES
    (1, N'鍗楅', 5, N'杩樺師閫昏緫鐗瑰埆瀹屾暣锛岀嚎绱㈠洖鏀跺緱寰堟紓浜紝閫傚悎鍠滄鎱㈢洏鐪熺浉鐨勭帺瀹躲€?, DATEADD(DAY, -10, GETDATE()), N'楂樿繕鍘?),
    (2, N'椴歌惤', 5, N'鎯呮劅绾垮緢鎵庡疄锛孨PC 甯﹀叆鎰熷己锛屾埧闂存皼鍥村拰婕旂粠鑺傚閮藉緢鍦ㄧ嚎銆?, DATEADD(DAY, -8, GETDATE()), N'楂樻矇娴?),
    (4, N'瑙佸北', 4, N'闃佃惀鍗氬紙鏈夎叮锛屽瀹磋瑙夌壒鍒€傚悎鏀惧湪棣栭〉鍋氶噸鐐规帹鑽愩€?, DATEADD(DAY, -7, GETDATE()), N'闃佃惀瀵规姉'),
    (5, N'涓冩湀', 5, N'鎭愭€栨紨缁庡拰鐏厜閰嶅悎澶己浜嗭紝棰勭害浜烘暟涔熷緢澶氾紝鍔ㄦ€佹暟鎹睍绀烘晥鏋滃緢濂姐€?, DATEADD(DAY, -6, GETDATE()), N'姘涘洿鍘嬭揩'),
    (3, N'闃挎洔', 4, N'娓彛棰樻潗灏戣锛岄€傚悎鍠滄娆у紡纭牳鐨勭帺瀹讹紝鏌ヨ鍜岃鎯呴〉浣撻獙寰堝ソ銆?, DATEADD(DAY, -5, GETDATE()), N'娆у紡鎺ㄧ悊'),
    (6, N'搴忕珷', 5, N'鏈哄埗鍜屾晠浜嬬粨鍚堝緱寰堝ソ锛岀鎶€鎰熼〉闈㈤鏍煎拰鍐呭寰堢粺涓€銆?, DATEADD(DAY, -4, GETDATE()), N'鏈哄埗鐑ц剳'),
    (2, N'鏈ㄦ湪', 4, N'瑙掕壊鍏崇郴寰堢粏锛岄€傚悎鐔熶汉杞︼紝棰勭害娴佺▼涔熷緢椤猴紝鎷艰溅缁勫眬浣撻獙涓嶉敊銆?, DATEADD(DAY, -3, GETDATE()), N'瑙掕壊鎷夋壇'),
    (4, N'鏃堕洦', 5, N'浠庡墽鏈埌鎴块棿閮藉緢瀹屾暣锛屽彜椋庢皼鍥淬€侀樀钀ュ崥寮堝拰婕旂粠钀界偣閮藉緢鏈夎蹇嗙偣銆?, DATEADD(DAY, -2, GETDATE()), N'鍙ら娌夋蹈');
END
GO
IF OBJECT_ID(N'dbo.GameStages', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.GameStages
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        StageKey NVARCHAR(30) NOT NULL,
        StageName NVARCHAR(60) NOT NULL,
        StageDescription NVARCHAR(300) NOT NULL,
        SortOrder INT NOT NULL,
        DurationMinutes INT NOT NULL
    );
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_GameStages_StageKey' AND object_id = OBJECT_ID(N'dbo.GameStages'))
BEGIN
    CREATE UNIQUE INDEX UX_GameStages_StageKey ON dbo.GameStages(StageKey);
END
GO

IF OBJECT_ID(N'dbo.SessionGameStates', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SessionGameStates
    (
        SessionId INT NOT NULL PRIMARY KEY,
        CurrentStageId INT NOT NULL,
        StartedAt DATETIME NOT NULL,
        UpdatedAt DATETIME NOT NULL,
        CONSTRAINT FK_SessionGameStates_Sessions FOREIGN KEY (SessionId) REFERENCES dbo.Sessions(Id),
        CONSTRAINT FK_SessionGameStates_GameStages FOREIGN KEY (CurrentStageId) REFERENCES dbo.GameStages(Id)
    );
END
GO

IF COL_LENGTH(N'dbo.SessionGameStates', N'GameStartedAt') IS NULL
BEGIN
    ALTER TABLE dbo.SessionGameStates ADD GameStartedAt DATETIME NULL;
END
GO

IF COL_LENGTH(N'dbo.SessionGameStates', N'GameEndedAt') IS NULL
BEGIN
    ALTER TABLE dbo.SessionGameStates ADD GameEndedAt DATETIME NULL;
END
GO

IF COL_LENGTH(N'dbo.SessionGameStates', N'SettledAt') IS NULL
BEGIN
    ALTER TABLE dbo.SessionGameStates ADD SettledAt DATETIME NULL;
END
GO

IF COL_LENGTH(N'dbo.SessionGameStates', N'StartedByUserId') IS NULL
BEGIN
    ALTER TABLE dbo.SessionGameStates ADD StartedByUserId INT NULL;
END
GO

IF COL_LENGTH(N'dbo.SessionGameStates', N'EndedByUserId') IS NULL
BEGIN
    ALTER TABLE dbo.SessionGameStates ADD EndedByUserId INT NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_SessionGameStates_StartedByUsers')
BEGIN
    ALTER TABLE dbo.SessionGameStates
    ADD CONSTRAINT FK_SessionGameStates_StartedByUsers FOREIGN KEY (StartedByUserId) REFERENCES dbo.Users(Id);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_SessionGameStates_EndedByUsers')
BEGIN
    ALTER TABLE dbo.SessionGameStates
    ADD CONSTRAINT FK_SessionGameStates_EndedByUsers FOREIGN KEY (EndedByUserId) REFERENCES dbo.Users(Id);
END
GO

IF OBJECT_ID(N'dbo.SessionCharacterAssignments', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SessionCharacterAssignments
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        SessionId INT NOT NULL,
        ReservationId INT NOT NULL,
        CharacterId INT NOT NULL,
        IsReady BIT NOT NULL CONSTRAINT DF_SessionCharacterAssignments_IsReady DEFAULT(0),
        CreatedAt DATETIME NOT NULL,
        CONSTRAINT FK_SessionCharacterAssignments_Sessions FOREIGN KEY (SessionId) REFERENCES dbo.Sessions(Id),
        CONSTRAINT FK_SessionCharacterAssignments_Reservations FOREIGN KEY (ReservationId) REFERENCES dbo.Reservations(Id),
        CONSTRAINT FK_SessionCharacterAssignments_ScriptCharacters FOREIGN KEY (CharacterId) REFERENCES dbo.ScriptCharacters(Id)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_SessionCharacterAssignments_SessionReservation' AND object_id = OBJECT_ID(N'dbo.SessionCharacterAssignments'))
BEGIN
    CREATE UNIQUE INDEX UX_SessionCharacterAssignments_SessionReservation
    ON dbo.SessionCharacterAssignments(SessionId, ReservationId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_SessionCharacterAssignments_SessionCharacter' AND object_id = OBJECT_ID(N'dbo.SessionCharacterAssignments'))
BEGIN
    CREATE UNIQUE INDEX UX_SessionCharacterAssignments_SessionCharacter
    ON dbo.SessionCharacterAssignments(SessionId, CharacterId);
END
GO

IF OBJECT_ID(N'dbo.ScriptClues', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ScriptClues
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ScriptId INT NOT NULL,
        StageId INT NULL,
        Title NVARCHAR(100) NOT NULL,
        Summary NVARCHAR(200) NOT NULL,
        Detail NVARCHAR(500) NOT NULL,
        ClueType NVARCHAR(30) NOT NULL,
        IsPublic BIT NOT NULL CONSTRAINT DF_ScriptClues_IsPublic DEFAULT(1),
        SortOrder INT NOT NULL,
        CONSTRAINT FK_ScriptClues_Scripts FOREIGN KEY (ScriptId) REFERENCES dbo.Scripts(Id),
        CONSTRAINT FK_ScriptClues_GameStages FOREIGN KEY (StageId) REFERENCES dbo.GameStages(Id)
    );
END
GO

IF OBJECT_ID(N'dbo.SessionClueUnlocks', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SessionClueUnlocks
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        SessionId INT NOT NULL,
        ClueId INT NOT NULL,
        RevealedToReservationId INT NULL,
        UnlockedByReservationId INT NULL,
        RevealMethod NVARCHAR(40) NOT NULL,
        RevealedAt DATETIME NOT NULL,
        CONSTRAINT FK_SessionClueUnlocks_Sessions FOREIGN KEY (SessionId) REFERENCES dbo.Sessions(Id),
        CONSTRAINT FK_SessionClueUnlocks_ScriptClues FOREIGN KEY (ClueId) REFERENCES dbo.ScriptClues(Id),
        CONSTRAINT FK_SessionClueUnlocks_RevealedToReservations FOREIGN KEY (RevealedToReservationId) REFERENCES dbo.Reservations(Id),
        CONSTRAINT FK_SessionClueUnlocks_UnlockedByReservations FOREIGN KEY (UnlockedByReservationId) REFERENCES dbo.Reservations(Id)
    );
END
GO

IF OBJECT_ID(N'dbo.SessionActionLogs', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SessionActionLogs
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        SessionId INT NOT NULL,
        ReservationId INT NULL,
        ActionType NVARCHAR(30) NOT NULL,
        ActionTitle NVARCHAR(100) NOT NULL,
        ActionContent NVARCHAR(500) NOT NULL,
        CreatedAt DATETIME NOT NULL,
        CONSTRAINT FK_SessionActionLogs_Sessions FOREIGN KEY (SessionId) REFERENCES dbo.Sessions(Id),
        CONSTRAINT FK_SessionActionLogs_Reservations FOREIGN KEY (ReservationId) REFERENCES dbo.Reservations(Id)
    );
END
GO

IF OBJECT_ID(N'dbo.SessionVotes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SessionVotes
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        SessionId INT NOT NULL,
        ReservationId INT NOT NULL,
        SuspectCharacterId INT NOT NULL,
        VoteComment NVARCHAR(300) NULL,
        CreatedAt DATETIME NOT NULL,
        CONSTRAINT FK_SessionVotes_Sessions FOREIGN KEY (SessionId) REFERENCES dbo.Sessions(Id),
        CONSTRAINT FK_SessionVotes_Reservations FOREIGN KEY (ReservationId) REFERENCES dbo.Reservations(Id),
        CONSTRAINT FK_SessionVotes_ScriptCharacters FOREIGN KEY (SuspectCharacterId) REFERENCES dbo.ScriptCharacters(Id)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_SessionVotes_SessionReservation' AND object_id = OBJECT_ID(N'dbo.SessionVotes'))
BEGIN
    CREATE UNIQUE INDEX UX_SessionVotes_SessionReservation ON dbo.SessionVotes(SessionId, ReservationId);
END
GO

IF OBJECT_ID(N'dbo.PlayerBattleRecords', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PlayerBattleRecords
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        SessionId INT NOT NULL,
        ReservationId INT NOT NULL,
        UserId INT NOT NULL,
        ScriptId INT NOT NULL,
        ScriptName NVARCHAR(100) NOT NULL,
        RoomName NVARCHAR(80) NOT NULL,
        CharacterId INT NULL,
        CharacterName NVARCHAR(50) NOT NULL,
        WasCorrect BIT NOT NULL CONSTRAINT DF_PlayerBattleRecords_WasCorrect DEFAULT(0),
        ResultTag NVARCHAR(30) NOT NULL,
        VotedCharacterId INT NULL,
        VotedCharacterName NVARCHAR(50) NULL,
        CorrectCharacterName NVARCHAR(50) NOT NULL,
        CompletedAt DATETIME NOT NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_PlayerBattleRecords_CreatedAt DEFAULT(GETDATE()),
        CONSTRAINT FK_PlayerBattleRecords_Sessions FOREIGN KEY (SessionId) REFERENCES dbo.Sessions(Id),
        CONSTRAINT FK_PlayerBattleRecords_Reservations FOREIGN KEY (ReservationId) REFERENCES dbo.Reservations(Id),
        CONSTRAINT FK_PlayerBattleRecords_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id),
        CONSTRAINT FK_PlayerBattleRecords_Scripts FOREIGN KEY (ScriptId) REFERENCES dbo.Scripts(Id),
        CONSTRAINT FK_PlayerBattleRecords_Characters FOREIGN KEY (CharacterId) REFERENCES dbo.ScriptCharacters(Id),
        CONSTRAINT FK_PlayerBattleRecords_VotedCharacters FOREIGN KEY (VotedCharacterId) REFERENCES dbo.ScriptCharacters(Id)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_PlayerBattleRecords_SessionReservation' AND object_id = OBJECT_ID(N'dbo.PlayerBattleRecords'))
BEGIN
    CREATE UNIQUE INDEX UX_PlayerBattleRecords_SessionReservation ON dbo.PlayerBattleRecords(SessionId, ReservationId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PlayerBattleRecords_User_CompletedAt' AND object_id = OBJECT_ID(N'dbo.PlayerBattleRecords'))
BEGIN
    CREATE INDEX IX_PlayerBattleRecords_User_CompletedAt ON dbo.PlayerBattleRecords(UserId, CompletedAt DESC);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.GameStages)
BEGIN
    INSERT INTO dbo.GameStages(StageKey, StageName, StageDescription, SortOrder, DurationMinutes)
    VALUES
    (N'opening', N'寮€鍦哄鍏?, N'DM 浠嬬粛鏁呬簨鑳屾櫙銆佺帺瀹剁‘璁よ韩浠藉苟瀹屾垚鍩虹鐮村啺銆?, 1, 20),
    (N'investigation', N'绾跨储鎼滆瘉', N'鐜╁鍥寸粫妗堝彂鐜板満銆佷汉鐗╁叧绯诲拰鍏抽敭鐗╄瘉灞曞紑璋冩煡銆?, 2, 35),
    (N'deduction', N'闆嗕腑鎺ㄧ悊', N'鍚勪綅鐜╁浜ゆ崲绾跨储銆佹嫾鎺ユ椂闂寸嚎骞堕攣瀹氭牳蹇冨珜鐤戙€?, 3, 30),
    (N'ending', N'缁堝眬澶嶇洏', N'瀹屾垚鍑舵墜閿佸畾銆佸姩鏈鸿繕鍘熷拰缁撳眬澶嶇洏灞曠ず銆?, 4, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ScriptClues)
BEGIN
    INSERT INTO dbo.ScriptClues(ScriptId, StageId, Title, Summary, Detail, ClueType, IsPublic, SortOrder)
    VALUES
    (1, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'opening'), N'杩熷埌鐨勯仐涔?, N'鎵€鏈変汉閮芥敹鍒颁簡鍚屼竴灏佸欢杩熷崄浜斿勾鐨勯仐涔﹀鍗颁欢銆?, N'閬椾功鐨勮惤娆炬椂闂翠笌鐤楀吇闄㈠仠鐢佃褰曚笉涓€鑷达紝璇存槑鏈変汉鍦ㄤ簨鍚庣鏀逛簡瀵勫嚭鏃堕棿銆?, N'鏂囦功', 1, 1),
    (1, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'investigation'), N'缂哄け鐨勪竴鍒嗛挓', N'鐩戞帶褰曞儚鍦ㄦ鍙戝墠鍚庢伆濂界己澶变竴鍒嗛挓銆?, N'褰曞儚缂哄彛瀵瑰簲鐨勬槸鍖荤敓鍊肩彮浜ゆ帴鏃堕棿锛岃鏄庣湡姝ｇ殑鎿嶇洏鑰呯啛鎮夌枟鍏婚櫌鍐呴儴娴佺▼銆?, N'鐩戞帶', 1, 2),
    (1, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'investigation'), N'鍖垮悕褰曢煶', N'浣犵殑鍙ｈ閲屾湁涓€娈垫湭鍏紑鐨勯噰璁垮綍闊炽€?, N'褰曢煶閲屽弽澶嶅嚭鐜扳€滆蹇嗚鍊熻蛋鈥濈殑琛ㄨ堪锛屾殫绀哄嚩妗堜笌褰撳勾鐨勫尰鐤楀疄楠屾湁鍏炽€?, N'绉佸瘑', 0, 3),
    (1, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'deduction'), N'鍒犻櫎鐥呭巻', N'鐥呭巻缂栧彿涓庝綇闄㈠悕鍗曚箣闂村瓨鍦ㄤ竴鏉¤浜轰负鍒犻櫎鐨勬槧灏勫叧绯汇€?, N'琚垹闄ょ殑鍚嶅瓧涓庢鑰呯殑缁ф壙绾犵悍鐩存帴鐩稿叧锛屽嚩鎵嬭瘯鍥炬姽闄よ嚜宸辨帴鍙楄繃娌荤枟鐨勪簨瀹炪€?, N'妗ｆ', 1, 4),

    (2, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'opening'), N'鍋滅數鍓嶇殑鐞村０', N'鏃呴鍦ㄥ仠鐢靛墠鍝嶈捣浜嗕竴娈靛苟涓嶅瓨鍦ㄤ簬鑺傜洰鍗曢噷鐨勬棆寰嬨€?, N'閭ｆ鏃嬪緥鍙細鍑虹幇鍦ㄨ€佹澘绉佷汉鏀惰棌鐨勬棫鐣欏０鏈洪噷锛岃鏄庢鍙戝墠鏈変汉杩涘叆杩囧皝闂偍钘忓銆?, N'澹伴煶', 1, 1),
    (2, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'investigation'), N'204 鎴块棬鍗?, N'鍞竴涓€寮?204 鎴跨殑澶囩敤闂ㄥ崱涓嶈浜嗐€?, N'闂ㄥ崱琚す鍦ㄨ处鏈悗椤碉紝璇存槑绠＄悊鑰呰瘯鍥炬妸鈥滄棤娉曡繘鍏モ€濈殑鎴块棿浼鎴愮粷瀵瑰瘑瀹ゃ€?, N'鐗╄瘉', 1, 2),
    (2, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'investigation'), N'浼€犵殑姝诲洜', N'浣犳彁鍓嶇湅杩囧案浣擄紝骞跺彂鐜拌〃闈㈡鍥犱笌瀹為檯鎹熶激涓嶄竴鑷淬€?, N'姝昏€呯湡姝ｆ浜℃椂闂存瘮鍋滅數鏃╄繎鍥涘崄鍒嗛挓锛屾梾棣嗗唴鑷冲皯鏈変汉鍦ㄦ鍙戝悗甯冪疆鐜板満銆?, N'绉佸瘑', 0, 3),
    (2, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'deduction'), N'鏆撮洦灏佽矾璁板綍', N'灞卞尯閬撹矾灏侀攣鏃堕棿涓庢梾棣嗘姤妗堟椂闂存棤娉曞涓娿€?, N'鎶ユ琚埢鎰忓欢鍚庯紝鐩殑鏄瓑寰呮煇浣嶈繜鍒扮殑鍏卞悓鍙備笌鑰呰繘鍏ユ梾棣嗐€?, N'璁板綍', 1, 4),

    (3, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'opening'), N'澶辫釜璁憳鍚嶅崟', N'娓彛浼犻椈閲屽弽澶嶅嚭鐜颁竴浣嶅け韪鍛樼殑鍚嶅瓧銆?, N'璁憳鏈€鍚庝竴娆″嚭鐜扮殑鍦扮偣骞朵笉鏄爜澶达紝鑰屾槸娴峰叧浠撳簱锛岃繖璁╂浠舵寚鍚戞洿楂樺眰鐨勫埄鐩婁氦鎹€?, N'鎯呮姤', 1, 1),
    (3, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'investigation'), N'娓呭崟涓婄殑娑傛敼', N'璐ц繍娓呭崟鏈変竴鏍忚澧ㄦ按鍙嶅瑕嗙洊銆?, N'琚鐩栫殑姝ｆ槸鍐涢渶闆朵欢鍨嬪彿锛岃鏄庤繍閫佺洰鏍囧苟闈炴櫘閫氳蛋绉佽揣锛岃€屾槸鏀挎不浜ゆ槗绛圭爜銆?, N'鍗曟嵁', 1, 2),
    (3, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'investigation'), N'搴曠墖缂鸿', N'浣犱繚瀛樼殑鐓х墖搴曠墖鍙充笅瑙掕浜哄壀鍘讳簡涓€鍧椼€?, N'缂哄け鐨勯偅涓€瑙掓濂藉彲浠ユ媿鍒颁笌榛戝府浜ゆ帴鐨勪汉褰憋紝璇存槑鏈変汉璇曞浘淇濇姢骞曞悗涔板銆?, N'绉佸瘑', 0, 3),
    (3, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'deduction'), N'澶滃崐鎹㈠矖', N'鐮佸ご澶滅彮鍚嶅唽鏄剧ず褰撴櫄鏈変竴娆″紓甯告崲宀椼€?, N'鎹㈠矖鍚庣殑鍗佸垎閽熷唴锛屽彧鏈夌啛鎮夎鍗稿姩绾跨殑浜烘墠鑳藉畬鎴愯揣鐗╄浆绉汇€?, N'鎺掔彮', 1, 4),

    (4, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'opening'), N'閿欐媿涓夊０', N'搴嗗姛澶滃鐨勪箰鏇插湪绗笁娈靛嚭鐜颁簡寮傚父鑺傛媿銆?, N'閭ｄ笁澹拌妭鎷嶅師鏈槸棰勫畾鐨勬殫鍙凤紝鐢ㄦ潵鎻愰啋鍚岀洘鑰呭噯澶囨帺鎶よ鍔ㄣ€?, N'涔愯氨', 1, 1),
    (4, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'investigation'), N'鍏电鍘诲悜', N'鍐涜惀鍏电娌℃湁鎸夎绋嬪洖鏀跺叆搴撱€?, N'鍏电娴佸悜鎰忓懗鐫€鏈変汉鍊熲€滆皟鍏碘€濅箣鍚嶅埗閫犲瀹村閮ㄦ贩涔憋紝涓哄埡鏉€鍒涢€犳椂鏈恒€?, N'鍐涘姟', 1, 2),
    (4, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'investigation'), N'鏄熺洏缂哄彛', N'浣犲彂鐜板ぉ鐩戝彴鐨勬槦鐩樿浜虹（鎺変簡涓€灏忓潡銆?, N'缂哄彛瀵瑰簲鐨勬槸鍑舵褰撳鐨勫ぉ璞★紝骞曞悗鑰呭€熷ぉ鐏句箣璇存帺鐩栭璋嬫椂闂淬€?, N'绉佸瘑', 0, 3),
    (4, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'deduction'), N'澶栦娇鏉ヤ俊', N'瀹翠細鍓嶅鏈変竴灏佸苟鏈櫥璁扮殑澶栦娇瀵嗕俊銆?, N'淇′腑瑕佹眰鈥滃簡鍔熶箣鍚庣珛鍗虫崲鍌ㄢ€濓紝琛ㄦ槑鍑舵鑳屽悗骞朵笉鍙槸涓汉鎭╂€紝鑰屾槸闃佃惀閲嶇粍銆?, N'瀵嗕俊', 1, 4),

    (5, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'opening'), N'閲嶅姊﹀', N'澶氫綅鍙楄瘯鑰呮弿杩颁簡鐩稿悓鐨勬ⅵ澧冪敾闈€?, N'姊﹀鐨勭粏鑺備笌灏侀櫌鍓嶄竴鍦哄疄楠屽綍鍍忛珮搴︿竴鑷达紝璇存槑鏈変汉鍦ㄥ埄鐢ㄦ殫绀洪噸鍐欐偅鑰呰蹇嗐€?, N'蹇冪悊', 1, 1),
    (5, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'investigation'), N'绌虹櫧鑽崟', N'鑽埧鐧昏閲屽嚭鐜颁簡涓€寮犲畬鍏ㄧ┖鐧藉嵈宸茬绔犵殑鑽崟銆?, N'绌虹櫧鑽崟浠ｈ〃鏈変汉鍙互鍦ㄤ笉鐣欑棔杩圭殑鎯呭喌涓嬭皟鐢ㄩ晣闈欒嵂鐗╋紝姝昏€呭苟闈炶嚜鐒舵浜°€?, N'鍖诲槺', 1, 2),
    (5, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'investigation'), N'灏佸瓨瀹為獙', N'浣犳帉鎻′竴浠借闄㈡柟鍒绘剰灏佸瓨鐨勫闂村疄楠屾憳瑕併€?, N'鎽樿鏄剧ず鎵€璋撹瀵熸不鐤楀叾瀹炴槸涓€鍦虹瓫閫夋湇浠庢€х殑娈嬮叿璇曢獙銆?, N'绉佸瘑', 0, 3),
    (5, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'deduction'), N'闀滈潰缂栧彿', N'涓嶅悓鐥呮埧鐨勯暅闈㈣儗鍚庤鍐欎笂浜嗛殣钘忕紪鍙枫€?, N'缂栧彿姝ｅソ瀵瑰簲鍙楄瘯鑰呰蹇嗚瀵奸『搴忥紝鍑舵墜琛岃釜鍥犳鑳藉琚噸鏂版嫾鍑恒€?, N'鐜', 1, 4),

    (6, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'opening'), N'涓夊勾鍓嶇殑寮傚父淇″彿', N'绌洪棿绔欓噸鏂版敹鍒颁竴娈垫潵鑷笁骞村墠鐨勯敊璇眰鏁戜俊鍙枫€?, N'淇″彿鍖呴噷宓屽叆浜嗗彧鍦ㄤ簨鏁呭綋澶╀娇鐢ㄨ繃鐨勫瘑閽ワ紝璇存槑鏈変汉鎻愬墠棰勭暀浜嗗洖婧叆鍙ｃ€?, N'淇″彿', 1, 1),
    (6, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'investigation'), N'涓绘帶鏉冮檺鏃ュ織', N'涓绘帶鍙版潈闄愯褰曞湪浜嬫晠鍙戠敓鍓嶅嚭鐜颁簡鐭殏瓒婃潈銆?, N'瓒婃潈璐︽埛鍙寔缁節鍗佺锛屽嵈瓒充互鏀瑰啓鑸辨闂ㄧ鍜屾哀姘旈榾闂ㄦ帶鍒跺簭鍒椼€?, N'鏃ュ織', 1, 2),
    (6, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'investigation'), N'璁板繂澶囦唤鍏ュ彛', N'浣犵煡閬撲竴澶勬病鏈夎褰曞湪鍏綉涓婄殑璁板繂澶囦唤鍏ュ彛銆?, N'鍏ュ彛鑳芥仮澶嶅垹鏀瑰墠鐨勫洟闃熶簤鎵ц褰曪紝涔熶細鏆撮湶浣犳浘鍙備笌鏍稿績鍐崇瓥銆?, N'绉佸瘑', 0, 3),
    (6, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'deduction'), N'鎯呯华鏃ヨ', N'涓€浠藉績鐞嗘棩蹇楁樉绀哄洟闃熷湪浜嬫晠鍓嶅凡缁忓嚭鐜颁弗閲嶈鐥曘€?, N'鏃ュ織鎻愬埌鈥滀笉鏄郴缁熷け鎺э紝鑰屾槸鏈変汉鍐冲畾璁╃郴缁熻儗閿呪€濓紝鐩存帴鏀瑰彉浜嗗嚩妗堟帹鐞嗘柟鍚戙€?, N'鏃ュ織', 1, 4);
END
GO

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
        SortOrder INT NOT NULL CONSTRAINT DF_ShowcaseStats_SortOrder DEFAULT (1),
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
        SortOrder INT NOT NULL CONSTRAINT DF_ShowcaseSections_SortOrder DEFAULT (1),
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
        ImageUrl NVARCHAR(300) NOT NULL,
        ActionText NVARCHAR(80) NULL,
        ActionUrl NVARCHAR(200) NULL,
        AccentValue NVARCHAR(80) NULL,
        SortOrder INT NOT NULL CONSTRAINT DF_ShowcaseEntries_SortOrder DEFAULT (1),
        CONSTRAINT FK_ShowcaseEntries_Section FOREIGN KEY (ShowcaseSectionId) REFERENCES dbo.ShowcaseSections(Id)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'', N'', N'', N' ????', N'', N'', N'', N'', N'', N'', N'');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'????', N'100%', 1),
    (@ShowcasePageId, N'????', N'2 ?', 2),
    (@ShowcasePageId, N'?????', N'???', 3),
    (@ShowcasePageId, N'????', N'2 ?', 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'???', N'?????????????????????????????', N'???', N'???????', N'?????????', N'?????????', N'', N'', N'', N'????', 1),
    (@SectionOneId, N'???????', N'??????????????????????????????', N'????', N'?????????', N'????????', N'?????????????', N'', N'', N'', N'????', 2),
    (@SectionOneId, N'??????', N'??????????????????????????????', N'????', N'???????', N'??????????', N'?????????', N'', N'??????', N'', N'????', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'', N'', N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'???????', N'????????? ShowcasePages?ShowcaseSections?ShowcaseEntries ? ShowcaseStats ???', N'???', N'???????', N'??????????', N'???????', N'', N'?????', N'ScriptsList.aspx', N'????', 1),
    (@SectionTwoId, N'??????', N'????', N'????', N'??????', N'??????', N'?????????', N'', N'????', N'Default.aspx', N'????', 2),
    (@SectionTwoId, N'??????', N'??????????????????????????????????????????', N'???', N'??????', N'???????????', N'??????', N'', N'', N'', N'?????', 3);
END
GO


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
        SortOrder INT NOT NULL CONSTRAINT DF_ShowcaseStats_SortOrder DEFAULT (1),
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
        SortOrder INT NOT NULL CONSTRAINT DF_ShowcaseSections_SortOrder DEFAULT (1),
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
        ImageUrl NVARCHAR(300) NOT NULL,
        ActionText NVARCHAR(80) NULL,
        ActionUrl NVARCHAR(200) NULL,
        AccentValue NVARCHAR(80) NULL,
        SortOrder INT NOT NULL CONSTRAINT DF_ShowcaseEntries_SortOrder DEFAULT (1),
        CONSTRAINT FK_ShowcaseEntries_Section FOREIGN KEY (ShowcaseSectionId) REFERENCES dbo.ShowcaseSections(Id)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'AR澧炲己鐜板疄婵€娲?)
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'AR澧炲己鐜板疄婵€娲?, N'AR澧炲己鐜板疄婵€娲?, N'GAME', N'AR澧炲己鐜板疄婵€娲?鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'灞€鍐呯帺娉曚笌娌夋蹈浜や簰', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'AR澧炲己鐜板疄婵€娲?鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'AR澧炲己鐜板疄婵€娲讳富鐣岄潰', N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'GameRoom.aspx?reservationId=1', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'灞€鍐呮祦绋嬩笌浜や簰鑱斿姩', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鍦烘櫙鎼缓宸ュ叿')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鍦烘櫙鎼缓宸ュ叿', N'鍦烘櫙鎼缓宸ュ叿', N'CREATOR', N'鍦烘櫙鎼缓宸ュ叿 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鍒涗綔涓庤繍钀ュ悗鍙?, N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍦烘櫙鎼缓宸ュ叿 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鍦烘櫙鎼缓宸ュ叿涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'CreatorCenter.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍒涗綔娴佺▼涓庢暟鎹簱鍚屾', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'娌夋蹈寮忔父鎴忓満鏅?)
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'娌夋蹈寮忔父鎴忓満鏅?, N'娌夋蹈寮忔父鎴忓満鏅?, N'GAME', N'娌夋蹈寮忔父鎴忓満鏅?鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'灞€鍐呯帺娉曚笌娌夋蹈浜や簰', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'娌夋蹈寮忔父鎴忓満鏅?鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'娌夋蹈寮忔父鎴忓満鏅富鐣岄潰', N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'GameRoom.aspx?reservationId=1', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'灞€鍐呮祦绋嬩笌浜や簰鑱斿姩', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鎴愬氨鍕嬬珷澧?)
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鎴愬氨鍕嬬珷澧?, N'鎴愬氨鍕嬬珷澧?, N'PLAYER', N'鎴愬氨鍕嬬珷澧?鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鐜╁鎴愰暱涓庤韩浠界郴缁?, N'杩涘叆鐜╁涓績', N'PlayerHub.aspx', N'鏌ョ湅鍙戠幇涓績', N'Discover.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鎴愬氨鍕嬬珷澧?鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鎴愬氨鍕嬬珷澧欎富鐣岄潰', N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鐜╁涓績', N'PlayerHub.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍙戠幇涓績', N'Discover.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'PlayerHub.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鎴愰暱鐢诲儚涓庢垚灏辨矇娣€', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍙戠幇涓績', N'Discover.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鍒涗綔鑰呭伐浣滃彴')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鍒涗綔鑰呭伐浣滃彴', N'鍒涗綔鑰呭伐浣滃彴', N'CREATOR', N'鍒涗綔鑰呭伐浣滃彴 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鍒涗綔涓庤繍钀ュ悗鍙?, N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍒涗綔鑰呭伐浣滃彴 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鍒涗綔鑰呭伐浣滃彴涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'CreatorCenter.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍒涗綔娴佺▼涓庢暟鎹簱鍚屾', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鍔ㄦ€侀毦搴﹁皟鑺傞潰鏉?)
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鍔ㄦ€侀毦搴﹁皟鑺傞潰鏉?, N'鍔ㄦ€侀毦搴﹁皟鑺傞潰鏉?, N'GAME', N'鍔ㄦ€侀毦搴﹁皟鑺傞潰鏉?鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'灞€鍐呯帺娉曚笌娌夋蹈浜や簰', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍔ㄦ€侀毦搴﹁皟鑺傞潰鏉?鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鍔ㄦ€侀毦搴﹁皟鑺傞潰鏉夸富鐣岄潰', N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'GameRoom.aspx?reservationId=1', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'灞€鍐呮祦绋嬩笌浜や簰鑱斿姩', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鎴块棿鍖归厤鍔犲叆')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鎴块棿鍖归厤鍔犲叆', N'鎴块棿鍖归厤鍔犲叆', N'GAME', N'鎴块棿鍖归厤鍔犲叆 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'灞€鍐呯帺娉曚笌娌夋蹈浜や簰', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鎴块棿鍖归厤鍔犲叆 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鎴块棿鍖归厤鍔犲叆涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'GameRoom.aspx?reservationId=1', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'灞€鍐呮祦绋嬩笌浜や簰鑱斿姩', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'瑙傛垬鑱婂ぉ浜掑姩')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'瑙傛垬鑱婂ぉ浜掑姩', N'瑙傛垬鑱婂ぉ浜掑姩', N'SPECTATOR', N'瑙傛垬鑱婂ぉ浜掑姩 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'瑙傛垬涓庣洿鎾ā鍧?, N'杩涘叆瑙傛垬涓績', N'Spectator.aspx', N'杩涘叆婕旂ず鎴块棿', N'GameRoom.aspx?reservationId=1');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'瑙傛垬鑱婂ぉ浜掑姩 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'瑙傛垬鑱婂ぉ浜掑姩涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'杩涘叆瑙傛垬涓績', N'Spectator.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'杩涘叆婕旂ず鎴块棿', N'GameRoom.aspx?reservationId=1', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'Spectator.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'瑙傛垬浜掑姩涓庣儹搴﹁仈鍔?, N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'杩涘叆婕旂ず鎴块棿', N'GameRoom.aspx?reservationId=1', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'瑙傛垬妯″紡閫夋嫨')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'瑙傛垬妯″紡閫夋嫨', N'瑙傛垬妯″紡閫夋嫨', N'SPECTATOR', N'瑙傛垬妯″紡閫夋嫨 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'瑙傛垬涓庣洿鎾ā鍧?, N'杩涘叆瑙傛垬涓績', N'Spectator.aspx', N'杩涘叆婕旂ず鎴块棿', N'GameRoom.aspx?reservationId=1');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'瑙傛垬妯″紡閫夋嫨 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'瑙傛垬妯″紡閫夋嫨涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'杩涘叆瑙傛垬涓績', N'Spectator.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'杩涘叆婕旂ず鎴块棿', N'GameRoom.aspx?reservationId=1', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'Spectator.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'瑙傛垬浜掑姩涓庣儹搴﹁仈鍔?, N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'杩涘叆婕旂ず鎴块棿', N'GameRoom.aspx?reservationId=1', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'瑙傛垬娓告垙瑙嗗浘')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'瑙傛垬娓告垙瑙嗗浘', N'瑙傛垬娓告垙瑙嗗浘', N'SPECTATOR', N'瑙傛垬娓告垙瑙嗗浘 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'瑙傛垬涓庣洿鎾ā鍧?, N'杩涘叆瑙傛垬涓績', N'Spectator.aspx', N'杩涘叆婕旂ず鎴块棿', N'GameRoom.aspx?reservationId=1');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'瑙傛垬娓告垙瑙嗗浘 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'瑙傛垬娓告垙瑙嗗浘涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'杩涘叆瑙傛垬涓績', N'Spectator.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'杩涘叆婕旂ず鎴块棿', N'GameRoom.aspx?reservationId=1', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'Spectator.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'瑙傛垬浜掑姩涓庣儹搴﹁仈鍔?, N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'杩涘叆婕旂ず鎴块棿', N'GameRoom.aspx?reservationId=1', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'浼氬憳璁㈤槄鏈嶅姟绠＄悊')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'浼氬憳璁㈤槄鏈嶅姟绠＄悊', N'浼氬憳璁㈤槄鏈嶅姟绠＄悊', N'DISCOVER', N'浼氬憳璁㈤槄鏈嶅姟绠＄悊 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鎺ㄨ崘涓庡钩鍙版湇鍔?, N'杩涘叆鍙戠幇涓績', N'Discover.aspx', N'娴忚鍓ф湰搴?, N'ScriptsList.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'浼氬憳璁㈤槄鏈嶅姟绠＄悊 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'浼氬憳璁㈤槄鏈嶅姟绠＄悊涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鍙戠幇涓績', N'Discover.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'娴忚鍓ф湰搴?, N'ScriptsList.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'Discover.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鎺ㄨ崘鍐呭涓庢湇鍔￠厤缃?, N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'娴忚鍓ф湰搴?, N'ScriptsList.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'瑙掕壊鍗¤鍥?)
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'瑙掕壊鍗¤鍥?, N'瑙掕壊鍗¤鍥?, N'GAME', N'瑙掕壊鍗¤鍥?鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'灞€鍐呯帺娉曚笌娌夋蹈浜や簰', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'瑙掕壊鍗¤鍥?鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'瑙掕壊鍗¤鍥句富鐣岄潰', N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'GameRoom.aspx?reservationId=1', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'灞€鍐呮祦绋嬩笌浜や簰鑱斿姩', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'瑙ｈ皽鐣岄潰')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'瑙ｈ皽鐣岄潰', N'瑙ｈ皽鐣岄潰', N'GAME', N'瑙ｈ皽鐣岄潰 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'灞€鍐呯帺娉曚笌娌夋蹈浜や簰', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'瑙ｈ皽鐣岄潰 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'瑙ｈ皽鐣岄潰涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'GameRoom.aspx?reservationId=1', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'灞€鍐呮祦绋嬩笌浜や簰鑱斿姩', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'浠婃棩鎺ㄨ崘')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'浠婃棩鎺ㄨ崘', N'浠婃棩鎺ㄨ崘', N'DISCOVER', N'浠婃棩鎺ㄨ崘 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鎺ㄨ崘涓庡钩鍙版湇鍔?, N'杩涘叆鍙戠幇涓績', N'Discover.aspx', N'娴忚鍓ф湰搴?, N'ScriptsList.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'浠婃棩鎺ㄨ崘 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'浠婃棩鎺ㄨ崘涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鍙戠幇涓績', N'Discover.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'娴忚鍓ф湰搴?, N'ScriptsList.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'Discover.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鎺ㄨ崘鍐呭涓庢湇鍔￠厤缃?, N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'娴忚鍓ф湰搴?, N'ScriptsList.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鍓ф湰鍒涗綔缂栬緫鍣?)
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鍓ф湰鍒涗綔缂栬緫鍣?, N'鍓ф湰鍒涗綔缂栬緫鍣?, N'CREATOR', N'鍓ф湰鍒涗綔缂栬緫鍣?鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鍒涗綔涓庤繍钀ュ悗鍙?, N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍓ф湰鍒涗綔缂栬緫鍣?鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鍓ф湰鍒涗綔缂栬緫鍣ㄤ富鐣岄潰', N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'CreatorCenter.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍒涗綔娴佺▼涓庢暟鎹簱鍚屾', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鍓ф湰鍒涗綔鍒嗘垚璁剧疆')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鍓ф湰鍒涗綔鍒嗘垚璁剧疆', N'鍓ф湰鍒涗綔鍒嗘垚璁剧疆', N'CREATOR', N'鍓ф湰鍒涗綔鍒嗘垚璁剧疆 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鍒涗綔涓庤繍钀ュ悗鍙?, N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍓ф湰鍒涗綔鍒嗘垚璁剧疆 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鍓ф湰鍒涗綔鍒嗘垚璁剧疆涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'CreatorCenter.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍒涗綔娴佺▼涓庢暟鎹簱鍚屾', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鍓ф湰鍒涗綔鑰呮。妗?)
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鍓ф湰鍒涗綔鑰呮。妗?, N'鍓ф湰鍒涗綔鑰呮。妗?, N'CREATOR', N'鍓ф湰鍒涗綔鑰呮。妗?鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鍒涗綔涓庤繍钀ュ悗鍙?, N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍓ф湰鍒涗綔鑰呮。妗?鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鍓ф湰鍒涗綔鑰呮。妗堜富鐣岄潰', N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'CreatorCenter.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍒涗綔娴佺▼涓庢暟鎹簱鍚屾', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鍓ф湰鍙戝竷璁剧疆')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鍓ф湰鍙戝竷璁剧疆', N'鍓ф湰鍙戝竷璁剧疆', N'CREATOR', N'鍓ф湰鍙戝竷璁剧疆 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鍒涗綔涓庤繍钀ュ悗鍙?, N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍓ф湰鍙戝竷璁剧疆 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鍓ф湰鍙戝竷璁剧疆涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'CreatorCenter.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍒涗綔娴佺▼涓庢暟鎹簱鍚屾', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鍓ф湰绠＄悊涓庣増鏈帶鍒?)
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鍓ф湰绠＄悊涓庣増鏈帶鍒?, N'鍓ф湰绠＄悊涓庣増鏈帶鍒?, N'CREATOR', N'鍓ф湰绠＄悊涓庣増鏈帶鍒?鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鍒涗綔涓庤繍钀ュ悗鍙?, N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍓ф湰绠＄悊涓庣増鏈帶鍒?鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鍓ф湰绠＄悊涓庣増鏈帶鍒朵富鐣岄潰', N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'CreatorCenter.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍒涗綔娴佺▼涓庢暟鎹簱鍚屾', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鍓ф湰瀹℃牳鎻愪氦')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鍓ф湰瀹℃牳鎻愪氦', N'鍓ф湰瀹℃牳鎻愪氦', N'CREATOR', N'鍓ф湰瀹℃牳鎻愪氦 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鍒涗綔涓庤繍钀ュ悗鍙?, N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍓ф湰瀹℃牳鎻愪氦 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鍓ф湰瀹℃牳鎻愪氦涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'CreatorCenter.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍒涗綔娴佺▼涓庢暟鎹簱鍚屾', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鍓ф湰瀹屾垚鐜囧垎鏋?)
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鍓ф湰瀹屾垚鐜囧垎鏋?, N'鍓ф湰瀹屾垚鐜囧垎鏋?, N'ANALYTICS', N'鍓ф湰瀹屾垚鐜囧垎鏋?鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'缁忚惀涓庢暟鎹垎鏋?, N'杩涘叆鏁版嵁鍒嗘瀽', N'Analytics.aspx', N'鏌ョ湅閽卞寘涓績', N'Wallet.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍓ф湰瀹屾垚鐜囧垎鏋?鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鍓ф湰瀹屾垚鐜囧垎鏋愪富鐣岄潰', N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鏁版嵁鍒嗘瀽', N'Analytics.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅閽卞寘涓績', N'Wallet.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'Analytics.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'缁熻缁撴灉涓庣粡钀ュ喅绛?, N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅閽卞寘涓績', N'Wallet.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鍓ф儏鍒嗘敮浜嬩欢')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鍓ф儏鍒嗘敮浜嬩欢', N'鍓ф儏鍒嗘敮浜嬩欢', N'CREATOR', N'鍓ф儏鍒嗘敮浜嬩欢 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鍒涗綔涓庤繍钀ュ悗鍙?, N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍓ф儏鍒嗘敮浜嬩欢 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鍓ф儏鍒嗘敮浜嬩欢涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'CreatorCenter.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍒涗綔娴佺▼涓庢暟鎹簱鍚屾', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'璺ㄦā寮忕粍闃熼€夋嫨')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'璺ㄦā寮忕粍闃熼€夋嫨', N'璺ㄦā寮忕粍闃熼€夋嫨', N'GAME', N'璺ㄦā寮忕粍闃熼€夋嫨 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'灞€鍐呯帺娉曚笌娌夋蹈浜や簰', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'璺ㄦā寮忕粍闃熼€夋嫨 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'璺ㄦā寮忕粍闃熼€夋嫨涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'GameRoom.aspx?reservationId=1', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'灞€鍐呮祦绋嬩笌浜や簰鑱斿姩', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鍘嗗彶鐗堟湰鏌ョ湅鍣?)
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鍘嗗彶鐗堟湰鏌ョ湅鍣?, N'鍘嗗彶鐗堟湰鏌ョ湅鍣?, N'CREATOR', N'鍘嗗彶鐗堟湰鏌ョ湅鍣?鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鍒涗綔涓庤繍钀ュ悗鍙?, N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍘嗗彶鐗堟湰鏌ョ湅鍣?鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鍘嗗彶鐗堟湰鏌ョ湅鍣ㄤ富鐣岄潰', N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'CreatorCenter.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍒涗綔娴佺▼涓庢暟鎹簱鍚屾', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'璋滈鐢熸垚AI鍔╂墜')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'璋滈鐢熸垚AI鍔╂墜', N'璋滈鐢熸垚AI鍔╂墜', N'GAME', N'璋滈鐢熸垚AI鍔╂墜 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'灞€鍐呯帺娉曚笌娌夋蹈浜や簰', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'璋滈鐢熸垚AI鍔╂墜 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'璋滈鐢熸垚AI鍔╂墜涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'GameRoom.aspx?reservationId=1', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'灞€鍐呮祦绋嬩笌浜や簰鑱斿姩', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'璋滈閫氳繃鐜囩粺璁?)
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'璋滈閫氳繃鐜囩粺璁?, N'璋滈閫氳繃鐜囩粺璁?, N'ANALYTICS', N'璋滈閫氳繃鐜囩粺璁?鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'缁忚惀涓庢暟鎹垎鏋?, N'杩涘叆鏁版嵁鍒嗘瀽', N'Analytics.aspx', N'鏌ョ湅閽卞寘涓績', N'Wallet.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'璋滈閫氳繃鐜囩粺璁?鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'璋滈閫氳繃鐜囩粺璁′富鐣岄潰', N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鏁版嵁鍒嗘瀽', N'Analytics.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅閽卞寘涓績', N'Wallet.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'Analytics.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'缁熻缁撴灉涓庣粡钀ュ喅绛?, N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅閽卞寘涓績', N'Wallet.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鑳藉姏鍊艰鎯?)
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鑳藉姏鍊艰鎯?, N'鑳藉姏鍊艰鎯?, N'PLAYER', N'鑳藉姏鍊艰鎯?鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鐜╁鎴愰暱涓庤韩浠界郴缁?, N'杩涘叆鐜╁涓績', N'PlayerHub.aspx', N'鏌ョ湅鍙戠幇涓績', N'Discover.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鑳藉姏鍊艰鎯?鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鑳藉姏鍊艰鎯呬富鐣岄潰', N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鐜╁涓績', N'PlayerHub.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍙戠幇涓績', N'Discover.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'PlayerHub.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鎴愰暱鐢诲儚涓庢垚灏辨矇娣€', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍙戠幇涓績', N'Discover.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鏅€氱帺瀹舵。妗?)
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鏅€氱帺瀹舵。妗?, N'鏅€氱帺瀹舵。妗?, N'PLAYER', N'鏅€氱帺瀹舵。妗?鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鐜╁鎴愰暱涓庤韩浠界郴缁?, N'杩涘叆鐜╁涓績', N'PlayerHub.aspx', N'鏌ョ湅鍙戠幇涓績', N'Discover.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鏅€氱帺瀹舵。妗?鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鏅€氱帺瀹舵。妗堜富鐣岄潰', N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鐜╁涓績', N'PlayerHub.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍙戠幇涓績', N'Discover.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'PlayerHub.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鎴愰暱鐢诲儚涓庢垚灏辨矇娣€', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍙戠幇涓績', N'Discover.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'绀惧尯瀹℃牳涓庤瘎鍒?)
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'绀惧尯瀹℃牳涓庤瘎鍒?, N'绀惧尯瀹℃牳涓庤瘎鍒?, N'DISCOVER', N'绀惧尯瀹℃牳涓庤瘎鍒?鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鎺ㄨ崘涓庡钩鍙版湇鍔?, N'杩涘叆鍙戠幇涓績', N'Discover.aspx', N'娴忚鍓ф湰搴?, N'ScriptsList.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'绀惧尯瀹℃牳涓庤瘎鍒?鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'绀惧尯瀹℃牳涓庤瘎鍒嗕富鐣岄潰', N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鍙戠幇涓績', N'Discover.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'娴忚鍓ф湰搴?, N'ScriptsList.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'Discover.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鎺ㄨ崘鍐呭涓庢湇鍔￠厤缃?, N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'娴忚鍓ф湰搴?, N'ScriptsList.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'韬唤閫夋嫨')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'韬唤閫夋嫨', N'韬唤閫夋嫨', N'PLAYER', N'韬唤閫夋嫨 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鐜╁鎴愰暱涓庤韩浠界郴缁?, N'杩涘叆鐜╁涓績', N'PlayerHub.aspx', N'鏌ョ湅鍙戠幇涓績', N'Discover.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'韬唤閫夋嫨 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'韬唤閫夋嫨涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鐜╁涓績', N'PlayerHub.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍙戠幇涓績', N'Discover.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'PlayerHub.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鎴愰暱鐢诲儚涓庢垚灏辨矇娣€', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍙戠幇涓績', N'Discover.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'瀹炴椂鍗忎綔闈㈡澘')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'瀹炴椂鍗忎綔闈㈡澘', N'瀹炴椂鍗忎綔闈㈡澘', N'CREATOR', N'瀹炴椂鍗忎綔闈㈡澘 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鍒涗綔涓庤繍钀ュ悗鍙?, N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'瀹炴椂鍗忎綔闈㈡澘 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'瀹炴椂鍗忎綔闈㈡澘涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鍒涗綔鑰呬腑蹇?, N'CreatorCenter.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'CreatorCenter.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鍒涗綔娴佺▼涓庢暟鎹簱鍚屾', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅瀹℃牳鍚庡彴', N'AdminReview.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鏀剁泭璁剧疆')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鏀剁泭璁剧疆', N'鏀剁泭璁剧疆', N'ANALYTICS', N'鏀剁泭璁剧疆 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'缁忚惀涓庢暟鎹垎鏋?, N'杩涘叆鏁版嵁鍒嗘瀽', N'Analytics.aspx', N'鏌ョ湅閽卞寘涓績', N'Wallet.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鏀剁泭璁剧疆 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鏀剁泭璁剧疆涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鏁版嵁鍒嗘瀽', N'Analytics.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅閽卞寘涓績', N'Wallet.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'Analytics.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'缁熻缁撴灉涓庣粡钀ュ喅绛?, N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅閽卞寘涓績', N'Wallet.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鏁版嵁鍒嗘瀽鐪嬫澘')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鏁版嵁鍒嗘瀽鐪嬫澘', N'鏁版嵁鍒嗘瀽鐪嬫澘', N'ANALYTICS', N'鏁版嵁鍒嗘瀽鐪嬫澘 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'缁忚惀涓庢暟鎹垎鏋?, N'杩涘叆鏁版嵁鍒嗘瀽', N'Analytics.aspx', N'鏌ョ湅閽卞寘涓績', N'Wallet.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鏁版嵁鍒嗘瀽鐪嬫澘 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鏁版嵁鍒嗘瀽鐪嬫澘涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鏁版嵁鍒嗘瀽', N'Analytics.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅閽卞寘涓績', N'Wallet.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'Analytics.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'缁熻缁撴灉涓庣粡钀ュ喅绛?, N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅閽卞寘涓績', N'Wallet.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鐜╁琛屼负鐑姏鍥?)
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鐜╁琛屼负鐑姏鍥?, N'鐜╁琛屼负鐑姏鍥?, N'ANALYTICS', N'鐜╁琛屼负鐑姏鍥?鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'缁忚惀涓庢暟鎹垎鏋?, N'杩涘叆鏁版嵁鍒嗘瀽', N'Analytics.aspx', N'鏌ョ湅閽卞寘涓績', N'Wallet.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鐜╁琛屼负鐑姏鍥?鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鐜╁琛屼负鐑姏鍥句富鐣岄潰', N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鏁版嵁鍒嗘瀽', N'Analytics.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅閽卞寘涓績', N'Wallet.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'Analytics.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'缁熻缁撴灉涓庣粡钀ュ喅绛?, N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅閽卞寘涓績', N'Wallet.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鐗╁搧浜や簰鐣岄潰')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鐗╁搧浜や簰鐣岄潰', N'鐗╁搧浜や簰鐣岄潰', N'GAME', N'鐗╁搧浜や簰鐣岄潰 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'灞€鍐呯帺娉曚笌娌夋蹈浜や簰', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鐗╁搧浜や簰鐣岄潰 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鐗╁搧浜や簰鐣岄潰涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'GameRoom.aspx?reservationId=1', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'灞€鍐呮祦绋嬩笌浜や簰鑱斿姩', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'绋€鏈夐亾鍏蜂氦鏄撳競鍦虹鐞?)
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'绋€鏈夐亾鍏蜂氦鏄撳競鍦虹鐞?, N'绋€鏈夐亾鍏蜂氦鏄撳競鍦虹鐞?, N'DISCOVER', N'绋€鏈夐亾鍏蜂氦鏄撳競鍦虹鐞?鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鎺ㄨ崘涓庡钩鍙版湇鍔?, N'杩涘叆鍙戠幇涓績', N'Discover.aspx', N'娴忚鍓ф湰搴?, N'ScriptsList.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'绋€鏈夐亾鍏蜂氦鏄撳競鍦虹鐞?鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'绋€鏈夐亾鍏蜂氦鏄撳競鍦虹鐞嗕富鐣岄潰', N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鍙戠幇涓績', N'Discover.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'娴忚鍓ф湰搴?, N'ScriptsList.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'Discover.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鎺ㄨ崘鍐呭涓庢湇鍔￠厤缃?, N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'娴忚鍓ф湰搴?, N'ScriptsList.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'闄愭椂鎸戞垬澶у巺')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'闄愭椂鎸戞垬澶у巺', N'闄愭椂鎸戞垬澶у巺', N'DISCOVER', N'闄愭椂鎸戞垬澶у巺 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鎺ㄨ崘涓庡钩鍙版湇鍔?, N'杩涘叆鍙戠幇涓績', N'Discover.aspx', N'娴忚鍓ф湰搴?, N'ScriptsList.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'闄愭椂鎸戞垬澶у巺 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'闄愭椂鎸戞垬澶у巺涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鍙戠幇涓績', N'Discover.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'娴忚鍓ф湰搴?, N'ScriptsList.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'Discover.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鎺ㄨ崘鍐呭涓庢湇鍔￠厤缃?, N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80', N'娴忚鍓ф湰搴?, N'ScriptsList.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'绾跨储鏉?)
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'绾跨储鏉?, N'绾跨储鏉?, N'GAME', N'绾跨储鏉?鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'灞€鍐呯帺娉曚笌娌夋蹈浜や簰', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'绾跨储鏉?鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'绾跨储鏉夸富鐣岄潰', N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'GameRoom.aspx?reservationId=1', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'灞€鍐呮祦绋嬩笌浜や簰鑱斿姩', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鏂版墜寮曞鐣岄潰')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鏂版墜寮曞鐣岄潰', N'鏂版墜寮曞鐣岄潰', N'PLAYER', N'鏂版墜寮曞鐣岄潰 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鐜╁鎴愰暱涓庤韩浠界郴缁?, N'杩涘叆鐜╁涓績', N'PlayerHub.aspx', N'鏌ョ湅鍙戠幇涓績', N'Discover.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鏂版墜寮曞鐣岄潰 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鏂版墜寮曞鐣岄潰涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鐜╁涓績', N'PlayerHub.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍙戠幇涓績', N'Discover.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'PlayerHub.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鎴愰暱鐢诲儚涓庢垚灏辨矇娣€', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍙戠幇涓績', N'Discover.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'铏氭嫙缁忔祹绠＄悊')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'铏氭嫙缁忔祹绠＄悊', N'铏氭嫙缁忔祹绠＄悊', N'ANALYTICS', N'铏氭嫙缁忔祹绠＄悊 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'缁忚惀涓庢暟鎹垎鏋?, N'杩涘叆鏁版嵁鍒嗘瀽', N'Analytics.aspx', N'鏌ョ湅閽卞寘涓績', N'Wallet.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'铏氭嫙缁忔祹绠＄悊 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'铏氭嫙缁忔祹绠＄悊涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鏁版嵁鍒嗘瀽', N'Analytics.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅閽卞寘涓績', N'Wallet.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'Analytics.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'缁熻缁撴灉涓庣粡钀ュ喅绛?, N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅閽卞寘涓績', N'Wallet.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'鐢ㄦ埛妗ｆ绠＄悊')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'鐢ㄦ埛妗ｆ绠＄悊', N'鐢ㄦ埛妗ｆ绠＄悊', N'PLAYER', N'鐢ㄦ埛妗ｆ绠＄悊 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'鐜╁鎴愰暱涓庤韩浠界郴缁?, N'杩涘叆鐜╁涓績', N'PlayerHub.aspx', N'鏌ョ湅鍙戠幇涓績', N'Discover.aspx');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鐢ㄦ埛妗ｆ绠＄悊 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'鐢ㄦ埛妗ｆ绠＄悊涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'杩涘叆鐜╁涓績', N'PlayerHub.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍙戠幇涓績', N'Discover.aspx', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'PlayerHub.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'鎴愰暱鐢诲儚涓庢垚灏辨矇娣€', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍙戠幇涓績', N'Discover.aspx', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'娓告垙璁剧疆')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'娓告垙璁剧疆', N'娓告垙璁剧疆', N'GAME', N'娓告垙璁剧疆 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'灞€鍐呯帺娉曚笌娌夋蹈浜や簰', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'娓告垙璁剧疆 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'娓告垙璁剧疆涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'GameRoom.aspx?reservationId=1', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'灞€鍐呮祦绋嬩笌浜や簰鑱斿姩', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'娓告垙棣栭〉')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'娓告垙棣栭〉', N'娓告垙棣栭〉', N'GAME', N'娓告垙棣栭〉 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'灞€鍐呯帺娉曚笌娌夋蹈浜や簰', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'娓告垙棣栭〉 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'娓告垙棣栭〉涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'GameRoom.aspx?reservationId=1', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'灞€鍐呮祦绋嬩笌浜や簰鑱斿姩', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'姝ｅ湪鐩存挱鐨勬父鎴忓垪琛?)
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'姝ｅ湪鐩存挱鐨勬父鎴忓垪琛?, N'姝ｅ湪鐩存挱鐨勬父鎴忓垪琛?, N'SPECTATOR', N'姝ｅ湪鐩存挱鐨勬父鎴忓垪琛?鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'瑙傛垬涓庣洿鎾ā鍧?, N'杩涘叆瑙傛垬涓績', N'Spectator.aspx', N'杩涘叆婕旂ず鎴块棿', N'GameRoom.aspx?reservationId=1');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'姝ｅ湪鐩存挱鐨勬父鎴忓垪琛?鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'姝ｅ湪鐩存挱鐨勬父鎴忓垪琛ㄤ富鐣岄潰', N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'杩涘叆瑙傛垬涓績', N'Spectator.aspx', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'杩涘叆婕旂ず鎴块棿', N'GameRoom.aspx?reservationId=1', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'Spectator.aspx', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'瑙傛垬浜掑姩涓庣儹搴﹁仈鍔?, N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80', N'杩涘叆婕旂ず鎴块棿', N'GameRoom.aspx?reservationId=1', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'涓撳妯″紡璁剧疆')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'涓撳妯″紡璁剧疆', N'涓撳妯″紡璁剧疆', N'GAME', N'涓撳妯″紡璁剧疆 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'灞€鍐呯帺娉曚笌娌夋蹈浜や簰', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'涓撳妯″紡璁剧疆 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'涓撳妯″紡璁剧疆涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'GameRoom.aspx?reservationId=1', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'灞€鍐呮祦绋嬩笌浜や簰鑱斿姩', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍙寔缁墿灞?, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ShowcasePages WHERE PageKey = N'缁勯槦澶у巺')
BEGIN
    DECLARE @ShowcasePageId INT;
    DECLARE @SectionOneId INT;
    DECLARE @SectionTwoId INT;
    INSERT INTO dbo.ShowcasePages(PageKey, PageName, Eyebrow, HeroTitle, HeroSummary, HeroDescription, BadgeText, PrimaryActionText, PrimaryActionUrl, SecondaryActionText, SecondaryActionUrl)
    VALUES(N'缁勯槦澶у巺', N'缁勯槦澶у巺', N'GAME', N'缁勯槦澶у巺 鍔ㄦ€佹ā鍧?, N'鍥寸粫锛岄€傚悎鐢ㄤ簬姣曚笟璁捐涓殑鍔熻兘璇存槑銆佺晫闈㈡紨绀哄拰绯荤粺鑱斿姩灞曠ず銆?, N'璇ラ〉闈㈢殑鏍囬銆佺粺璁℃暟瀛椼€佸姛鑳藉崱鐗囥€佸叆鍙ｆ寜閽拰璇存槑鏂囧瓧鍧囦粠鏁版嵁搴撹鍙栵紝骞跺拰鐜版湁鐨勫彂鐜颁腑蹇冦€佺帺瀹朵腑蹇冦€佹父鎴忔埧闂淬€佸垱浣滆€呬腑蹇冩垨鏁版嵁鍒嗘瀽妯″潡褰㈡垚璺宠浆鑱斿姩銆?, N'灞€鍐呯帺娉曚笌娌夋蹈浜や簰', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1');
    SET @ShowcasePageId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseStats(ShowcasePageId, StatLabel, StatValue, SortOrder) VALUES
    (@ShowcasePageId, N'鍘熷瀷鏄犲皠', N'100%', 1),
    (@ShowcasePageId, N'灞曠ず鍖哄潡', N'2 涓?, 2),
    (@ShowcasePageId, N'鏁版嵁搴撻┍鍔?, N'宸叉帴鍏?, 3),
    (@ShowcasePageId, N'鑱斿姩鍏ュ彛', N'2 涓?, 4);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'缁勯槦澶у巺 鏍稿績浜偣', N'浠庡師鍨嬩腑鐨勪富鍔熻兘鍖恒€佹暟鍊奸潰鏉垮拰浜や簰鍏ュ彛涓娊鍙栨牳蹇冨唴瀹癸紝浠ュ崱鐗囨柟寮忓睍绀恒€?, N'', 1);
    SET @SectionOneId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionOneId, N'缁勯槦澶у巺涓荤晫闈?, N'灞曠ず椤甸潰涓昏瑙夈€佽鏄庢枃妗堝拰鍏抽敭鍏ュ彛锛岀獊鍑哄師鍨嬩腑鐨勬牳蹇冨姛鑳姐€?, N'涓荤晫闈?, N'鍔ㄦ€佹爣棰樹笌璇存槑', N'鎸夐挳鍏ュ彛鏉ヨ嚜鏁版嵁搴?, N'閫傚悎棣栭〉鎴栫瓟杈╂紨绀?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆娓告垙鎴块棿', N'GameRoom.aspx?reservationId=1', N'鏍稿績鍏ュ彛', 1),
    (@SectionOneId, N'閰嶇疆涓庢暟鍊奸潰鏉?, N'鎶婂師鍨嬩腑鐨勬ā寮忚缃€佺姸鎬佹爣璇嗐€佹暟鍊间俊鎭敼鎴愬彲閰嶇疆鐨勬暟鎹崱鐗囥€?, N'鏁版嵁鍗＄墖', N'鏍囩涓庢弿杩板姩鎬佽鍙?, N'鏀寔鎵╁睍鏇村瀛楁', N'閫傚悎浣滀负绠＄悊鍚庡彴鎴栫帺娉曢潰鏉?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍔ㄦ€侀厤缃?, 2),
    (@SectionOneId, N'鑱斿姩鍔熻兘鍏ュ彛', N'褰撳墠椤甸潰鍙笌鍙戠幇銆佺帺瀹躲€佹埧闂淬€佸垱浣溿€佽鎴樺拰鍒嗘瀽妯″潡鑱斿姩璺宠浆銆?, N'绯荤粺鑱斿姩', N'璺ㄩ〉闈㈡祦绋嬩覆鑱?, N'閫傚悎灞曠ず瀹屾暣涓氬姟閾捐矾', N'涓嶅啀鏄绔嬮潤鎬侀〉闈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鑱斿姩鍏ュ彛', N'GameRoom.aspx?reservationId=1', N'瀹屾暣閾捐矾', 3);
    INSERT INTO dbo.ShowcaseSections(ShowcasePageId, SectionTitle, SectionSummary, LayoutCode, SortOrder)
    VALUES(@ShowcasePageId, N'灞€鍐呮祦绋嬩笌浜や簰鑱斿姩', N'灞曠ず璇ュ姛鑳介〉鍦ㄦ暣涓墽鏈潃绯荤粺涓殑鏁版嵁搴撴潵婧愩€佹紨绀轰环鍊煎拰涓氬姟涓茶仈鏂瑰紡銆?, N'alt', 2);
    SET @SectionTwoId = SCOPE_IDENTITY();
    INSERT INTO dbo.ShowcaseEntries(ShowcaseSectionId, Title, Summary, TagText, MetaPrimary, MetaSecondary, MetaTertiary, ImageUrl, ActionText, ActionUrl, AccentValue, SortOrder) VALUES
    (@SectionTwoId, N'鏁版嵁搴撴潵婧愯鏄?, N'椤甸潰鍐呭缁熶竴瀛樻斁鍦?ShowcasePages銆丼howcaseSections銆丼howcaseEntries 鍜?ShowcaseStats 琛ㄤ腑銆?, N'鏁版嵁婧?, N'鍏ㄩ儴璇诲彇鏁版嵁搴?, N'閫傚悎姣曚笟璁捐绛旇京璇存槑', N'鍙户缁墿灞曞瓧娈?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'鏌ョ湅鍓ф湰搴?, N'ScriptsList.aspx', N'缁撴瀯娓呮櫚', 1),
    (@SectionTwoId, N'婕旂ず鍦烘櫙寤鸿', N'鎺ㄨ崘鎶婏紝绐佸嚭椤甸潰鍔ㄦ€佸寲涓庣郴缁熷畬鏁存€с€?, N'绛旇京婕旂ず', N'鏀寔鍗曢〉鎵撳紑', N'鏀寔鍏ㄧ珯鑱斿姩', N'鏀寔缁х画缇庡寲涓庢墿灞?, N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩斿洖棣栭〉', N'Default.aspx', N'閫傚悎姹囨姤', 2),
    (@SectionTwoId, N'鍚庣画鎵╁睍鏂瑰悜', N'鍙互缁х画鎺ュ叆鏇寸粏鐨勪笟鍔¤〃锛屼緥濡備换鍔¤褰曘€佽繍钀ラ厤缃€佺増鏈棩蹇椼€佸鏍哥粨鏋滄垨瀹炴椂鍗忎綔鏁版嵁銆?, N'鎵╁睍鎬?, N'鍏煎鍚庣画杩唬', N'渚夸簬琛ヨ鏂囦笌鏁版嵁搴撹璁?, N'閫傚悎闀挎湡瀹屽杽', N'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80', N'杩涘叆缁勯槦澶у巺', N'GameLobby.aspx?reservationId=1', N'鍙寔缁墿灞?, 3);
END
GO


IF EXISTS (SELECT 1 FROM dbo.Scripts WHERE Id = 9)
   AND NOT EXISTS (SELECT 1 FROM dbo.ScriptClues WHERE ScriptId = 9)
BEGIN
    INSERT INTO dbo.ScriptClues(ScriptId, StageId, Title, Summary, Detail, ClueType, IsPublic, SortOrder)
    VALUES
    (9, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'opening'), N'观景室习惯记录', N'顾远山几乎每天晚上十点都会独自在观景室饮茶。', N'前台备注显示，死者习惯在十点独处、反锁房门并整理旧文件，这让“密室”更像是他自己形成的。', N'习惯', 1, 1),
    (9, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'investigation'), N'苦味红茶', N'茶杯残液苦味明显高于平时。', N'顾远山一向会先加蜂蜜再喝茶，但案发当晚蜂蜜罐未被动过，说明他是情绪紧张下直接饮茶，中毒时间因此提前。', N'物证', 1, 2),
    (9, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'investigation'), N'被撕掉标签的药瓶', N'维修间里有一个残留“附子”字样的空药瓶。', N'药瓶并不属于维修工具，说明真正接触过毒物的人试图将怀疑引向熟悉电路和锁具的人。', N'药物', 0, 3),
    (9, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'deduction'), N'前台辞退通知', N'书房抽屉内有一份未签字的辞退通知。', N'辞退通知写的是许青禾的名字，说明她和死者在案发当晚存在明显冲突，也解释了她为何会提前布置报复。', N'档案', 1, 4),
    (9, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'deduction'), N'雨夜旧照片', N'一张被撕下来的旧照片重新出现，画面中有码头争执的身影。', N'照片拍到八年前许明与顾远山在雨夜码头拉扯，这是还原旧案的重要旁证。', N'照片', 0, 5),
    (9, (SELECT Id FROM dbo.GameStages WHERE StageKey = N'ending'), N'毒茶与旧案的交点', N'真正的关键不是密室，而是延时投毒与旧案掩盖。', N'许青禾掌握死者作息、能接触保温壶，也终于确认哥哥许明之死与顾远山有关，因此选择在今晚完成复仇。', N'复盘', 1, 6);
END
GO

