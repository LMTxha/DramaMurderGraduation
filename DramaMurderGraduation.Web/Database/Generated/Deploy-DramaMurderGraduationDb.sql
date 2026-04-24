:setvar DatabaseName "DramaMurderGraduationDb"
:on error exit

USE [master];
GO

IF DB_ID(N'$(DatabaseName)') IS NULL
BEGIN
    CREATE DATABASE [$(DatabaseName)];
END
GO

USE [$(DatabaseName)];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

-- Generated from the current LocalDB schema
-- Source script: Tools/Generate-DatabaseDeployment.ps1

IF OBJECT_ID(N'[dbo].[Achievements]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Achievements]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [UserId] int NOT NULL,
        [Title] nvarchar(80) NOT NULL,
        [Description] nvarchar(200) NOT NULL,
        [RarityTag] nvarchar(30) NOT NULL,
        [ProgressValue] int NOT NULL,
        [ProgressTotal] int NOT NULL,
        [EarnedAt] datetime NULL,
        [SortOrder] int NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Achievem__3214EC0791B8E509')
BEGIN
    ALTER TABLE [dbo].[Achievements] ADD CONSTRAINT [PK__Achievem__3214EC0791B8E509] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[AdminReplyLogs]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[AdminReplyLogs]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [BusinessType] nvarchar(30) NOT NULL,
        [BusinessId] int NOT NULL,
        [AdminUserId] int NULL,
        [ReplyContent] nvarchar(500) NOT NULL,
        [VisibleToUser] bit NOT NULL,
        [CreatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_AdminReplyLogs_VisibleToUser')
BEGIN
    ALTER TABLE [dbo].[AdminReplyLogs] ADD CONSTRAINT [DF_AdminReplyLogs_VisibleToUser] DEFAULT ((1)) FOR [VisibleToUser];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_AdminReplyLogs_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[AdminReplyLogs] ADD CONSTRAINT [DF_AdminReplyLogs_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__AdminRep__3214EC07583C4C2A')
BEGIN
    ALTER TABLE [dbo].[AdminReplyLogs] ADD CONSTRAINT [PK__AdminRep__3214EC07583C4C2A] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[AfterSaleRequests]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[AfterSaleRequests]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [ReservationId] int NOT NULL,
        [UserId] int NOT NULL,
        [RequestType] nvarchar(30) NOT NULL,
        [Reason] nvarchar(500) NOT NULL,
        [RequestedAmount] decimal(10,2) NULL,
        [Status] nvarchar(30) NOT NULL,
        [AdminReply] nvarchar(500) NULL,
        [AdminRemark] nvarchar(300) NULL,
        [ProcessedByUserId] int NULL,
        [ProcessedAt] datetime NULL,
        [RefundTransactionId] int NULL,
        [RefundedAmount] decimal(10,2) NULL,
        [CreatedAt] datetime NOT NULL,
        [EvidenceUrl] nvarchar(500) NULL,
        [RejectReason] nvarchar(500) NULL,
        [AppealReason] nvarchar(500) NULL,
        [AcceptedAt] datetime NULL,
        [RejectedAt] datetime NULL,
        [AppealedAt] datetime NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_AfterSaleRequests_Status')
BEGIN
    ALTER TABLE [dbo].[AfterSaleRequests] ADD CONSTRAINT [DF_AfterSaleRequests_Status] DEFAULT (N'待处理') FOR [Status];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_AfterSaleRequests_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[AfterSaleRequests] ADD CONSTRAINT [DF_AfterSaleRequests_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__AfterSal__3214EC0731EE32C5')
BEGIN
    ALTER TABLE [dbo].[AfterSaleRequests] ADD CONSTRAINT [PK__AfterSal__3214EC0731EE32C5] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[AnalyticsSnapshots]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[AnalyticsSnapshots]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [SnapshotDate] datetime NOT NULL,
        [ActiveUsers] int NOT NULL,
        [AverageSessionMinutes] decimal(10,2) NOT NULL,
        [TotalBookings] int NOT NULL,
        [RevenueAmount] decimal(12,2) NOT NULL,
        [ConversionRate] decimal(5,2) NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Analytic__3214EC07AAFB897D')
BEGIN
    ALTER TABLE [dbo].[AnalyticsSnapshots] ADD CONSTRAINT [PK__Analytic__3214EC07AAFB897D] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[Announcements]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Announcements]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Title] nvarchar(120) NOT NULL,
        [Summary] nvarchar(300) NOT NULL,
        [PublishDate] date NOT NULL,
        [IsImportant] bit NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF__Announcem__IsImp__4BAC3F29')
BEGIN
    ALTER TABLE [dbo].[Announcements] ADD CONSTRAINT [DF__Announcem__IsImp__4BAC3F29] DEFAULT ((0)) FOR [IsImportant];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Announce__3214EC07365B0381')
BEGIN
    ALTER TABLE [dbo].[Announcements] ADD CONSTRAINT [PK__Announce__3214EC07365B0381] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[BusinessActionLogs]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[BusinessActionLogs]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [BusinessType] nvarchar(30) NOT NULL,
        [BusinessId] int NOT NULL,
        [ActionType] nvarchar(50) NOT NULL,
        [ActionTitle] nvarchar(100) NOT NULL,
        [ActionContent] nvarchar(500) NULL,
        [OperatorUserId] int NULL,
        [CreatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_BusinessActionLogs_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[BusinessActionLogs] ADD CONSTRAINT [DF_BusinessActionLogs_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Business__3214EC0788573CD1')
BEGIN
    ALTER TABLE [dbo].[BusinessActionLogs] ADD CONSTRAINT [PK__Business__3214EC0788573CD1] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[Challenges]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Challenges]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Title] nvarchar(100) NOT NULL,
        [Description] nvarchar(240) NOT NULL,
        [CoverImage] nvarchar(300) NOT NULL,
        [EndTime] datetime NOT NULL,
        [RewardSummary] nvarchar(200) NOT NULL,
        [StatusTag] nvarchar(40) NOT NULL,
        [RouteUrl] nvarchar(200) NOT NULL,
        [SortOrder] int NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Challeng__3214EC07CEDB280F')
BEGIN
    ALTER TABLE [dbo].[Challenges] ADD CONSTRAINT [PK__Challeng__3214EC07CEDB280F] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[ChatGroupMembers]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ChatGroupMembers]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [GroupId] int NOT NULL,
        [UserId] int NOT NULL,
        [DisplayOrder] int NOT NULL,
        [JoinedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_ChatGroupMembers_DisplayOrder')
BEGIN
    ALTER TABLE [dbo].[ChatGroupMembers] ADD CONSTRAINT [DF_ChatGroupMembers_DisplayOrder] DEFAULT ((0)) FOR [DisplayOrder];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_ChatGroupMembers_JoinedAt')
BEGIN
    ALTER TABLE [dbo].[ChatGroupMembers] ADD CONSTRAINT [DF_ChatGroupMembers_JoinedAt] DEFAULT (getdate()) FOR [JoinedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__ChatGrou__3214EC07946ACC1B')
BEGIN
    ALTER TABLE [dbo].[ChatGroupMembers] ADD CONSTRAINT [PK__ChatGrou__3214EC07946ACC1B] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[ChatGroups]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ChatGroups]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Name] nvarchar(80) NOT NULL,
        [OwnerUserId] int NOT NULL,
        [AvatarUrl] nvarchar(300) NULL,
        [Announcement] nvarchar(200) NULL,
        [CreatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_ChatGroups_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[ChatGroups] ADD CONSTRAINT [DF_ChatGroups_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__ChatGrou__3214EC0793405AA2')
BEGIN
    ALTER TABLE [dbo].[ChatGroups] ADD CONSTRAINT [PK__ChatGrou__3214EC0793405AA2] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[CompletionInsights]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[CompletionInsights]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [MetricType] nvarchar(40) NOT NULL,
        [Name] nvarchar(80) NOT NULL,
        [ValueDecimal] decimal(10,2) NOT NULL,
        [Summary] nvarchar(200) NOT NULL,
        [SortOrder] int NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Completi__3214EC0779F69BDB')
BEGIN
    ALTER TABLE [dbo].[CompletionInsights] ADD CONSTRAINT [PK__Completi__3214EC0779F69BDB] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[DownloadOptions]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[DownloadOptions]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [PlatformName] nvarchar(40) NOT NULL,
        [PlatformCode] nvarchar(40) NOT NULL,
        [IconText] nvarchar(20) NOT NULL,
        [VersionText] nvarchar(80) NOT NULL,
        [Summary] nvarchar(200) NOT NULL,
        [DownloadUrl] nvarchar(500) NOT NULL,
        [ReleaseDate] datetime NOT NULL,
        [SortOrder] int NOT NULL,
        [IsActive] bit NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_DownloadOptions_SortOrder')
BEGIN
    ALTER TABLE [dbo].[DownloadOptions] ADD CONSTRAINT [DF_DownloadOptions_SortOrder] DEFAULT ((0)) FOR [SortOrder];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_DownloadOptions_IsActive')
BEGIN
    ALTER TABLE [dbo].[DownloadOptions] ADD CONSTRAINT [DF_DownloadOptions_IsActive] DEFAULT ((1)) FOR [IsActive];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Download__3214EC07FC322351')
BEGIN
    ALTER TABLE [dbo].[DownloadOptions] ADD CONSTRAINT [PK__Download__3214EC07FC322351] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[EconomyInsights]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[EconomyInsights]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [CategoryName] nvarchar(60) NOT NULL,
        [MetricName] nvarchar(80) NOT NULL,
        [MetricValue] decimal(12,2) NOT NULL,
        [TrendText] nvarchar(100) NOT NULL,
        [SortOrder] int NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__EconomyI__3214EC07FFF0C8B5')
BEGIN
    ALTER TABLE [dbo].[EconomyInsights] ADD CONSTRAINT [PK__EconomyI__3214EC07FFF0C8B5] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[FriendConversationPreferences]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[FriendConversationPreferences]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [UserId] int NOT NULL,
        [FriendUserId] int NOT NULL,
        [IsPinned] bit NOT NULL,
        [IsHidden] bit NOT NULL,
        [CreatedAt] datetime NOT NULL,
        [UpdatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_FriendConversationPreferences_IsPinned')
BEGIN
    ALTER TABLE [dbo].[FriendConversationPreferences] ADD CONSTRAINT [DF_FriendConversationPreferences_IsPinned] DEFAULT ((0)) FOR [IsPinned];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_FriendConversationPreferences_IsHidden')
BEGIN
    ALTER TABLE [dbo].[FriendConversationPreferences] ADD CONSTRAINT [DF_FriendConversationPreferences_IsHidden] DEFAULT ((0)) FOR [IsHidden];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_FriendConversationPreferences_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[FriendConversationPreferences] ADD CONSTRAINT [DF_FriendConversationPreferences_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_FriendConversationPreferences_UpdatedAt')
BEGIN
    ALTER TABLE [dbo].[FriendConversationPreferences] ADD CONSTRAINT [DF_FriendConversationPreferences_UpdatedAt] DEFAULT (getdate()) FOR [UpdatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__FriendCo__3214EC075C527534')
BEGIN
    ALTER TABLE [dbo].[FriendConversationPreferences] ADD CONSTRAINT [PK__FriendCo__3214EC075C527534] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[FriendMessages]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[FriendMessages]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [SenderUserId] int NOT NULL,
        [ReceiverUserId] int NOT NULL,
        [MessageType] nvarchar(20) NOT NULL,
        [Content] nvarchar(400) NULL,
        [AttachmentUrl] nvarchar(300) NULL,
        [LocationText] nvarchar(120) NULL,
        [CreatedAt] datetime NOT NULL,
        [IsRead] bit NOT NULL,
        [IsRevoked] bit NOT NULL,
        [RevokedAt] datetime NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_FriendMessages_MessageType')
BEGIN
    ALTER TABLE [dbo].[FriendMessages] ADD CONSTRAINT [DF_FriendMessages_MessageType] DEFAULT (N'Text') FOR [MessageType];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_FriendMessages_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[FriendMessages] ADD CONSTRAINT [DF_FriendMessages_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_FriendMessages_IsRead')
BEGIN
    ALTER TABLE [dbo].[FriendMessages] ADD CONSTRAINT [DF_FriendMessages_IsRead] DEFAULT ((0)) FOR [IsRead];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_FriendMessages_IsRevoked')
BEGIN
    ALTER TABLE [dbo].[FriendMessages] ADD CONSTRAINT [DF_FriendMessages_IsRevoked] DEFAULT ((0)) FOR [IsRevoked];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__FriendMe__3214EC07A2E6D4E6')
BEGIN
    ALTER TABLE [dbo].[FriendMessages] ADD CONSTRAINT [PK__FriendMe__3214EC07A2E6D4E6] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[FriendMoments]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[FriendMoments]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [UserId] int NOT NULL,
        [Content] nvarchar(600) NULL,
        [ImageUrl] nvarchar(300) NULL,
        [LocationText] nvarchar(120) NULL,
        [Visibility] nvarchar(20) NOT NULL,
        [CreatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_FriendMoments_Visibility')
BEGIN
    ALTER TABLE [dbo].[FriendMoments] ADD CONSTRAINT [DF_FriendMoments_Visibility] DEFAULT (N'Friends') FOR [Visibility];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_FriendMoments_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[FriendMoments] ADD CONSTRAINT [DF_FriendMoments_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__FriendMo__3214EC0735B176D2')
BEGIN
    ALTER TABLE [dbo].[FriendMoments] ADD CONSTRAINT [PK__FriendMo__3214EC0735B176D2] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[FriendMoneyTransfers]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[FriendMoneyTransfers]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [SenderUserId] int NOT NULL,
        [ReceiverUserId] int NOT NULL,
        [TransferType] nvarchar(20) NOT NULL,
        [Amount] decimal(10,2) NOT NULL,
        [Note] nvarchar(200) NULL,
        [CreatedAt] datetime NOT NULL,
        [MessageId] int NULL,
        [Status] nvarchar(20) NOT NULL,
        [ClaimedAt] datetime NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_FriendMoneyTransfers_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[FriendMoneyTransfers] ADD CONSTRAINT [DF_FriendMoneyTransfers_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_FriendMoneyTransfers_Status')
BEGIN
    ALTER TABLE [dbo].[FriendMoneyTransfers] ADD CONSTRAINT [DF_FriendMoneyTransfers_Status] DEFAULT (N'Claimed') FOR [Status];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__FriendMo__3214EC07C692E05F')
BEGIN
    ALTER TABLE [dbo].[FriendMoneyTransfers] ADD CONSTRAINT [PK__FriendMo__3214EC07C692E05F] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[FriendRequests]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[FriendRequests]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [SenderUserId] int NOT NULL,
        [ReceiverUserId] int NOT NULL,
        [RequestMessage] nvarchar(200) NULL,
        [Status] nvarchar(20) NOT NULL,
        [CreatedAt] datetime NOT NULL,
        [ReviewedAt] datetime NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_FriendRequests_Status')
BEGIN
    ALTER TABLE [dbo].[FriendRequests] ADD CONSTRAINT [DF_FriendRequests_Status] DEFAULT (N'Pending') FOR [Status];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_FriendRequests_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[FriendRequests] ADD CONSTRAINT [DF_FriendRequests_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__FriendRe__3214EC0756D8A444')
BEGIN
    ALTER TABLE [dbo].[FriendRequests] ADD CONSTRAINT [PK__FriendRe__3214EC0756D8A444] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[Friendships]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Friendships]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [UserId] int NOT NULL,
        [FriendUserId] int NOT NULL,
        [CreatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_Friendships_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[Friendships] ADD CONSTRAINT [DF_Friendships_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Friendsh__3214EC07002C1010')
BEGIN
    ALTER TABLE [dbo].[Friendships] ADD CONSTRAINT [PK__Friendsh__3214EC07002C1010] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[GameStages]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[GameStages]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [StageKey] nvarchar(30) NOT NULL,
        [StageName] nvarchar(60) NOT NULL,
        [StageDescription] nvarchar(300) NOT NULL,
        [SortOrder] int NOT NULL,
        [DurationMinutes] int NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__GameStag__3214EC07029C37A4')
BEGIN
    ALTER TABLE [dbo].[GameStages] ADD CONSTRAINT [PK__GameStag__3214EC07029C37A4] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[Genres]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Genres]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Name] nvarchar(50) NOT NULL,
        [Description] nvarchar(200) NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Genres__3214EC073053465C')
BEGIN
    ALTER TABLE [dbo].[Genres] ADD CONSTRAINT [PK__Genres__3214EC073053465C] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[GiftCatalog]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[GiftCatalog]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Name] nvarchar(50) NOT NULL,
        [PriceInCoins] int NOT NULL,
        [IconText] nvarchar(20) NOT NULL,
        [Summary] nvarchar(200) NULL,
        [SortOrder] int NOT NULL,
        [IsActive] bit NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_GiftCatalog_SortOrder')
BEGIN
    ALTER TABLE [dbo].[GiftCatalog] ADD CONSTRAINT [DF_GiftCatalog_SortOrder] DEFAULT ((0)) FOR [SortOrder];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_GiftCatalog_IsActive')
BEGIN
    ALTER TABLE [dbo].[GiftCatalog] ADD CONSTRAINT [DF_GiftCatalog_IsActive] DEFAULT ((1)) FOR [IsActive];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__GiftCata__3214EC07E15F6D36')
BEGIN
    ALTER TABLE [dbo].[GiftCatalog] ADD CONSTRAINT [PK__GiftCata__3214EC07E15F6D36] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[GiftTransactions]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[GiftTransactions]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [SenderUserId] int NOT NULL,
        [ReceiverUserId] int NOT NULL,
        [GiftId] int NOT NULL,
        [Quantity] int NOT NULL,
        [UnitPrice] int NOT NULL,
        [TotalCoins] int NOT NULL,
        [Summary] nvarchar(200) NULL,
        [CreatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_GiftTransactions_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[GiftTransactions] ADD CONSTRAINT [DF_GiftTransactions_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__GiftTran__3214EC0791998817')
BEGIN
    ALTER TABLE [dbo].[GiftTransactions] ADD CONSTRAINT [PK__GiftTran__3214EC0791998817] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[GiftWalletTransactions]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[GiftWalletTransactions]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [UserId] int NOT NULL,
        [TransactionType] nvarchar(30) NOT NULL,
        [CoinAmount] int NOT NULL,
        [BalanceAfter] int NOT NULL,
        [Summary] nvarchar(200) NULL,
        [CreatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_GiftWalletTransactions_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[GiftWalletTransactions] ADD CONSTRAINT [DF_GiftWalletTransactions_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__GiftWall__3214EC07FF674E7F')
BEGIN
    ALTER TABLE [dbo].[GiftWalletTransactions] ADD CONSTRAINT [PK__GiftWall__3214EC07FF674E7F] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[GroupConversationPreferences]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[GroupConversationPreferences]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [UserId] int NOT NULL,
        [GroupId] int NOT NULL,
        [IsPinned] bit NOT NULL,
        [IsHidden] bit NOT NULL,
        [IsMuted] bit NOT NULL,
        [LastReadGroupMessageId] int NULL,
        [CreatedAt] datetime NOT NULL,
        [UpdatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_GroupConversationPreferences_IsPinned')
BEGIN
    ALTER TABLE [dbo].[GroupConversationPreferences] ADD CONSTRAINT [DF_GroupConversationPreferences_IsPinned] DEFAULT ((0)) FOR [IsPinned];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_GroupConversationPreferences_IsHidden')
BEGIN
    ALTER TABLE [dbo].[GroupConversationPreferences] ADD CONSTRAINT [DF_GroupConversationPreferences_IsHidden] DEFAULT ((0)) FOR [IsHidden];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_GroupConversationPreferences_IsMuted')
BEGIN
    ALTER TABLE [dbo].[GroupConversationPreferences] ADD CONSTRAINT [DF_GroupConversationPreferences_IsMuted] DEFAULT ((0)) FOR [IsMuted];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_GroupConversationPreferences_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[GroupConversationPreferences] ADD CONSTRAINT [DF_GroupConversationPreferences_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_GroupConversationPreferences_UpdatedAt')
BEGIN
    ALTER TABLE [dbo].[GroupConversationPreferences] ADD CONSTRAINT [DF_GroupConversationPreferences_UpdatedAt] DEFAULT (getdate()) FOR [UpdatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__GroupCon__3214EC076C046502')
BEGIN
    ALTER TABLE [dbo].[GroupConversationPreferences] ADD CONSTRAINT [PK__GroupCon__3214EC076C046502] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[GroupMessages]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[GroupMessages]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [GroupId] int NOT NULL,
        [SenderUserId] int NOT NULL,
        [MessageType] nvarchar(20) NOT NULL,
        [Content] nvarchar(500) NULL,
        [AttachmentUrl] nvarchar(300) NULL,
        [LocationText] nvarchar(120) NULL,
        [IsRevoked] bit NOT NULL,
        [RevokedAt] datetime NULL,
        [CreatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_GroupMessages_MessageType')
BEGIN
    ALTER TABLE [dbo].[GroupMessages] ADD CONSTRAINT [DF_GroupMessages_MessageType] DEFAULT (N'Text') FOR [MessageType];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_GroupMessages_IsRevoked')
BEGIN
    ALTER TABLE [dbo].[GroupMessages] ADD CONSTRAINT [DF_GroupMessages_IsRevoked] DEFAULT ((0)) FOR [IsRevoked];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_GroupMessages_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[GroupMessages] ADD CONSTRAINT [DF_GroupMessages_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__GroupMes__3214EC076E3CBA88')
BEGIN
    ALTER TABLE [dbo].[GroupMessages] ADD CONSTRAINT [PK__GroupMes__3214EC076E3CBA88] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[HeatmapZones]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[HeatmapZones]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [ZoneName] nvarchar(50) NOT NULL,
        [HeatLevel] int NOT NULL,
        [PeakPeriod] nvarchar(40) NOT NULL,
        [Summary] nvarchar(200) NOT NULL,
        [SortOrder] int NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__HeatmapZ__3214EC071E062157')
BEGIN
    ALTER TABLE [dbo].[HeatmapZones] ADD CONSTRAINT [PK__HeatmapZ__3214EC071E062157] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[IdentityOptions]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[IdentityOptions]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Name] nvarchar(40) NOT NULL,
        [Description] nvarchar(200) NOT NULL,
        [AbilityFocus] nvarchar(100) NOT NULL,
        [RecommendedFor] nvarchar(100) NOT NULL,
        [SortOrder] int NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Identity__3214EC0744C0C243')
BEGIN
    ALTER TABLE [dbo].[IdentityOptions] ADD CONSTRAINT [PK__Identity__3214EC0744C0C243] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[LiveSessions]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[LiveSessions]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Title] nvarchar(100) NOT NULL,
        [Summary] nvarchar(240) NOT NULL,
        [HostName] nvarchar(50) NOT NULL,
        [ViewerCount] int NOT NULL,
        [CoverImage] nvarchar(300) NOT NULL,
        [RouteUrl] nvarchar(200) NOT NULL,
        [StatusText] nvarchar(30) NOT NULL,
        [HeatScore] int NOT NULL,
        [SortOrder] int NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__LiveSess__3214EC07D6ECEFC2')
BEGIN
    ALTER TABLE [dbo].[LiveSessions] ADD CONSTRAINT [PK__LiveSess__3214EC07D6ECEFC2] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[MembershipPlans]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[MembershipPlans]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Name] nvarchar(60) NOT NULL,
        [Price] decimal(10,2) NOT NULL,
        [BillingCycle] nvarchar(30) NOT NULL,
        [Description] nvarchar(200) NOT NULL,
        [BenefitSummary] nvarchar(300) NOT NULL,
        [HighlightText] nvarchar(40) NOT NULL,
        [SortOrder] int NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Membersh__3214EC0700F30651')
BEGIN
    ALTER TABLE [dbo].[MembershipPlans] ADD CONSTRAINT [PK__Membersh__3214EC0700F30651] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[MomentComments]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[MomentComments]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [MomentId] int NOT NULL,
        [UserId] int NOT NULL,
        [Content] nvarchar(300) NOT NULL,
        [CreatedAt] datetime NOT NULL,
        [ParentCommentId] int NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_MomentComments_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[MomentComments] ADD CONSTRAINT [DF_MomentComments_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__MomentCo__3214EC0765324F2D')
BEGIN
    ALTER TABLE [dbo].[MomentComments] ADD CONSTRAINT [PK__MomentCo__3214EC0765324F2D] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[MomentLikes]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[MomentLikes]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [MomentId] int NOT NULL,
        [UserId] int NOT NULL,
        [CreatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_MomentLikes_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[MomentLikes] ADD CONSTRAINT [DF_MomentLikes_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__MomentLi__3214EC0740AD9400')
BEGIN
    ALTER TABLE [dbo].[MomentLikes] ADD CONSTRAINT [PK__MomentLi__3214EC0740AD9400] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[PasswordResetTickets]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[PasswordResetTickets]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [UserId] int NOT NULL,
        [TicketCode] nvarchar(30) NOT NULL,
        [ExpiresAt] datetime NOT NULL,
        [IsUsed] bit NOT NULL,
        [CreatedAt] datetime NOT NULL,
        [UsedAt] datetime NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_PasswordResetTickets_IsUsed')
BEGIN
    ALTER TABLE [dbo].[PasswordResetTickets] ADD CONSTRAINT [DF_PasswordResetTickets_IsUsed] DEFAULT ((0)) FOR [IsUsed];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_PasswordResetTickets_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[PasswordResetTickets] ADD CONSTRAINT [DF_PasswordResetTickets_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Password__3214EC0717480CA2')
BEGIN
    ALTER TABLE [dbo].[PasswordResetTickets] ADD CONSTRAINT [PK__Password__3214EC0717480CA2] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[PlayerAbilities]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[PlayerAbilities]
    (
        [UserId] int NOT NULL,
        [DeductionPower] int NOT NULL,
        [ObservationPower] int NOT NULL,
        [CreativityPower] int NOT NULL,
        [CollaborationPower] int NOT NULL,
        [ExecutionPower] int NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__PlayerAb__1788CC4C9D8CA9FC')
BEGIN
    ALTER TABLE [dbo].[PlayerAbilities] ADD CONSTRAINT [PK__PlayerAb__1788CC4C9D8CA9FC] PRIMARY KEY CLUSTERED ([UserId] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[PlayerBattleRecords]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[PlayerBattleRecords]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [SessionId] int NOT NULL,
        [ReservationId] int NOT NULL,
        [UserId] int NOT NULL,
        [ScriptId] int NOT NULL,
        [ScriptName] nvarchar(100) NOT NULL,
        [RoomName] nvarchar(80) NOT NULL,
        [CharacterId] int NULL,
        [CharacterName] nvarchar(50) NOT NULL,
        [WasCorrect] bit NOT NULL,
        [ResultTag] nvarchar(30) NOT NULL,
        [VotedCharacterId] int NULL,
        [VotedCharacterName] nvarchar(50) NULL,
        [CorrectCharacterName] nvarchar(50) NOT NULL,
        [CompletedAt] datetime NOT NULL,
        [CreatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_PlayerBattleRecords_WasCorrect')
BEGIN
    ALTER TABLE [dbo].[PlayerBattleRecords] ADD CONSTRAINT [DF_PlayerBattleRecords_WasCorrect] DEFAULT ((0)) FOR [WasCorrect];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_PlayerBattleRecords_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[PlayerBattleRecords] ADD CONSTRAINT [DF_PlayerBattleRecords_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__PlayerBa__3214EC074DC00CCE')
BEGIN
    ALTER TABLE [dbo].[PlayerBattleRecords] ADD CONSTRAINT [PK__PlayerBa__3214EC074DC00CCE] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[PlayerProfiles]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[PlayerProfiles]
    (
        [UserId] int NOT NULL,
        [DisplayName] nvarchar(50) NOT NULL,
        [DisplayTitle] nvarchar(50) NOT NULL,
        [Motto] nvarchar(200) NOT NULL,
        [AvatarUrl] nvarchar(300) NOT NULL,
        [FavoriteGenre] nvarchar(50) NOT NULL,
        [JoinDays] int NOT NULL,
        [CompletedScripts] int NOT NULL,
        [WinRate] decimal(5,2) NOT NULL,
        [ReputationLevel] nvarchar(40) NOT NULL,
        [Gender] nvarchar(20) NULL,
        [Region] nvarchar(80) NULL,
        [Signature] nvarchar(200) NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__PlayerPr__1788CC4C4871272F')
BEGIN
    ALTER TABLE [dbo].[PlayerProfiles] ADD CONSTRAINT [PK__PlayerPr__1788CC4C4871272F] PRIMARY KEY CLUSTERED ([UserId] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[RechargeRequests]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[RechargeRequests]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [UserId] int NOT NULL,
        [PaymentMethod] nvarchar(20) NOT NULL,
        [Amount] decimal(10,2) NOT NULL,
        [PaymentAccount] nvarchar(80) NULL,
        [RequestStatus] nvarchar(20) NOT NULL,
        [ReviewRemark] nvarchar(200) NULL,
        [WalletTransactionId] int NULL,
        [SubmittedAt] datetime NOT NULL,
        [ReviewedAt] datetime NULL,
        [ReviewedByUserId] int NULL,
        [RechargeOrderNo] nvarchar(32) NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Recharge__3214EC072B90D79C')
BEGIN
    ALTER TABLE [dbo].[RechargeRequests] ADD CONSTRAINT [PK__Recharge__3214EC072B90D79C] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[Reservations]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Reservations]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [SessionId] int NOT NULL,
        [UserId] int NULL,
        [ContactName] nvarchar(50) NOT NULL,
        [Phone] nvarchar(30) NOT NULL,
        [PlayerCount] int NOT NULL,
        [UnitPrice] decimal(10,2) NULL,
        [TotalAmount] decimal(10,2) NULL,
        [PaymentStatus] nvarchar(30) NOT NULL,
        [PaymentTransactionId] int NULL,
        [Remark] nvarchar(400) NULL,
        [CreatedAt] datetime NOT NULL,
        [Status] nvarchar(30) NOT NULL,
        [AdminRemark] nvarchar(300) NULL,
        [AdminReply] nvarchar(500) NULL,
        [ProcessedByUserId] int NULL,
        [ProcessedAt] datetime NULL,
        [RepliedAt] datetime NULL,
        [ConfirmStatus] nvarchar(30) NULL,
        [PlayerConfirmRemark] nvarchar(300) NULL,
        [PlayerConfirmedAt] datetime NULL,
        [CouponId] int NULL,
        [DiscountAmount] decimal(10,2) NOT NULL,
        [CheckInCode] nvarchar(20) NULL,
        [CheckedInAt] datetime NULL,
        [CheckInByUserId] int NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_Reservations_PaymentStatus')
BEGIN
    ALTER TABLE [dbo].[Reservations] ADD CONSTRAINT [DF_Reservations_PaymentStatus] DEFAULT (N'绾夸笅纭') FOR [PaymentStatus];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_Reservations_DiscountAmount')
BEGIN
    ALTER TABLE [dbo].[Reservations] ADD CONSTRAINT [DF_Reservations_DiscountAmount] DEFAULT ((0)) FOR [DiscountAmount];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Reservat__3214EC0776B91539')
BEGIN
    ALTER TABLE [dbo].[Reservations] ADD CONSTRAINT [PK__Reservat__3214EC0776B91539] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[ReservationWaitlists]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ReservationWaitlists]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [SessionId] int NOT NULL,
        [UserId] int NOT NULL,
        [ContactName] nvarchar(50) NOT NULL,
        [Phone] nvarchar(30) NOT NULL,
        [PlayerCount] int NOT NULL,
        [Note] nvarchar(300) NULL,
        [Status] nvarchar(20) NOT NULL,
        [CreatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_ReservationWaitlists_Status')
BEGIN
    ALTER TABLE [dbo].[ReservationWaitlists] ADD CONSTRAINT [DF_ReservationWaitlists_Status] DEFAULT (N'Pending') FOR [Status];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_ReservationWaitlists_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[ReservationWaitlists] ADD CONSTRAINT [DF_ReservationWaitlists_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Reservat__3214EC074E05005E')
BEGIN
    ALTER TABLE [dbo].[ReservationWaitlists] ADD CONSTRAINT [PK__Reservat__3214EC074E05005E] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[Reviews]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Reviews]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [ScriptId] int NOT NULL,
        [ReviewerName] nvarchar(50) NOT NULL,
        [Rating] int NOT NULL,
        [Content] nvarchar(500) NOT NULL,
        [ReviewDate] datetime NOT NULL,
        [HighlightTag] nvarchar(50) NOT NULL,
        [UserId] int NULL,
        [ReservationId] int NULL,
        [IsFeatured] bit NOT NULL,
        [IsHidden] bit NOT NULL,
        [AdminReply] nvarchar(500) NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_Reviews_IsFeatured')
BEGIN
    ALTER TABLE [dbo].[Reviews] ADD CONSTRAINT [DF_Reviews_IsFeatured] DEFAULT ((0)) FOR [IsFeatured];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_Reviews_IsHidden')
BEGIN
    ALTER TABLE [dbo].[Reviews] ADD CONSTRAINT [DF_Reviews_IsHidden] DEFAULT ((0)) FOR [IsHidden];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Reviews__3214EC0710F8650B')
BEGIN
    ALTER TABLE [dbo].[Reviews] ADD CONSTRAINT [PK__Reviews__3214EC0710F8650B] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[RoomMessages]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[RoomMessages]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [SessionId] int NOT NULL,
        [ReservationId] int NOT NULL,
        [UserId] int NULL,
        [SenderName] nvarchar(50) NOT NULL,
        [MessageType] nvarchar(20) NOT NULL,
        [Content] nvarchar(MAX) NULL,
        [MediaData] nvarchar(MAX) NULL,
        [DurationSeconds] int NULL,
        [SentAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__RoomMess__3214EC079457F383')
BEGIN
    ALTER TABLE [dbo].[RoomMessages] ADD CONSTRAINT [PK__RoomMess__3214EC079457F383] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[RoomPresence]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[RoomPresence]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [SessionId] int NOT NULL,
        [ReservationId] int NOT NULL,
        [UserId] int NULL,
        [DisplayName] nvarchar(50) NOT NULL,
        [CameraEnabled] bit NOT NULL,
        [MicrophoneEnabled] bit NOT NULL,
        [VideoSnapshot] nvarchar(MAX) NULL,
        [UpdatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_RoomPresence_CameraEnabled')
BEGIN
    ALTER TABLE [dbo].[RoomPresence] ADD CONSTRAINT [DF_RoomPresence_CameraEnabled] DEFAULT ((0)) FOR [CameraEnabled];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_RoomPresence_MicrophoneEnabled')
BEGIN
    ALTER TABLE [dbo].[RoomPresence] ADD CONSTRAINT [DF_RoomPresence_MicrophoneEnabled] DEFAULT ((0)) FOR [MicrophoneEnabled];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__RoomPres__3214EC07441586E6')
BEGIN
    ALTER TABLE [dbo].[RoomPresence] ADD CONSTRAINT [PK__RoomPres__3214EC07441586E6] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[Rooms]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Rooms]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Name] nvarchar(80) NOT NULL,
        [Theme] nvarchar(60) NOT NULL,
        [Capacity] int NOT NULL,
        [Description] nvarchar(300) NOT NULL,
        [ImageUrl] nvarchar(300) NOT NULL,
        [Status] nvarchar(30) NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Rooms__3214EC07A568907A')
BEGIN
    ALTER TABLE [dbo].[Rooms] ADD CONSTRAINT [PK__Rooms__3214EC07A568907A] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[SchemaMigrations]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[SchemaMigrations]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [MigrationKey] nvarchar(120) NOT NULL,
        [Description] nvarchar(200) NULL,
        [ScriptChecksum] nvarchar(64) NOT NULL,
        [StartedAt] datetime NOT NULL,
        [CompletedAt] datetime NULL,
        [Succeeded] bit NOT NULL,
        [ErrorMessage] nvarchar(MAX) NULL,
        [UpdatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_SchemaMigrations_Succeeded')
BEGIN
    ALTER TABLE [dbo].[SchemaMigrations] ADD CONSTRAINT [DF_SchemaMigrations_Succeeded] DEFAULT ((0)) FOR [Succeeded];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_SchemaMigrations_UpdatedAt')
BEGIN
    ALTER TABLE [dbo].[SchemaMigrations] ADD CONSTRAINT [DF_SchemaMigrations_UpdatedAt] DEFAULT (getdate()) FOR [UpdatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__SchemaMi__3214EC07FD4EB641')
BEGIN
    ALTER TABLE [dbo].[SchemaMigrations] ADD CONSTRAINT [PK__SchemaMi__3214EC07FD4EB641] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[ScriptAssets]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ScriptAssets]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [ScriptId] int NOT NULL,
        [AssetType] nvarchar(40) NOT NULL,
        [Title] nvarchar(200) NOT NULL,
        [FileName] nvarchar(260) NOT NULL,
        [RelativePath] nvarchar(500) NOT NULL,
        [PublicUrl] nvarchar(500) NOT NULL,
        [FileExtension] nvarchar(20) NOT NULL,
        [FileSizeBytes] bigint NOT NULL,
        [IsPrimary] bit NOT NULL,
        [SortOrder] int NOT NULL,
        [CreatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_ScriptAssets_FileSizeBytes')
BEGIN
    ALTER TABLE [dbo].[ScriptAssets] ADD CONSTRAINT [DF_ScriptAssets_FileSizeBytes] DEFAULT ((0)) FOR [FileSizeBytes];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_ScriptAssets_IsPrimary')
BEGIN
    ALTER TABLE [dbo].[ScriptAssets] ADD CONSTRAINT [DF_ScriptAssets_IsPrimary] DEFAULT ((0)) FOR [IsPrimary];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_ScriptAssets_SortOrder')
BEGIN
    ALTER TABLE [dbo].[ScriptAssets] ADD CONSTRAINT [DF_ScriptAssets_SortOrder] DEFAULT ((0)) FOR [SortOrder];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_ScriptAssets_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[ScriptAssets] ADD CONSTRAINT [DF_ScriptAssets_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__ScriptAs__3214EC074DCE8DEE')
BEGIN
    ALTER TABLE [dbo].[ScriptAssets] ADD CONSTRAINT [PK__ScriptAs__3214EC074DCE8DEE] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[ScriptCharacters]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ScriptCharacters]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [ScriptId] int NOT NULL,
        [Name] nvarchar(50) NOT NULL,
        [Gender] nvarchar(20) NOT NULL,
        [AgeRange] nvarchar(20) NOT NULL,
        [Profession] nvarchar(50) NOT NULL,
        [Personality] nvarchar(100) NOT NULL,
        [SecretLine] nvarchar(100) NOT NULL,
        [Description] nvarchar(300) NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__ScriptCh__3214EC07557C0F7B')
BEGIN
    ALTER TABLE [dbo].[ScriptCharacters] ADD CONSTRAINT [PK__ScriptCh__3214EC07557C0F7B] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[ScriptClues]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ScriptClues]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [ScriptId] int NOT NULL,
        [StageId] int NULL,
        [Title] nvarchar(100) NOT NULL,
        [Summary] nvarchar(200) NOT NULL,
        [Detail] nvarchar(500) NOT NULL,
        [ClueType] nvarchar(30) NOT NULL,
        [IsPublic] bit NOT NULL,
        [SortOrder] int NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_ScriptClues_IsPublic')
BEGIN
    ALTER TABLE [dbo].[ScriptClues] ADD CONSTRAINT [DF_ScriptClues_IsPublic] DEFAULT ((1)) FOR [IsPublic];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__ScriptCl__3214EC07C58AEF1A')
BEGIN
    ALTER TABLE [dbo].[ScriptClues] ADD CONSTRAINT [PK__ScriptCl__3214EC07C58AEF1A] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[Scripts]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Scripts]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [GenreId] int NOT NULL,
        [Name] nvarchar(80) NOT NULL,
        [Slogan] nvarchar(180) NOT NULL,
        [StoryBackground] nvarchar(MAX) NOT NULL,
        [CoverImage] nvarchar(300) NOT NULL,
        [DurationMinutes] int NOT NULL,
        [PlayerMin] int NOT NULL,
        [PlayerMax] int NOT NULL,
        [Difficulty] nvarchar(30) NOT NULL,
        [Price] decimal(10,2) NOT NULL,
        [IsFeatured] bit NOT NULL,
        [Status] nvarchar(30) NOT NULL,
        [AuthorName] nvarchar(50) NOT NULL,
        [CreatorUserId] int NULL,
        [AuditStatus] nvarchar(20) NOT NULL,
        [AuditComment] nvarchar(300) NULL,
        [SubmittedAt] datetime NULL,
        [ReviewedAt] datetime NULL,
        [FullScriptContent] nvarchar(MAX) NULL,
        [KillerCharacterName] nvarchar(50) NULL,
        [TruthSummary] nvarchar(MAX) NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF__Scripts__IsFeatu__5629CD9C')
BEGIN
    ALTER TABLE [dbo].[Scripts] ADD CONSTRAINT [DF__Scripts__IsFeatu__5629CD9C] DEFAULT ((0)) FOR [IsFeatured];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_Scripts_AuditStatus')
BEGIN
    ALTER TABLE [dbo].[Scripts] ADD CONSTRAINT [DF_Scripts_AuditStatus] DEFAULT (N'Approved') FOR [AuditStatus];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Scripts__3214EC07CC135AC0')
BEGIN
    ALTER TABLE [dbo].[Scripts] ADD CONSTRAINT [PK__Scripts__3214EC07CC135AC0] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[ServiceMessages]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ServiceMessages]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [BusinessType] nvarchar(30) NOT NULL,
        [BusinessId] int NOT NULL,
        [SenderUserId] int NOT NULL,
        [SenderRole] nvarchar(20) NOT NULL,
        [Content] nvarchar(800) NOT NULL,
        [IsReadByAdmin] bit NOT NULL,
        [IsReadByUser] bit NOT NULL,
        [CreatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_ServiceMessages_IsReadByAdmin')
BEGIN
    ALTER TABLE [dbo].[ServiceMessages] ADD CONSTRAINT [DF_ServiceMessages_IsReadByAdmin] DEFAULT ((0)) FOR [IsReadByAdmin];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_ServiceMessages_IsReadByUser')
BEGIN
    ALTER TABLE [dbo].[ServiceMessages] ADD CONSTRAINT [DF_ServiceMessages_IsReadByUser] DEFAULT ((0)) FOR [IsReadByUser];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_ServiceMessages_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[ServiceMessages] ADD CONSTRAINT [DF_ServiceMessages_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__ServiceM__3214EC07603C2FB2')
BEGIN
    ALTER TABLE [dbo].[ServiceMessages] ADD CONSTRAINT [PK__ServiceM__3214EC07603C2FB2] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[SessionActionLogs]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[SessionActionLogs]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [SessionId] int NOT NULL,
        [ReservationId] int NULL,
        [ActionType] nvarchar(30) NOT NULL,
        [ActionTitle] nvarchar(100) NOT NULL,
        [ActionContent] nvarchar(500) NOT NULL,
        [CreatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__SessionA__3214EC074A0905B3')
BEGIN
    ALTER TABLE [dbo].[SessionActionLogs] ADD CONSTRAINT [PK__SessionA__3214EC074A0905B3] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[SessionCharacterAssignments]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[SessionCharacterAssignments]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [SessionId] int NOT NULL,
        [ReservationId] int NOT NULL,
        [CharacterId] int NOT NULL,
        [IsReady] bit NOT NULL,
        [CreatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_SessionCharacterAssignments_IsReady')
BEGIN
    ALTER TABLE [dbo].[SessionCharacterAssignments] ADD CONSTRAINT [DF_SessionCharacterAssignments_IsReady] DEFAULT ((0)) FOR [IsReady];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__SessionC__3214EC07AB4C9AE4')
BEGIN
    ALTER TABLE [dbo].[SessionCharacterAssignments] ADD CONSTRAINT [PK__SessionC__3214EC07AB4C9AE4] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[SessionClueUnlocks]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[SessionClueUnlocks]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [SessionId] int NOT NULL,
        [ClueId] int NOT NULL,
        [RevealedToReservationId] int NULL,
        [UnlockedByReservationId] int NULL,
        [RevealMethod] nvarchar(40) NOT NULL,
        [RevealedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__SessionC__3214EC07272D8AB1')
BEGIN
    ALTER TABLE [dbo].[SessionClueUnlocks] ADD CONSTRAINT [PK__SessionC__3214EC07272D8AB1] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[SessionGameStates]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[SessionGameStates]
    (
        [SessionId] int NOT NULL,
        [CurrentStageId] int NOT NULL,
        [StartedAt] datetime NOT NULL,
        [UpdatedAt] datetime NOT NULL,
        [GameStartedAt] datetime NULL,
        [GameEndedAt] datetime NULL,
        [SettledAt] datetime NULL,
        [StartedByUserId] int NULL,
        [EndedByUserId] int NULL,
        [CaseKillerCharacterId] int NULL,
        [CaseKillerCharacterName] nvarchar(50) NULL,
        [CaseTruthSummary] nvarchar(MAX) NULL,
        [DmNotes] nvarchar(MAX) NULL,
        [StageTimerStartedAt] datetime NULL,
        [StageTimerDurationMinutes] int NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__SessionG__C9F49290F6623EED')
BEGIN
    ALTER TABLE [dbo].[SessionGameStates] ADD CONSTRAINT [PK__SessionG__C9F49290F6623EED] PRIMARY KEY CLUSTERED ([SessionId] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[Sessions]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Sessions]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [ScriptId] int NOT NULL,
        [RoomId] int NOT NULL,
        [SessionDateTime] datetime NOT NULL,
        [HostName] nvarchar(50) NOT NULL,
        [BasePrice] decimal(10,2) NOT NULL,
        [MaxPlayers] int NOT NULL,
        [Status] nvarchar(30) NOT NULL,
        [HostUserId] int NULL,
        [HostBriefing] nvarchar(500) NULL,
        [HostAcceptedAt] datetime NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Sessions__3214EC07C193277A')
BEGIN
    ALTER TABLE [dbo].[Sessions] ADD CONSTRAINT [PK__Sessions__3214EC07C193277A] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[SessionVotes]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[SessionVotes]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [SessionId] int NOT NULL,
        [ReservationId] int NOT NULL,
        [SuspectCharacterId] int NOT NULL,
        [VoteComment] nvarchar(300) NULL,
        [CreatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__SessionV__3214EC070360C91B')
BEGIN
    ALTER TABLE [dbo].[SessionVotes] ADD CONSTRAINT [PK__SessionV__3214EC070360C91B] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[ShowcaseEntries]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ShowcaseEntries]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [ShowcaseSectionId] int NOT NULL,
        [Title] nvarchar(160) NOT NULL,
        [Summary] nvarchar(600) NOT NULL,
        [TagText] nvarchar(80) NOT NULL,
        [MetaPrimary] nvarchar(120) NULL,
        [MetaSecondary] nvarchar(120) NULL,
        [MetaTertiary] nvarchar(120) NULL,
        [ImageUrl] nvarchar(300) NULL,
        [ActionText] nvarchar(80) NULL,
        [ActionUrl] nvarchar(200) NULL,
        [AccentValue] nvarchar(80) NULL,
        [SortOrder] int NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_ShowcaseEntries_SortOrder')
BEGIN
    ALTER TABLE [dbo].[ShowcaseEntries] ADD CONSTRAINT [DF_ShowcaseEntries_SortOrder] DEFAULT ((1)) FOR [SortOrder];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Showcase__3214EC07831F2B71')
BEGIN
    ALTER TABLE [dbo].[ShowcaseEntries] ADD CONSTRAINT [PK__Showcase__3214EC07831F2B71] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[ShowcasePages]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ShowcasePages]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [PageKey] nvarchar(120) NOT NULL,
        [PageName] nvarchar(120) NOT NULL,
        [Eyebrow] nvarchar(60) NOT NULL,
        [HeroTitle] nvarchar(200) NOT NULL,
        [HeroSummary] nvarchar(600) NOT NULL,
        [HeroDescription] nvarchar(1000) NOT NULL,
        [BadgeText] nvarchar(100) NOT NULL,
        [PrimaryActionText] nvarchar(80) NULL,
        [PrimaryActionUrl] nvarchar(200) NULL,
        [SecondaryActionText] nvarchar(80) NULL,
        [SecondaryActionUrl] nvarchar(200) NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Showcase__3214EC07E557575B')
BEGIN
    ALTER TABLE [dbo].[ShowcasePages] ADD CONSTRAINT [PK__Showcase__3214EC07E557575B] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ__Showcase__C92DA44A84CA4578')
BEGIN
    ALTER TABLE [dbo].[ShowcasePages] ADD CONSTRAINT [UQ__Showcase__C92DA44A84CA4578] UNIQUE NONCLUSTERED ([PageKey] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[ShowcaseSections]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ShowcaseSections]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [ShowcasePageId] int NOT NULL,
        [SectionTitle] nvarchar(160) NOT NULL,
        [SectionSummary] nvarchar(600) NOT NULL,
        [LayoutCode] nvarchar(40) NULL,
        [SortOrder] int NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_ShowcaseSections_SortOrder')
BEGIN
    ALTER TABLE [dbo].[ShowcaseSections] ADD CONSTRAINT [DF_ShowcaseSections_SortOrder] DEFAULT ((1)) FOR [SortOrder];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Showcase__3214EC076FA5E57E')
BEGIN
    ALTER TABLE [dbo].[ShowcaseSections] ADD CONSTRAINT [PK__Showcase__3214EC076FA5E57E] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[ShowcaseStats]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ShowcaseStats]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [ShowcasePageId] int NOT NULL,
        [StatLabel] nvarchar(80) NOT NULL,
        [StatValue] nvarchar(80) NOT NULL,
        [SortOrder] int NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_ShowcaseStats_SortOrder')
BEGIN
    ALTER TABLE [dbo].[ShowcaseStats] ADD CONSTRAINT [DF_ShowcaseStats_SortOrder] DEFAULT ((1)) FOR [SortOrder];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Showcase__3214EC077243B9A3')
BEGIN
    ALTER TABLE [dbo].[ShowcaseStats] ADD CONSTRAINT [PK__Showcase__3214EC077243B9A3] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[SiteSettings]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[SiteSettings]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [SiteName] nvarchar(100) NOT NULL,
        [HeroTitle] nvarchar(150) NOT NULL,
        [HeroSubtitle] nvarchar(200) NOT NULL,
        [WelcomeText] nvarchar(500) NOT NULL,
        [AboutTitle] nvarchar(120) NOT NULL,
        [AboutContent] nvarchar(MAX) NOT NULL,
        [Address] nvarchar(200) NOT NULL,
        [BusinessHours] nvarchar(100) NOT NULL,
        [ContactPhone] nvarchar(30) NOT NULL,
        [ContactWeChat] nvarchar(50) NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__SiteSett__3214EC0740D7DA28')
BEGIN
    ALTER TABLE [dbo].[SiteSettings] ADD CONSTRAINT [PK__SiteSett__3214EC0740D7DA28] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[SpectatorMessages]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[SpectatorMessages]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [SpectatorRoomId] int NOT NULL,
        [SenderName] nvarchar(50) NOT NULL,
        [Content] nvarchar(200) NOT NULL,
        [BadgeText] nvarchar(30) NOT NULL,
        [SentAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Spectato__3214EC07637D6801')
BEGIN
    ALTER TABLE [dbo].[SpectatorMessages] ADD CONSTRAINT [PK__Spectato__3214EC07637D6801] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[SpectatorModes]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[SpectatorModes]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Name] nvarchar(60) NOT NULL,
        [Description] nvarchar(200) NOT NULL,
        [SceneText] nvarchar(120) NOT NULL,
        [SortOrder] int NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Spectato__3214EC073EAFC5D6')
BEGIN
    ALTER TABLE [dbo].[SpectatorModes] ADD CONSTRAINT [PK__Spectato__3214EC073EAFC5D6] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[SpectatorRooms]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[SpectatorRooms]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Title] nvarchar(100) NOT NULL,
        [ScriptName] nvarchar(80) NOT NULL,
        [HostName] nvarchar(50) NOT NULL,
        [ViewerCount] int NOT NULL,
        [HeatScore] int NOT NULL,
        [CoverImage] nvarchar(300) NOT NULL,
        [RoomStatus] nvarchar(30) NOT NULL,
        [RouteCode] nvarchar(50) NOT NULL,
        [SortOrder] int NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Spectato__3214EC07941F4E0A')
BEGIN
    ALTER TABLE [dbo].[SpectatorRooms] ADD CONSTRAINT [PK__Spectato__3214EC07941F4E0A] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[StoreVisitRequests]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[StoreVisitRequests]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [UserId] int NULL,
        [ScriptId] int NULL,
        [ContactName] nvarchar(50) NOT NULL,
        [Phone] nvarchar(30) NOT NULL,
        [PreferredArriveTime] datetime NOT NULL,
        [TeamSize] int NOT NULL,
        [RequestStatus] nvarchar(30) NOT NULL,
        [Note] nvarchar(300) NULL,
        [CreatedAt] datetime NOT NULL,
        [AssignedRoomName] nvarchar(80) NULL,
        [AdminRemark] nvarchar(300) NULL,
        [AdminReply] nvarchar(500) NULL,
        [ProcessedByUserId] int NULL,
        [ProcessedAt] datetime NULL,
        [RepliedAt] datetime NULL,
        [ConfirmStatus] nvarchar(30) NULL,
        [PlayerConfirmRemark] nvarchar(300) NULL,
        [PlayerConfirmedAt] datetime NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_StoreVisitRequests_RequestStatus')
BEGIN
    ALTER TABLE [dbo].[StoreVisitRequests] ADD CONSTRAINT [DF_StoreVisitRequests_RequestStatus] DEFAULT (N'待门店联系') FOR [RequestStatus];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_StoreVisitRequests_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[StoreVisitRequests] ADD CONSTRAINT [DF_StoreVisitRequests_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__StoreVis__3214EC073FD32E87')
BEGIN
    ALTER TABLE [dbo].[StoreVisitRequests] ADD CONSTRAINT [PK__StoreVis__3214EC073FD32E87] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[TodayRecommendations]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[TodayRecommendations]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Title] nvarchar(80) NOT NULL,
        [Summary] nvarchar(240) NOT NULL,
        [CoverImage] nvarchar(300) NOT NULL,
        [PlayerCount] int NOT NULL,
        [Difficulty] nvarchar(20) NOT NULL,
        [Rating] decimal(4,2) NOT NULL,
        [HighlightTag] nvarchar(40) NOT NULL,
        [DestinationUrl] nvarchar(200) NOT NULL,
        [SortOrder] int NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__TodayRec__3214EC07574162EE')
BEGIN
    ALTER TABLE [dbo].[TodayRecommendations] ADD CONSTRAINT [PK__TodayRec__3214EC07574162EE] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[UserBlocks]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[UserBlocks]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [UserId] int NOT NULL,
        [BlockedUserId] int NOT NULL,
        [CreatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserBlocks_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[UserBlocks] ADD CONSTRAINT [DF_UserBlocks_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__UserBloc__3214EC0706A156D3')
BEGIN
    ALTER TABLE [dbo].[UserBlocks] ADD CONSTRAINT [PK__UserBloc__3214EC0706A156D3] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[UserCoupons]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[UserCoupons]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [UserId] int NOT NULL,
        [Title] nvarchar(80) NOT NULL,
        [CouponType] nvarchar(20) NOT NULL,
        [DiscountAmount] decimal(10,2) NOT NULL,
        [MinSpend] decimal(10,2) NOT NULL,
        [Status] nvarchar(20) NOT NULL,
        [Source] nvarchar(80) NULL,
        [IssuedByUserId] int NULL,
        [IssuedAt] datetime NOT NULL,
        [ValidFrom] datetime NOT NULL,
        [ValidUntil] datetime NOT NULL,
        [UsedReservationId] int NULL,
        [UsedAt] datetime NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserCoupons_CouponType')
BEGIN
    ALTER TABLE [dbo].[UserCoupons] ADD CONSTRAINT [DF_UserCoupons_CouponType] DEFAULT (N'Amount') FOR [CouponType];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserCoupons_MinSpend')
BEGIN
    ALTER TABLE [dbo].[UserCoupons] ADD CONSTRAINT [DF_UserCoupons_MinSpend] DEFAULT ((0)) FOR [MinSpend];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserCoupons_Status')
BEGIN
    ALTER TABLE [dbo].[UserCoupons] ADD CONSTRAINT [DF_UserCoupons_Status] DEFAULT (N'未使用') FOR [Status];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserCoupons_IssuedAt')
BEGIN
    ALTER TABLE [dbo].[UserCoupons] ADD CONSTRAINT [DF_UserCoupons_IssuedAt] DEFAULT (getdate()) FOR [IssuedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserCoupons_ValidFrom')
BEGIN
    ALTER TABLE [dbo].[UserCoupons] ADD CONSTRAINT [DF_UserCoupons_ValidFrom] DEFAULT (getdate()) FOR [ValidFrom];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__UserCoup__3214EC074BB2844C')
BEGIN
    ALTER TABLE [dbo].[UserCoupons] ADD CONSTRAINT [PK__UserCoup__3214EC074BB2844C] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[UserDesktopSettings]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[UserDesktopSettings]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [UserId] int NOT NULL,
        [LoginConfirmMode] nvarchar(30) NOT NULL,
        [KeepChatHistory] bit NOT NULL,
        [StoragePath] nvarchar(260) NULL,
        [AutoDownloadMaxMb] int NOT NULL,
        [NotificationEnabled] bit NOT NULL,
        [ShortcutScheme] nvarchar(40) NOT NULL,
        [PluginEnabled] bit NOT NULL,
        [FriendRequestEnabled] bit NOT NULL,
        [PhoneSearchEnabled] bit NOT NULL,
        [ShowMomentsToStrangers] bit NOT NULL,
        [UseEnterToSend] bit NOT NULL,
        [CreatedAt] datetime NOT NULL,
        [UpdatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserDesktopSettings_LoginConfirmMode')
BEGIN
    ALTER TABLE [dbo].[UserDesktopSettings] ADD CONSTRAINT [DF_UserDesktopSettings_LoginConfirmMode] DEFAULT (N'MobileConfirm') FOR [LoginConfirmMode];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserDesktopSettings_KeepChatHistory')
BEGIN
    ALTER TABLE [dbo].[UserDesktopSettings] ADD CONSTRAINT [DF_UserDesktopSettings_KeepChatHistory] DEFAULT ((1)) FOR [KeepChatHistory];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserDesktopSettings_AutoDownloadMaxMb')
BEGIN
    ALTER TABLE [dbo].[UserDesktopSettings] ADD CONSTRAINT [DF_UserDesktopSettings_AutoDownloadMaxMb] DEFAULT ((20)) FOR [AutoDownloadMaxMb];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserDesktopSettings_NotificationEnabled')
BEGIN
    ALTER TABLE [dbo].[UserDesktopSettings] ADD CONSTRAINT [DF_UserDesktopSettings_NotificationEnabled] DEFAULT ((1)) FOR [NotificationEnabled];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserDesktopSettings_ShortcutScheme')
BEGIN
    ALTER TABLE [dbo].[UserDesktopSettings] ADD CONSTRAINT [DF_UserDesktopSettings_ShortcutScheme] DEFAULT (N'Default') FOR [ShortcutScheme];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserDesktopSettings_PluginEnabled')
BEGIN
    ALTER TABLE [dbo].[UserDesktopSettings] ADD CONSTRAINT [DF_UserDesktopSettings_PluginEnabled] DEFAULT ((1)) FOR [PluginEnabled];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserDesktopSettings_FriendRequestEnabled')
BEGIN
    ALTER TABLE [dbo].[UserDesktopSettings] ADD CONSTRAINT [DF_UserDesktopSettings_FriendRequestEnabled] DEFAULT ((1)) FOR [FriendRequestEnabled];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserDesktopSettings_PhoneSearchEnabled')
BEGIN
    ALTER TABLE [dbo].[UserDesktopSettings] ADD CONSTRAINT [DF_UserDesktopSettings_PhoneSearchEnabled] DEFAULT ((0)) FOR [PhoneSearchEnabled];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserDesktopSettings_ShowMomentsToStrangers')
BEGIN
    ALTER TABLE [dbo].[UserDesktopSettings] ADD CONSTRAINT [DF_UserDesktopSettings_ShowMomentsToStrangers] DEFAULT ((0)) FOR [ShowMomentsToStrangers];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserDesktopSettings_UseEnterToSend')
BEGIN
    ALTER TABLE [dbo].[UserDesktopSettings] ADD CONSTRAINT [DF_UserDesktopSettings_UseEnterToSend] DEFAULT ((0)) FOR [UseEnterToSend];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserDesktopSettings_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[UserDesktopSettings] ADD CONSTRAINT [DF_UserDesktopSettings_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserDesktopSettings_UpdatedAt')
BEGIN
    ALTER TABLE [dbo].[UserDesktopSettings] ADD CONSTRAINT [DF_UserDesktopSettings_UpdatedAt] DEFAULT (getdate()) FOR [UpdatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__UserDesk__3214EC07FB877FC0')
BEGIN
    ALTER TABLE [dbo].[UserDesktopSettings] ADD CONSTRAINT [PK__UserDesk__3214EC07FB877FC0] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[UserLoginSecurityLogs]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[UserLoginSecurityLogs]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [UserId] int NULL,
        [Username] nvarchar(50) NOT NULL,
        [ResultType] nvarchar(30) NOT NULL,
        [IpAddress] nvarchar(80) NULL,
        [UserAgent] nvarchar(500) NULL,
        [Detail] nvarchar(300) NULL,
        [CreatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserLoginSecurityLogs_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[UserLoginSecurityLogs] ADD CONSTRAINT [DF_UserLoginSecurityLogs_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__UserLogi__3214EC0717A9F05E')
BEGIN
    ALTER TABLE [dbo].[UserLoginSecurityLogs] ADD CONSTRAINT [PK__UserLogi__3214EC0717A9F05E] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[UserNotificationReads]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[UserNotificationReads]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [UserId] int NOT NULL,
        [NotificationKey] nvarchar(200) NOT NULL,
        [ReadAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserNotificationReads_ReadAt')
BEGIN
    ALTER TABLE [dbo].[UserNotificationReads] ADD CONSTRAINT [DF_UserNotificationReads_ReadAt] DEFAULT (getdate()) FOR [ReadAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__UserNoti__3214EC073E87EB9A')
BEGIN
    ALTER TABLE [dbo].[UserNotificationReads] ADD CONSTRAINT [PK__UserNoti__3214EC073E87EB9A] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[UserProfileChangeLogs]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[UserProfileChangeLogs]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [UserId] int NOT NULL,
        [FieldName] nvarchar(50) NOT NULL,
        [BeforeValue] nvarchar(1000) NULL,
        [AfterValue] nvarchar(1000) NULL,
        [ChangedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserProfileChangeLogs_ChangedAt')
BEGIN
    ALTER TABLE [dbo].[UserProfileChangeLogs] ADD CONSTRAINT [DF_UserProfileChangeLogs_ChangedAt] DEFAULT (getdate()) FOR [ChangedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__UserProf__3214EC07F7EDCA31')
BEGIN
    ALTER TABLE [dbo].[UserProfileChangeLogs] ADD CONSTRAINT [PK__UserProf__3214EC07F7EDCA31] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[UserQuickNotes]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[UserQuickNotes]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [UserId] int NOT NULL,
        [Title] nvarchar(80) NOT NULL,
        [Content] nvarchar(600) NOT NULL,
        [CreatedAt] datetime NOT NULL,
        [UpdatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserQuickNotes_CreatedAt')
BEGIN
    ALTER TABLE [dbo].[UserQuickNotes] ADD CONSTRAINT [DF_UserQuickNotes_CreatedAt] DEFAULT (getdate()) FOR [CreatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_UserQuickNotes_UpdatedAt')
BEGIN
    ALTER TABLE [dbo].[UserQuickNotes] ADD CONSTRAINT [DF_UserQuickNotes_UpdatedAt] DEFAULT (getdate()) FOR [UpdatedAt];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__UserQuic__3214EC07C0C5059B')
BEGIN
    ALTER TABLE [dbo].[UserQuickNotes] ADD CONSTRAINT [PK__UserQuic__3214EC07C0C5059B] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[Users]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Users]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Username] nvarchar(50) NOT NULL,
        [PasswordHash] nvarchar(64) NOT NULL,
        [DisplayName] nvarchar(50) NOT NULL,
        [Email] nvarchar(100) NOT NULL,
        [Phone] nvarchar(30) NOT NULL,
        [RoleCode] nvarchar(20) NOT NULL,
        [ReviewStatus] nvarchar(20) NOT NULL,
        [ReviewRemark] nvarchar(200) NULL,
        [Balance] decimal(10,2) NOT NULL,
        [CreatedAt] datetime NOT NULL,
        [ReviewedAt] datetime NULL,
        [PublicUserCode] nvarchar(24) NULL,
        [GiftBalance] int NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_Users_Balance')
BEGIN
    ALTER TABLE [dbo].[Users] ADD CONSTRAINT [DF_Users_Balance] DEFAULT ((0)) FOR [Balance];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_Users_GiftBalance')
BEGIN
    ALTER TABLE [dbo].[Users] ADD CONSTRAINT [DF_Users_GiftBalance] DEFAULT ((0)) FOR [GiftBalance];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__Users__3214EC0737ADD728')
BEGIN
    ALTER TABLE [dbo].[Users] ADD CONSTRAINT [PK__Users__3214EC0737ADD728] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[WalletTransactions]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[WalletTransactions]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [UserId] int NOT NULL,
        [TransactionType] nvarchar(30) NOT NULL,
        [Amount] decimal(10,2) NOT NULL,
        [BalanceAfter] decimal(10,2) NOT NULL,
        [Summary] nvarchar(200) NOT NULL,
        [CreatedAt] datetime NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK__WalletTr__3214EC07C52D305F')
BEGIN
    ALTER TABLE [dbo].[WalletTransactions] ADD CONSTRAINT [PK__WalletTr__3214EC07C52D305F] PRIMARY KEY CLUSTERED ([Id] ASC);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Achievements_Users')
BEGIN
    ALTER TABLE [dbo].[Achievements] ADD CONSTRAINT [FK_Achievements_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PasswordResetTickets_Users')
BEGIN
    ALTER TABLE [dbo].[PasswordResetTickets] ADD CONSTRAINT [FK_PasswordResetTickets_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PlayerAbilities_Users')
BEGIN
    ALTER TABLE [dbo].[PlayerAbilities] ADD CONSTRAINT [FK_PlayerAbilities_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PlayerBattleRecords_Characters')
BEGIN
    ALTER TABLE [dbo].[PlayerBattleRecords] ADD CONSTRAINT [FK_PlayerBattleRecords_Characters] FOREIGN KEY ([CharacterId]) REFERENCES [dbo].[ScriptCharacters] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PlayerBattleRecords_Reservations')
BEGIN
    ALTER TABLE [dbo].[PlayerBattleRecords] ADD CONSTRAINT [FK_PlayerBattleRecords_Reservations] FOREIGN KEY ([ReservationId]) REFERENCES [dbo].[Reservations] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PlayerBattleRecords_Scripts')
BEGIN
    ALTER TABLE [dbo].[PlayerBattleRecords] ADD CONSTRAINT [FK_PlayerBattleRecords_Scripts] FOREIGN KEY ([ScriptId]) REFERENCES [dbo].[Scripts] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PlayerBattleRecords_Sessions')
BEGIN
    ALTER TABLE [dbo].[PlayerBattleRecords] ADD CONSTRAINT [FK_PlayerBattleRecords_Sessions] FOREIGN KEY ([SessionId]) REFERENCES [dbo].[Sessions] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PlayerBattleRecords_Users')
BEGIN
    ALTER TABLE [dbo].[PlayerBattleRecords] ADD CONSTRAINT [FK_PlayerBattleRecords_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PlayerBattleRecords_VotedCharacters')
BEGIN
    ALTER TABLE [dbo].[PlayerBattleRecords] ADD CONSTRAINT [FK_PlayerBattleRecords_VotedCharacters] FOREIGN KEY ([VotedCharacterId]) REFERENCES [dbo].[ScriptCharacters] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PlayerProfiles_Users')
BEGIN
    ALTER TABLE [dbo].[PlayerProfiles] ADD CONSTRAINT [FK_PlayerProfiles_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_RechargeRequests_ReviewedByUsers')
BEGIN
    ALTER TABLE [dbo].[RechargeRequests] ADD CONSTRAINT [FK_RechargeRequests_ReviewedByUsers] FOREIGN KEY ([ReviewedByUserId]) REFERENCES [dbo].[Users] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_RechargeRequests_Users')
BEGIN
    ALTER TABLE [dbo].[RechargeRequests] ADD CONSTRAINT [FK_RechargeRequests_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_RechargeRequests_WalletTransactions')
BEGIN
    ALTER TABLE [dbo].[RechargeRequests] ADD CONSTRAINT [FK_RechargeRequests_WalletTransactions] FOREIGN KEY ([WalletTransactionId]) REFERENCES [dbo].[WalletTransactions] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Reservations_Sessions')
BEGIN
    ALTER TABLE [dbo].[Reservations] ADD CONSTRAINT [FK_Reservations_Sessions] FOREIGN KEY ([SessionId]) REFERENCES [dbo].[Sessions] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Reservations_Users')
BEGIN
    ALTER TABLE [dbo].[Reservations] ADD CONSTRAINT [FK_Reservations_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Reservations_WalletTransactions')
BEGIN
    ALTER TABLE [dbo].[Reservations] ADD CONSTRAINT [FK_Reservations_WalletTransactions] FOREIGN KEY ([PaymentTransactionId]) REFERENCES [dbo].[WalletTransactions] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ReservationWaitlists_Sessions')
BEGIN
    ALTER TABLE [dbo].[ReservationWaitlists] ADD CONSTRAINT [FK_ReservationWaitlists_Sessions] FOREIGN KEY ([SessionId]) REFERENCES [dbo].[Sessions] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ReservationWaitlists_Users')
BEGIN
    ALTER TABLE [dbo].[ReservationWaitlists] ADD CONSTRAINT [FK_ReservationWaitlists_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Reviews_Scripts')
BEGIN
    ALTER TABLE [dbo].[Reviews] ADD CONSTRAINT [FK_Reviews_Scripts] FOREIGN KEY ([ScriptId]) REFERENCES [dbo].[Scripts] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_RoomMessages_Reservations')
BEGIN
    ALTER TABLE [dbo].[RoomMessages] ADD CONSTRAINT [FK_RoomMessages_Reservations] FOREIGN KEY ([ReservationId]) REFERENCES [dbo].[Reservations] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_RoomMessages_Sessions')
BEGIN
    ALTER TABLE [dbo].[RoomMessages] ADD CONSTRAINT [FK_RoomMessages_Sessions] FOREIGN KEY ([SessionId]) REFERENCES [dbo].[Sessions] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_RoomMessages_Users')
BEGIN
    ALTER TABLE [dbo].[RoomMessages] ADD CONSTRAINT [FK_RoomMessages_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_RoomPresence_Reservations')
BEGIN
    ALTER TABLE [dbo].[RoomPresence] ADD CONSTRAINT [FK_RoomPresence_Reservations] FOREIGN KEY ([ReservationId]) REFERENCES [dbo].[Reservations] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_RoomPresence_Sessions')
BEGIN
    ALTER TABLE [dbo].[RoomPresence] ADD CONSTRAINT [FK_RoomPresence_Sessions] FOREIGN KEY ([SessionId]) REFERENCES [dbo].[Sessions] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_RoomPresence_Users')
BEGIN
    ALTER TABLE [dbo].[RoomPresence] ADD CONSTRAINT [FK_RoomPresence_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ScriptAssets_Scripts')
BEGIN
    ALTER TABLE [dbo].[ScriptAssets] ADD CONSTRAINT [FK_ScriptAssets_Scripts] FOREIGN KEY ([ScriptId]) REFERENCES [dbo].[Scripts] ([Id]) ON DELETE CASCADE;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ScriptCharacters_Scripts')
BEGIN
    ALTER TABLE [dbo].[ScriptCharacters] ADD CONSTRAINT [FK_ScriptCharacters_Scripts] FOREIGN KEY ([ScriptId]) REFERENCES [dbo].[Scripts] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ScriptClues_GameStages')
BEGIN
    ALTER TABLE [dbo].[ScriptClues] ADD CONSTRAINT [FK_ScriptClues_GameStages] FOREIGN KEY ([StageId]) REFERENCES [dbo].[GameStages] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ScriptClues_Scripts')
BEGIN
    ALTER TABLE [dbo].[ScriptClues] ADD CONSTRAINT [FK_ScriptClues_Scripts] FOREIGN KEY ([ScriptId]) REFERENCES [dbo].[Scripts] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Scripts_Genres')
BEGIN
    ALTER TABLE [dbo].[Scripts] ADD CONSTRAINT [FK_Scripts_Genres] FOREIGN KEY ([GenreId]) REFERENCES [dbo].[Genres] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Scripts_Users')
BEGIN
    ALTER TABLE [dbo].[Scripts] ADD CONSTRAINT [FK_Scripts_Users] FOREIGN KEY ([CreatorUserId]) REFERENCES [dbo].[Users] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_SessionActionLogs_Reservations')
BEGIN
    ALTER TABLE [dbo].[SessionActionLogs] ADD CONSTRAINT [FK_SessionActionLogs_Reservations] FOREIGN KEY ([ReservationId]) REFERENCES [dbo].[Reservations] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_SessionActionLogs_Sessions')
BEGIN
    ALTER TABLE [dbo].[SessionActionLogs] ADD CONSTRAINT [FK_SessionActionLogs_Sessions] FOREIGN KEY ([SessionId]) REFERENCES [dbo].[Sessions] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_SessionCharacterAssignments_Reservations')
BEGIN
    ALTER TABLE [dbo].[SessionCharacterAssignments] ADD CONSTRAINT [FK_SessionCharacterAssignments_Reservations] FOREIGN KEY ([ReservationId]) REFERENCES [dbo].[Reservations] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_SessionCharacterAssignments_ScriptCharacters')
BEGIN
    ALTER TABLE [dbo].[SessionCharacterAssignments] ADD CONSTRAINT [FK_SessionCharacterAssignments_ScriptCharacters] FOREIGN KEY ([CharacterId]) REFERENCES [dbo].[ScriptCharacters] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_SessionCharacterAssignments_Sessions')
BEGIN
    ALTER TABLE [dbo].[SessionCharacterAssignments] ADD CONSTRAINT [FK_SessionCharacterAssignments_Sessions] FOREIGN KEY ([SessionId]) REFERENCES [dbo].[Sessions] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_SessionClueUnlocks_RevealedToReservations')
BEGIN
    ALTER TABLE [dbo].[SessionClueUnlocks] ADD CONSTRAINT [FK_SessionClueUnlocks_RevealedToReservations] FOREIGN KEY ([RevealedToReservationId]) REFERENCES [dbo].[Reservations] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_SessionClueUnlocks_ScriptClues')
BEGIN
    ALTER TABLE [dbo].[SessionClueUnlocks] ADD CONSTRAINT [FK_SessionClueUnlocks_ScriptClues] FOREIGN KEY ([ClueId]) REFERENCES [dbo].[ScriptClues] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_SessionClueUnlocks_Sessions')
BEGIN
    ALTER TABLE [dbo].[SessionClueUnlocks] ADD CONSTRAINT [FK_SessionClueUnlocks_Sessions] FOREIGN KEY ([SessionId]) REFERENCES [dbo].[Sessions] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_SessionClueUnlocks_UnlockedByReservations')
BEGIN
    ALTER TABLE [dbo].[SessionClueUnlocks] ADD CONSTRAINT [FK_SessionClueUnlocks_UnlockedByReservations] FOREIGN KEY ([UnlockedByReservationId]) REFERENCES [dbo].[Reservations] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_SessionGameStates_EndedByUsers')
BEGIN
    ALTER TABLE [dbo].[SessionGameStates] ADD CONSTRAINT [FK_SessionGameStates_EndedByUsers] FOREIGN KEY ([EndedByUserId]) REFERENCES [dbo].[Users] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_SessionGameStates_GameStages')
BEGIN
    ALTER TABLE [dbo].[SessionGameStates] ADD CONSTRAINT [FK_SessionGameStates_GameStages] FOREIGN KEY ([CurrentStageId]) REFERENCES [dbo].[GameStages] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_SessionGameStates_Sessions')
BEGIN
    ALTER TABLE [dbo].[SessionGameStates] ADD CONSTRAINT [FK_SessionGameStates_Sessions] FOREIGN KEY ([SessionId]) REFERENCES [dbo].[Sessions] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_SessionGameStates_StartedByUsers')
BEGIN
    ALTER TABLE [dbo].[SessionGameStates] ADD CONSTRAINT [FK_SessionGameStates_StartedByUsers] FOREIGN KEY ([StartedByUserId]) REFERENCES [dbo].[Users] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Sessions_Rooms')
BEGIN
    ALTER TABLE [dbo].[Sessions] ADD CONSTRAINT [FK_Sessions_Rooms] FOREIGN KEY ([RoomId]) REFERENCES [dbo].[Rooms] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Sessions_Scripts')
BEGIN
    ALTER TABLE [dbo].[Sessions] ADD CONSTRAINT [FK_Sessions_Scripts] FOREIGN KEY ([ScriptId]) REFERENCES [dbo].[Scripts] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_SessionVotes_Reservations')
BEGIN
    ALTER TABLE [dbo].[SessionVotes] ADD CONSTRAINT [FK_SessionVotes_Reservations] FOREIGN KEY ([ReservationId]) REFERENCES [dbo].[Reservations] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_SessionVotes_ScriptCharacters')
BEGIN
    ALTER TABLE [dbo].[SessionVotes] ADD CONSTRAINT [FK_SessionVotes_ScriptCharacters] FOREIGN KEY ([SuspectCharacterId]) REFERENCES [dbo].[ScriptCharacters] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_SessionVotes_Sessions')
BEGIN
    ALTER TABLE [dbo].[SessionVotes] ADD CONSTRAINT [FK_SessionVotes_Sessions] FOREIGN KEY ([SessionId]) REFERENCES [dbo].[Sessions] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ShowcaseEntries_Section')
BEGIN
    ALTER TABLE [dbo].[ShowcaseEntries] ADD CONSTRAINT [FK_ShowcaseEntries_Section] FOREIGN KEY ([ShowcaseSectionId]) REFERENCES [dbo].[ShowcaseSections] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ShowcaseSections_Page')
BEGIN
    ALTER TABLE [dbo].[ShowcaseSections] ADD CONSTRAINT [FK_ShowcaseSections_Page] FOREIGN KEY ([ShowcasePageId]) REFERENCES [dbo].[ShowcasePages] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ShowcaseStats_Page')
BEGIN
    ALTER TABLE [dbo].[ShowcaseStats] ADD CONSTRAINT [FK_ShowcaseStats_Page] FOREIGN KEY ([ShowcasePageId]) REFERENCES [dbo].[ShowcasePages] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_SpectatorMessages_SpectatorRooms')
BEGIN
    ALTER TABLE [dbo].[SpectatorMessages] ADD CONSTRAINT [FK_SpectatorMessages_SpectatorRooms] FOREIGN KEY ([SpectatorRoomId]) REFERENCES [dbo].[SpectatorRooms] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_UserProfileChangeLogs_Users')
BEGIN
    ALTER TABLE [dbo].[UserProfileChangeLogs] ADD CONSTRAINT [FK_UserProfileChangeLogs_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_WalletTransactions_Users')
BEGIN
    ALTER TABLE [dbo].[WalletTransactions] ADD CONSTRAINT [FK_WalletTransactions_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_AdminReplyLogs_Business' AND object_id = OBJECT_ID(N'[dbo].[AdminReplyLogs]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_AdminReplyLogs_Business] ON [dbo].[AdminReplyLogs] ([BusinessType], [BusinessId], [CreatedAt] DESC);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_AfterSaleRequests_Reservation' AND object_id = OBJECT_ID(N'[dbo].[AfterSaleRequests]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_AfterSaleRequests_Reservation] ON [dbo].[AfterSaleRequests] ([ReservationId], [CreatedAt] DESC);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_AfterSaleRequests_Status' AND object_id = OBJECT_ID(N'[dbo].[AfterSaleRequests]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_AfterSaleRequests_Status] ON [dbo].[AfterSaleRequests] ([Status], [CreatedAt] DESC);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_BusinessActionLogs_Business' AND object_id = OBJECT_ID(N'[dbo].[BusinessActionLogs]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_BusinessActionLogs_Business] ON [dbo].[BusinessActionLogs] ([BusinessType], [BusinessId], [CreatedAt] DESC);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_ChatGroupMembers_Group_User' AND object_id = OBJECT_ID(N'[dbo].[ChatGroupMembers]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_ChatGroupMembers_Group_User] ON [dbo].[ChatGroupMembers] ([GroupId], [UserId]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_DownloadOptions_ActiveSort' AND object_id = OBJECT_ID(N'[dbo].[DownloadOptions]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_DownloadOptions_ActiveSort] ON [dbo].[DownloadOptions] ([IsActive], [SortOrder], [Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_FriendConversationPreferences_User_Friend' AND object_id = OBJECT_ID(N'[dbo].[FriendConversationPreferences]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_FriendConversationPreferences_User_Friend] ON [dbo].[FriendConversationPreferences] ([UserId], [FriendUserId]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_FriendMoneyTransfers_MessageId' AND object_id = OBJECT_ID(N'[dbo].[FriendMoneyTransfers]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_FriendMoneyTransfers_MessageId] ON [dbo].[FriendMoneyTransfers] ([MessageId]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Friendships_User_Friend' AND object_id = OBJECT_ID(N'[dbo].[Friendships]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_Friendships_User_Friend] ON [dbo].[Friendships] ([UserId], [FriendUserId]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_GameStages_StageKey' AND object_id = OBJECT_ID(N'[dbo].[GameStages]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_GameStages_StageKey] ON [dbo].[GameStages] ([StageKey]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_GroupConversationPreferences_User_Group' AND object_id = OBJECT_ID(N'[dbo].[GroupConversationPreferences]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_GroupConversationPreferences_User_Group] ON [dbo].[GroupConversationPreferences] ([UserId], [GroupId]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_MomentLikes_Moment_User' AND object_id = OBJECT_ID(N'[dbo].[MomentLikes]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_MomentLikes_Moment_User] ON [dbo].[MomentLikes] ([MomentId], [UserId]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_PasswordResetTickets_Code' AND object_id = OBJECT_ID(N'[dbo].[PasswordResetTickets]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_PasswordResetTickets_Code] ON [dbo].[PasswordResetTickets] ([TicketCode]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PlayerBattleRecords_User_CompletedAt' AND object_id = OBJECT_ID(N'[dbo].[PlayerBattleRecords]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_PlayerBattleRecords_User_CompletedAt] ON [dbo].[PlayerBattleRecords] ([UserId], [CompletedAt] DESC);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_PlayerBattleRecords_SessionReservation' AND object_id = OBJECT_ID(N'[dbo].[PlayerBattleRecords]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_PlayerBattleRecords_SessionReservation] ON [dbo].[PlayerBattleRecords] ([SessionId], [ReservationId]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_RechargeRequests_RechargeOrderNo' AND object_id = OBJECT_ID(N'[dbo].[RechargeRequests]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_RechargeRequests_RechargeOrderNo] ON [dbo].[RechargeRequests] ([RechargeOrderNo]) WHERE ([RechargeOrderNo] IS NOT NULL);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Reservations_CheckInCode' AND object_id = OBJECT_ID(N'[dbo].[Reservations]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Reservations_CheckInCode] ON [dbo].[Reservations] ([CheckInCode], [Status]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ReservationWaitlists_SessionStatus' AND object_id = OBJECT_ID(N'[dbo].[ReservationWaitlists]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_ReservationWaitlists_SessionStatus] ON [dbo].[ReservationWaitlists] ([SessionId], [Status], [CreatedAt] DESC);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ReservationWaitlists_UserStatus' AND object_id = OBJECT_ID(N'[dbo].[ReservationWaitlists]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_ReservationWaitlists_UserStatus] ON [dbo].[ReservationWaitlists] ([UserId], [Status], [CreatedAt] DESC);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Reviews_UserReservation' AND object_id = OBJECT_ID(N'[dbo].[Reviews]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Reviews_UserReservation] ON [dbo].[Reviews] ([UserId], [ReservationId]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_RoomPresence_ReservationId' AND object_id = OBJECT_ID(N'[dbo].[RoomPresence]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_RoomPresence_ReservationId] ON [dbo].[RoomPresence] ([ReservationId]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_SchemaMigrations_MigrationKey' AND object_id = OBJECT_ID(N'[dbo].[SchemaMigrations]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_SchemaMigrations_MigrationKey] ON [dbo].[SchemaMigrations] ([MigrationKey]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ScriptAssets_ScriptId' AND object_id = OBJECT_ID(N'[dbo].[ScriptAssets]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_ScriptAssets_ScriptId] ON [dbo].[ScriptAssets] ([ScriptId], [SortOrder], [Id]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ServiceMessages_Business' AND object_id = OBJECT_ID(N'[dbo].[ServiceMessages]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_ServiceMessages_Business] ON [dbo].[ServiceMessages] ([BusinessType], [BusinessId], [CreatedAt] DESC);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ServiceMessages_UnreadAdmin' AND object_id = OBJECT_ID(N'[dbo].[ServiceMessages]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_ServiceMessages_UnreadAdmin] ON [dbo].[ServiceMessages] ([IsReadByAdmin], [CreatedAt] DESC);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_SessionCharacterAssignments_SessionCharacter' AND object_id = OBJECT_ID(N'[dbo].[SessionCharacterAssignments]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_SessionCharacterAssignments_SessionCharacter] ON [dbo].[SessionCharacterAssignments] ([SessionId], [CharacterId]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_SessionCharacterAssignments_SessionReservation' AND object_id = OBJECT_ID(N'[dbo].[SessionCharacterAssignments]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_SessionCharacterAssignments_SessionReservation] ON [dbo].[SessionCharacterAssignments] ([SessionId], [ReservationId]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_SessionVotes_SessionReservation' AND object_id = OBJECT_ID(N'[dbo].[SessionVotes]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_SessionVotes_SessionReservation] ON [dbo].[SessionVotes] ([SessionId], [ReservationId]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_UserBlocks_User_Blocked' AND object_id = OBJECT_ID(N'[dbo].[UserBlocks]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_UserBlocks_User_Blocked] ON [dbo].[UserBlocks] ([UserId], [BlockedUserId]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UserCoupons_Recent' AND object_id = OBJECT_ID(N'[dbo].[UserCoupons]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_UserCoupons_Recent] ON [dbo].[UserCoupons] ([IssuedAt] DESC, [Id] DESC);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UserCoupons_UserStatus' AND object_id = OBJECT_ID(N'[dbo].[UserCoupons]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_UserCoupons_UserStatus] ON [dbo].[UserCoupons] ([UserId], [Status], [ValidUntil]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_UserDesktopSettings_User' AND object_id = OBJECT_ID(N'[dbo].[UserDesktopSettings]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_UserDesktopSettings_User] ON [dbo].[UserDesktopSettings] ([UserId]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UserLoginSecurityLogs_User_CreatedAt' AND object_id = OBJECT_ID(N'[dbo].[UserLoginSecurityLogs]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_UserLoginSecurityLogs_User_CreatedAt] ON [dbo].[UserLoginSecurityLogs] ([UserId], [CreatedAt] DESC);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_UserNotificationReads_UserKey' AND object_id = OBJECT_ID(N'[dbo].[UserNotificationReads]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_UserNotificationReads_UserKey] ON [dbo].[UserNotificationReads] ([UserId], [NotificationKey]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UserProfileChangeLogs_User_ChangedAt' AND object_id = OBJECT_ID(N'[dbo].[UserProfileChangeLogs]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_UserProfileChangeLogs_User_ChangedAt] ON [dbo].[UserProfileChangeLogs] ([UserId], [ChangedAt] DESC);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Users_PublicUserCode' AND object_id = OBJECT_ID(N'[dbo].[Users]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_Users_PublicUserCode] ON [dbo].[Users] ([PublicUserCode]) WHERE ([PublicUserCode] IS NOT NULL);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Users_Username' AND object_id = OBJECT_ID(N'[dbo].[Users]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_Users_Username] ON [dbo].[Users] ([Username]);
END
GO

