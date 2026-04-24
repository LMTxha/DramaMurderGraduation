using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Security.Cryptography;
using System.Text.RegularExpressions;
using System.Web.Hosting;

namespace DramaMurderGraduation.Web.Data
{
    public static class SqlDatabaseInitializer
    {
        private const string BaseSchemaMigrationKey = "base-schema";
        private const string IncrementalFeaturesMigrationKey = "incremental-features";
        private const string IncrementalFeaturesMigrationVersion = "2026-04-24-v3";
        private static readonly object SyncRoot = new object();
        private static bool _initialized;

        public static void EnsureDatabase()
        {
            if (_initialized)
            {
                return;
            }

            lock (SyncRoot)
            {
                if (_initialized)
                {
                    return;
                }

                var databaseName = ConfigurationManager.AppSettings["DatabaseName"] ?? "DramaMurderGraduationDb";
                var appDataPath = HostingEnvironment.MapPath("~/App_Data") ?? throw new InvalidOperationException("无法定位 App_Data 目录。");
                var databaseScriptPath = HostingEnvironment.MapPath("~/Database/DramaMurder.sql") ?? throw new InvalidOperationException("无法定位数据库脚本。");
                var configuredDatabaseDirectory = ResolveDatabaseDirectory();
                if (!string.IsNullOrWhiteSpace(configuredDatabaseDirectory))
                {
                    appDataPath = configuredDatabaseDirectory;
                }

                Directory.CreateDirectory(appDataPath);

                var mdfPath = Path.Combine(appDataPath, databaseName + ".mdf");
                var ldfPath = Path.Combine(appDataPath, databaseName + "_log.ldf");

                var databaseCreated = EnsureDatabaseFiles(databaseName, mdfPath, ldfPath);
                if (databaseCreated || !HasRequiredSchema(databaseName))
                {
                    EnsureSchema(databaseName, databaseScriptPath);
                }

                EnsureIncrementalFeatures(databaseName);

                _initialized = true;
            }
        }

        private static string ResolveDatabaseDirectory()
        {
            var configuredDirectory = ConfigurationManager.AppSettings["DatabaseDirectory"];
            if (!string.IsNullOrWhiteSpace(configuredDirectory))
            {
                if (Path.IsPathRooted(configuredDirectory))
                {
                    return configuredDirectory;
                }

                var mappedDirectory = HostingEnvironment.MapPath(configuredDirectory);
                if (!string.IsNullOrWhiteSpace(mappedDirectory))
                {
                    return mappedDirectory;
                }

                return Path.GetFullPath(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, configuredDirectory));
            }

            return string.Empty;
        }

        private static string BuildMasterConnectionString()
        {
            var builder = new SqlConnectionStringBuilder(ConfigurationManager.ConnectionStrings["DramaMurderDb"].ConnectionString)
            {
                InitialCatalog = "master",
                AttachDBFilename = string.Empty
            };

            return builder.ConnectionString;
        }

        private static string BuildDatabaseConnectionString(string databaseName)
        {
            var builder = new SqlConnectionStringBuilder(ConfigurationManager.ConnectionStrings["DramaMurderDb"].ConnectionString)
            {
                InitialCatalog = databaseName,
                AttachDBFilename = string.Empty
            };

            return builder.ConnectionString;
        }

        private static bool EnsureDatabaseFiles(string databaseName, string mdfPath, string ldfPath)
        {
            using (var connection = new SqlConnection(BuildMasterConnectionString()))
            using (var command = connection.CreateCommand())
            {
                connection.Open();
                command.CommandText = "SELECT COUNT(1) FROM sys.databases WHERE name = @DatabaseName";
                command.Parameters.AddWithValue("@DatabaseName", databaseName);

                if (Convert.ToInt32(command.ExecuteScalar()) > 0)
                {
                    return false;
                }

                command.Parameters.Clear();
                command.CommandText = $@"
CREATE DATABASE [{databaseName}]
ON PRIMARY (
    NAME = N'{databaseName}',
    FILENAME = N'{EscapeSqlLiteral(mdfPath)}'
)
LOG ON (
    NAME = N'{databaseName}_log',
    FILENAME = N'{EscapeSqlLiteral(ldfPath)}'
);";
                command.ExecuteNonQuery();
                return true;
            }
        }

        private static bool HasRequiredSchema(string databaseName)
        {
            var requiredTables = new[]
            {
                "Users",
                "Scripts",
                "Sessions",
                "Reservations",
                "GameStages",
                "SessionGameStates",
                "SessionVotes",
                "ShowcasePages"
            };

            using (var connection = new SqlConnection(BuildDatabaseConnectionString(databaseName)))
            using (var command = connection.CreateCommand())
            {
                connection.Open();
                foreach (var tableName in requiredTables)
                {
                    command.CommandText = "SELECT COUNT(1) FROM sys.tables WHERE name = @TableName";
                    command.Parameters.Clear();
                    command.Parameters.AddWithValue("@TableName", tableName);

                    if (Convert.ToInt32(command.ExecuteScalar()) == 0)
                    {
                        return false;
                    }
                }
            }

            return true;
        }

        private static void EnsureIncrementalFeatures(string databaseName)
        {
            const string sql = @"
IF COL_LENGTH('dbo.Users', 'GiftBalance') IS NULL
BEGIN
    ALTER TABLE dbo.Users
    ADD GiftBalance INT NOT NULL CONSTRAINT DF_Users_GiftBalance DEFAULT(0);
END;

IF OBJECT_ID('dbo.ScriptAssets', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ScriptAssets
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ScriptId INT NOT NULL,
        AssetType NVARCHAR(40) NOT NULL,
        Title NVARCHAR(200) NOT NULL,
        FileName NVARCHAR(260) NOT NULL,
        RelativePath NVARCHAR(500) NOT NULL,
        PublicUrl NVARCHAR(500) NOT NULL,
        FileExtension NVARCHAR(20) NOT NULL,
        FileSizeBytes BIGINT NOT NULL CONSTRAINT DF_ScriptAssets_FileSizeBytes DEFAULT(0),
        IsPrimary BIT NOT NULL CONSTRAINT DF_ScriptAssets_IsPrimary DEFAULT(0),
        SortOrder INT NOT NULL CONSTRAINT DF_ScriptAssets_SortOrder DEFAULT(0),
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_ScriptAssets_CreatedAt DEFAULT(GETDATE())
    );

    ALTER TABLE dbo.ScriptAssets
    ADD CONSTRAINT FK_ScriptAssets_Scripts FOREIGN KEY (ScriptId) REFERENCES dbo.Scripts(Id) ON DELETE CASCADE;

    CREATE INDEX IX_ScriptAssets_ScriptId ON dbo.ScriptAssets(ScriptId, SortOrder, Id);
END;

IF OBJECT_ID('dbo.GiftCatalog', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.GiftCatalog
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(50) NOT NULL,
        PriceInCoins INT NOT NULL,
        IconText NVARCHAR(20) NOT NULL,
        Summary NVARCHAR(200) NULL,
        SortOrder INT NOT NULL CONSTRAINT DF_GiftCatalog_SortOrder DEFAULT(0),
        IsActive BIT NOT NULL CONSTRAINT DF_GiftCatalog_IsActive DEFAULT(1)
    );
END;

IF OBJECT_ID('dbo.GiftWalletTransactions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.GiftWalletTransactions
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        TransactionType NVARCHAR(30) NOT NULL,
        CoinAmount INT NOT NULL,
        BalanceAfter INT NOT NULL,
        Summary NVARCHAR(200) NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_GiftWalletTransactions_CreatedAt DEFAULT(GETDATE())
    );
END;

IF OBJECT_ID('dbo.GiftTransactions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.GiftTransactions
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        SenderUserId INT NOT NULL,
        ReceiverUserId INT NOT NULL,
        GiftId INT NOT NULL,
        Quantity INT NOT NULL,
        UnitPrice INT NOT NULL,
        TotalCoins INT NOT NULL,
        Summary NVARCHAR(200) NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_GiftTransactions_CreatedAt DEFAULT(GETDATE())
    );
END;

IF OBJECT_ID('dbo.FriendRequests', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FriendRequests
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        SenderUserId INT NOT NULL,
        ReceiverUserId INT NOT NULL,
        RequestMessage NVARCHAR(200) NULL,
        Status NVARCHAR(20) NOT NULL CONSTRAINT DF_FriendRequests_Status DEFAULT(N'Pending'),
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_FriendRequests_CreatedAt DEFAULT(GETDATE()),
        ReviewedAt DATETIME NULL
    );
END;

IF OBJECT_ID('dbo.Friendships', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Friendships
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        FriendUserId INT NOT NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_Friendships_CreatedAt DEFAULT(GETDATE())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_Friendships_User_Friend' AND object_id = OBJECT_ID('dbo.Friendships'))
BEGIN
    CREATE UNIQUE INDEX UX_Friendships_User_Friend ON dbo.Friendships(UserId, FriendUserId);
END;

IF OBJECT_ID('dbo.FriendConversationPreferences', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FriendConversationPreferences
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        FriendUserId INT NOT NULL,
        IsPinned BIT NOT NULL CONSTRAINT DF_FriendConversationPreferences_IsPinned DEFAULT(0),
        IsHidden BIT NOT NULL CONSTRAINT DF_FriendConversationPreferences_IsHidden DEFAULT(0),
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_FriendConversationPreferences_CreatedAt DEFAULT(GETDATE()),
        UpdatedAt DATETIME NOT NULL CONSTRAINT DF_FriendConversationPreferences_UpdatedAt DEFAULT(GETDATE())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_FriendConversationPreferences_User_Friend' AND object_id = OBJECT_ID('dbo.FriendConversationPreferences'))
BEGIN
    CREATE UNIQUE INDEX UX_FriendConversationPreferences_User_Friend ON dbo.FriendConversationPreferences(UserId, FriendUserId);
END;

IF COL_LENGTH('dbo.PlayerProfiles', 'Gender') IS NULL
BEGIN
    ALTER TABLE dbo.PlayerProfiles ADD Gender NVARCHAR(20) NULL;
END;

IF COL_LENGTH('dbo.PlayerProfiles', 'Region') IS NULL
BEGIN
    ALTER TABLE dbo.PlayerProfiles ADD Region NVARCHAR(80) NULL;
END;

IF COL_LENGTH('dbo.PlayerProfiles', 'Signature') IS NULL
BEGIN
    ALTER TABLE dbo.PlayerProfiles ADD Signature NVARCHAR(200) NULL;
END;

IF OBJECT_ID('dbo.ChatGroups', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ChatGroups
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(80) NOT NULL,
        OwnerUserId INT NOT NULL,
        AvatarUrl NVARCHAR(300) NULL,
        Announcement NVARCHAR(200) NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_ChatGroups_CreatedAt DEFAULT(GETDATE())
    );
END;

IF OBJECT_ID('dbo.ChatGroupMembers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ChatGroupMembers
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        GroupId INT NOT NULL,
        UserId INT NOT NULL,
        DisplayOrder INT NOT NULL CONSTRAINT DF_ChatGroupMembers_DisplayOrder DEFAULT(0),
        JoinedAt DATETIME NOT NULL CONSTRAINT DF_ChatGroupMembers_JoinedAt DEFAULT(GETDATE())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_ChatGroupMembers_Group_User' AND object_id = OBJECT_ID('dbo.ChatGroupMembers'))
BEGIN
    CREATE UNIQUE INDEX UX_ChatGroupMembers_Group_User ON dbo.ChatGroupMembers(GroupId, UserId);
END;

IF OBJECT_ID('dbo.GroupMessages', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.GroupMessages
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        GroupId INT NOT NULL,
        SenderUserId INT NOT NULL,
        MessageType NVARCHAR(20) NOT NULL CONSTRAINT DF_GroupMessages_MessageType DEFAULT(N'Text'),
        Content NVARCHAR(500) NULL,
        AttachmentUrl NVARCHAR(300) NULL,
        LocationText NVARCHAR(120) NULL,
        IsRevoked BIT NOT NULL CONSTRAINT DF_GroupMessages_IsRevoked DEFAULT(0),
        RevokedAt DATETIME NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_GroupMessages_CreatedAt DEFAULT(GETDATE())
    );
END;

IF OBJECT_ID('dbo.GroupConversationPreferences', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.GroupConversationPreferences
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        GroupId INT NOT NULL,
        IsPinned BIT NOT NULL CONSTRAINT DF_GroupConversationPreferences_IsPinned DEFAULT(0),
        IsHidden BIT NOT NULL CONSTRAINT DF_GroupConversationPreferences_IsHidden DEFAULT(0),
        IsMuted BIT NOT NULL CONSTRAINT DF_GroupConversationPreferences_IsMuted DEFAULT(0),
        LastReadGroupMessageId INT NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_GroupConversationPreferences_CreatedAt DEFAULT(GETDATE()),
        UpdatedAt DATETIME NOT NULL CONSTRAINT DF_GroupConversationPreferences_UpdatedAt DEFAULT(GETDATE())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_GroupConversationPreferences_User_Group' AND object_id = OBJECT_ID('dbo.GroupConversationPreferences'))
BEGIN
    CREATE UNIQUE INDEX UX_GroupConversationPreferences_User_Group ON dbo.GroupConversationPreferences(UserId, GroupId);
END;

IF OBJECT_ID('dbo.UserQuickNotes', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.UserQuickNotes
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        Title NVARCHAR(80) NOT NULL,
        Content NVARCHAR(600) NOT NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_UserQuickNotes_CreatedAt DEFAULT(GETDATE()),
        UpdatedAt DATETIME NOT NULL CONSTRAINT DF_UserQuickNotes_UpdatedAt DEFAULT(GETDATE())
    );
END;

IF OBJECT_ID('dbo.UserDesktopSettings', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.UserDesktopSettings
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        LoginConfirmMode NVARCHAR(30) NOT NULL CONSTRAINT DF_UserDesktopSettings_LoginConfirmMode DEFAULT(N'MobileConfirm'),
        KeepChatHistory BIT NOT NULL CONSTRAINT DF_UserDesktopSettings_KeepChatHistory DEFAULT(1),
        StoragePath NVARCHAR(260) NULL,
        AutoDownloadMaxMb INT NOT NULL CONSTRAINT DF_UserDesktopSettings_AutoDownloadMaxMb DEFAULT(20),
        NotificationEnabled BIT NOT NULL CONSTRAINT DF_UserDesktopSettings_NotificationEnabled DEFAULT(1),
        ShortcutScheme NVARCHAR(40) NOT NULL CONSTRAINT DF_UserDesktopSettings_ShortcutScheme DEFAULT(N'Default'),
        PluginEnabled BIT NOT NULL CONSTRAINT DF_UserDesktopSettings_PluginEnabled DEFAULT(1),
        FriendRequestEnabled BIT NOT NULL CONSTRAINT DF_UserDesktopSettings_FriendRequestEnabled DEFAULT(1),
        PhoneSearchEnabled BIT NOT NULL CONSTRAINT DF_UserDesktopSettings_PhoneSearchEnabled DEFAULT(0),
        ShowMomentsToStrangers BIT NOT NULL CONSTRAINT DF_UserDesktopSettings_ShowMomentsToStrangers DEFAULT(0),
        UseEnterToSend BIT NOT NULL CONSTRAINT DF_UserDesktopSettings_UseEnterToSend DEFAULT(0),
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_UserDesktopSettings_CreatedAt DEFAULT(GETDATE()),
        UpdatedAt DATETIME NOT NULL CONSTRAINT DF_UserDesktopSettings_UpdatedAt DEFAULT(GETDATE())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_UserDesktopSettings_User' AND object_id = OBJECT_ID('dbo.UserDesktopSettings'))
BEGIN
    CREATE UNIQUE INDEX UX_UserDesktopSettings_User ON dbo.UserDesktopSettings(UserId);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.GiftCatalog)
BEGIN
    INSERT INTO dbo.GiftCatalog(Name, PriceInCoins, IconText, Summary, SortOrder, IsActive)
    VALUES
    (N'玫瑰花束', 66, N'玫瑰', N'适合感谢推理搭档或向好友表达鼓励。', 1, 1),
    (N'侦探徽章', 120, N'徽章', N'送给本局高光玩家的进阶礼物。', 2, 1),
    (N'灵感灯泡', 188, N'灯泡', N'用于夸奖还原关键时间线的玩家。', 3, 1),
    (N'舞台聚光灯', 288, N'聚光', N'适合送给带飞全场的核心发言位。', 4, 1),
    (N'悬疑王冠', 520, N'王冠', N'高价值礼物，用于剧本房高光时刻。', 5, 1),
    (N'星幕城堡', 1314, N'城堡', N'全站稀有礼物，适合答辩演示互动收入。', 6, 1);
END;

IF OBJECT_ID('dbo.FriendMessages', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FriendMessages
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        SenderUserId INT NOT NULL,
        ReceiverUserId INT NOT NULL,
        MessageType NVARCHAR(20) NOT NULL CONSTRAINT DF_FriendMessages_MessageType DEFAULT(N'Text'),
        Content NVARCHAR(400) NULL,
        AttachmentUrl NVARCHAR(300) NULL,
        LocationText NVARCHAR(120) NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_FriendMessages_CreatedAt DEFAULT(GETDATE())
    );
END;

IF COL_LENGTH('dbo.FriendMessages', 'IsRead') IS NULL
BEGIN
    ALTER TABLE dbo.FriendMessages
    ADD IsRead BIT NOT NULL CONSTRAINT DF_FriendMessages_IsRead DEFAULT(0);
END;

IF COL_LENGTH('dbo.FriendMessages', 'IsRevoked') IS NULL
BEGIN
    ALTER TABLE dbo.FriendMessages
    ADD IsRevoked BIT NOT NULL CONSTRAINT DF_FriendMessages_IsRevoked DEFAULT(0);
END;

IF COL_LENGTH('dbo.FriendMessages', 'RevokedAt') IS NULL
BEGIN
    ALTER TABLE dbo.FriendMessages
    ADD RevokedAt DATETIME NULL;
END;

IF OBJECT_ID('dbo.FriendMoments', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FriendMoments
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        Content NVARCHAR(600) NULL,
        ImageUrl NVARCHAR(300) NULL,
        LocationText NVARCHAR(120) NULL,
        Visibility NVARCHAR(20) NOT NULL CONSTRAINT DF_FriendMoments_Visibility DEFAULT(N'Friends'),
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_FriendMoments_CreatedAt DEFAULT(GETDATE())
    );
END;

IF OBJECT_ID('dbo.MomentLikes', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.MomentLikes
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        MomentId INT NOT NULL,
        UserId INT NOT NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_MomentLikes_CreatedAt DEFAULT(GETDATE())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_MomentLikes_Moment_User' AND object_id = OBJECT_ID('dbo.MomentLikes'))
BEGIN
    CREATE UNIQUE INDEX UX_MomentLikes_Moment_User ON dbo.MomentLikes(MomentId, UserId);
END;

IF OBJECT_ID('dbo.MomentComments', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.MomentComments
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        MomentId INT NOT NULL,
        UserId INT NOT NULL,
        Content NVARCHAR(300) NOT NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_MomentComments_CreatedAt DEFAULT(GETDATE())
    );
END;

IF COL_LENGTH('dbo.MomentComments', 'ParentCommentId') IS NULL
BEGIN
    ALTER TABLE dbo.MomentComments
    ADD ParentCommentId INT NULL;
END;

IF OBJECT_ID('dbo.FriendMoneyTransfers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FriendMoneyTransfers
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        SenderUserId INT NOT NULL,
        ReceiverUserId INT NOT NULL,
        MessageId INT NULL,
        TransferType NVARCHAR(20) NOT NULL,
        Amount DECIMAL(10,2) NOT NULL,
        Note NVARCHAR(200) NULL,
        Status NVARCHAR(20) NOT NULL CONSTRAINT DF_FriendMoneyTransfers_Status DEFAULT(N'Claimed'),
        ClaimedAt DATETIME NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_FriendMoneyTransfers_CreatedAt DEFAULT(GETDATE())
    );
END;

IF COL_LENGTH('dbo.FriendMoneyTransfers', 'MessageId') IS NULL
BEGIN
    ALTER TABLE dbo.FriendMoneyTransfers
    ADD MessageId INT NULL;
END;

IF COL_LENGTH('dbo.FriendMoneyTransfers', 'Status') IS NULL
BEGIN
    ALTER TABLE dbo.FriendMoneyTransfers
    ADD Status NVARCHAR(20) NOT NULL CONSTRAINT DF_FriendMoneyTransfers_Status DEFAULT(N'Claimed');
END;

IF COL_LENGTH('dbo.FriendMoneyTransfers', 'ClaimedAt') IS NULL
BEGIN
    ALTER TABLE dbo.FriendMoneyTransfers
    ADD ClaimedAt DATETIME NULL;
END;

EXEC(N'UPDATE dbo.FriendMoneyTransfers
SET Status = N''Claimed'',
    ClaimedAt = ISNULL(ClaimedAt, CreatedAt)
WHERE ISNULL(Status, N'''') = N'''';');

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FriendMoneyTransfers_MessageId' AND object_id = OBJECT_ID('dbo.FriendMoneyTransfers'))
BEGIN
    EXEC(N'CREATE INDEX IX_FriendMoneyTransfers_MessageId ON dbo.FriendMoneyTransfers(MessageId);');
END;

EXEC(N'
UPDATE fmt
SET MessageId = matched.MessageId
FROM dbo.FriendMoneyTransfers fmt
CROSS APPLY
(
    SELECT TOP 1 fm.Id AS MessageId
    FROM dbo.FriendMessages fm
    WHERE fm.SenderUserId = fmt.SenderUserId
      AND fm.ReceiverUserId = fmt.ReceiverUserId
      AND fm.MessageType = fmt.TransferType
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.FriendMoneyTransfers used
          WHERE used.MessageId = fm.Id
            AND used.Id <> fmt.Id
      )
    ORDER BY ABS(DATEDIFF(SECOND, fm.CreatedAt, fmt.CreatedAt)), fm.Id
) matched
WHERE fmt.MessageId IS NULL;');

IF OBJECT_ID('dbo.UserBlocks', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.UserBlocks
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        BlockedUserId INT NOT NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_UserBlocks_CreatedAt DEFAULT(GETDATE())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_UserBlocks_User_Blocked' AND object_id = OBJECT_ID('dbo.UserBlocks'))
BEGIN
    CREATE UNIQUE INDEX UX_UserBlocks_User_Blocked ON dbo.UserBlocks(UserId, BlockedUserId);
END;

IF OBJECT_ID('dbo.StoreVisitRequests', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.StoreVisitRequests
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NULL,
        ScriptId INT NULL,
        ContactName NVARCHAR(50) NOT NULL,
        Phone NVARCHAR(30) NOT NULL,
        PreferredArriveTime DATETIME NOT NULL,
        TeamSize INT NOT NULL,
        RequestStatus NVARCHAR(30) NOT NULL CONSTRAINT DF_StoreVisitRequests_RequestStatus DEFAULT(N'待门店联系'),
        Note NVARCHAR(300) NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_StoreVisitRequests_CreatedAt DEFAULT(GETDATE())
    );
END;

IF COL_LENGTH('dbo.StoreVisitRequests', 'AssignedRoomName') IS NULL
BEGIN
    ALTER TABLE dbo.StoreVisitRequests
    ADD AssignedRoomName NVARCHAR(80) NULL;
END;

IF COL_LENGTH('dbo.StoreVisitRequests', 'AdminRemark') IS NULL
BEGIN
    ALTER TABLE dbo.StoreVisitRequests
    ADD AdminRemark NVARCHAR(300) NULL;
END;

IF COL_LENGTH('dbo.StoreVisitRequests', 'AdminReply') IS NULL
BEGIN
    ALTER TABLE dbo.StoreVisitRequests
    ADD AdminReply NVARCHAR(500) NULL;
END;

IF COL_LENGTH('dbo.StoreVisitRequests', 'ProcessedByUserId') IS NULL
BEGIN
    ALTER TABLE dbo.StoreVisitRequests
    ADD ProcessedByUserId INT NULL;
END;

IF COL_LENGTH('dbo.StoreVisitRequests', 'ProcessedAt') IS NULL
BEGIN
    ALTER TABLE dbo.StoreVisitRequests
    ADD ProcessedAt DATETIME NULL;
END;

IF COL_LENGTH('dbo.StoreVisitRequests', 'RepliedAt') IS NULL
BEGIN
    ALTER TABLE dbo.StoreVisitRequests
    ADD RepliedAt DATETIME NULL;
END;

IF COL_LENGTH('dbo.StoreVisitRequests', 'ConfirmStatus') IS NULL
BEGIN
    ALTER TABLE dbo.StoreVisitRequests
    ADD ConfirmStatus NVARCHAR(30) NULL;
END;

IF COL_LENGTH('dbo.StoreVisitRequests', 'PlayerConfirmRemark') IS NULL
BEGIN
    ALTER TABLE dbo.StoreVisitRequests
    ADD PlayerConfirmRemark NVARCHAR(300) NULL;
END;

IF COL_LENGTH('dbo.StoreVisitRequests', 'PlayerConfirmedAt') IS NULL
BEGIN
    ALTER TABLE dbo.StoreVisitRequests
    ADD PlayerConfirmedAt DATETIME NULL;
END;

IF COL_LENGTH('dbo.Reservations', 'AdminRemark') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations
    ADD AdminRemark NVARCHAR(300) NULL;
END;

IF COL_LENGTH('dbo.Reservations', 'AdminReply') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations
    ADD AdminReply NVARCHAR(500) NULL;
END;

IF COL_LENGTH('dbo.Reservations', 'ProcessedByUserId') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations
    ADD ProcessedByUserId INT NULL;
END;

IF COL_LENGTH('dbo.Reservations', 'ProcessedAt') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations
    ADD ProcessedAt DATETIME NULL;
END;

IF COL_LENGTH('dbo.Reservations', 'RepliedAt') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations
    ADD RepliedAt DATETIME NULL;
END;

IF COL_LENGTH('dbo.Reservations', 'ConfirmStatus') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations
    ADD ConfirmStatus NVARCHAR(30) NULL;
END;

IF COL_LENGTH('dbo.Reservations', 'PlayerConfirmRemark') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations
    ADD PlayerConfirmRemark NVARCHAR(300) NULL;
END;

IF COL_LENGTH('dbo.Reservations', 'PlayerConfirmedAt') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations
    ADD PlayerConfirmedAt DATETIME NULL;
END;

IF OBJECT_ID('dbo.AdminReplyLogs', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AdminReplyLogs
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        BusinessType NVARCHAR(30) NOT NULL,
        BusinessId INT NOT NULL,
        AdminUserId INT NULL,
        ReplyContent NVARCHAR(500) NOT NULL,
        VisibleToUser BIT NOT NULL CONSTRAINT DF_AdminReplyLogs_VisibleToUser DEFAULT(1),
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_AdminReplyLogs_CreatedAt DEFAULT(GETDATE())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AdminReplyLogs_Business' AND object_id = OBJECT_ID('dbo.AdminReplyLogs'))
BEGIN
    CREATE INDEX IX_AdminReplyLogs_Business ON dbo.AdminReplyLogs(BusinessType, BusinessId, CreatedAt DESC);
END;

IF OBJECT_ID('dbo.BusinessActionLogs', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.BusinessActionLogs
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        BusinessType NVARCHAR(30) NOT NULL,
        BusinessId INT NOT NULL,
        ActionType NVARCHAR(50) NOT NULL,
        ActionTitle NVARCHAR(100) NOT NULL,
        ActionContent NVARCHAR(500) NULL,
        OperatorUserId INT NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_BusinessActionLogs_CreatedAt DEFAULT(GETDATE())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_BusinessActionLogs_Business' AND object_id = OBJECT_ID('dbo.BusinessActionLogs'))
BEGIN
    CREATE INDEX IX_BusinessActionLogs_Business ON dbo.BusinessActionLogs(BusinessType, BusinessId, CreatedAt DESC);
END;

IF OBJECT_ID('dbo.AfterSaleRequests', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AfterSaleRequests
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        ReservationId INT NOT NULL,
        UserId INT NOT NULL,
        RequestType NVARCHAR(30) NOT NULL,
        Reason NVARCHAR(500) NOT NULL,
        RequestedAmount DECIMAL(10,2) NULL,
        Status NVARCHAR(30) NOT NULL CONSTRAINT DF_AfterSaleRequests_Status DEFAULT(N'待处理'),
        AdminReply NVARCHAR(500) NULL,
        AdminRemark NVARCHAR(300) NULL,
        EvidenceUrl NVARCHAR(500) NULL,
        RejectReason NVARCHAR(500) NULL,
        AppealReason NVARCHAR(500) NULL,
        AcceptedAt DATETIME NULL,
        RejectedAt DATETIME NULL,
        AppealedAt DATETIME NULL,
        ProcessedByUserId INT NULL,
        ProcessedAt DATETIME NULL,
        RefundTransactionId INT NULL,
        RefundedAmount DECIMAL(10,2) NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_AfterSaleRequests_CreatedAt DEFAULT(GETDATE())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AfterSaleRequests_Reservation' AND object_id = OBJECT_ID('dbo.AfterSaleRequests'))
BEGIN
    CREATE INDEX IX_AfterSaleRequests_Reservation ON dbo.AfterSaleRequests(ReservationId, CreatedAt DESC);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AfterSaleRequests_Status' AND object_id = OBJECT_ID('dbo.AfterSaleRequests'))
BEGIN
    CREATE INDEX IX_AfterSaleRequests_Status ON dbo.AfterSaleRequests(Status, CreatedAt DESC);
END;

IF COL_LENGTH('dbo.Reservations', 'CouponId') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations
    ADD CouponId INT NULL;
END;

IF COL_LENGTH('dbo.Reservations', 'DiscountAmount') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations
    ADD DiscountAmount DECIMAL(10,2) NOT NULL CONSTRAINT DF_Reservations_DiscountAmount DEFAULT(0);
END;

IF OBJECT_ID('dbo.UserCoupons', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.UserCoupons
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        Title NVARCHAR(80) NOT NULL,
        CouponType NVARCHAR(20) NOT NULL CONSTRAINT DF_UserCoupons_CouponType DEFAULT(N'Amount'),
        DiscountAmount DECIMAL(10,2) NOT NULL,
        MinSpend DECIMAL(10,2) NOT NULL CONSTRAINT DF_UserCoupons_MinSpend DEFAULT(0),
        Status NVARCHAR(20) NOT NULL CONSTRAINT DF_UserCoupons_Status DEFAULT(N'未使用'),
        Source NVARCHAR(80) NULL,
        IssuedByUserId INT NULL,
        IssuedAt DATETIME NOT NULL CONSTRAINT DF_UserCoupons_IssuedAt DEFAULT(GETDATE()),
        ValidFrom DATETIME NOT NULL CONSTRAINT DF_UserCoupons_ValidFrom DEFAULT(GETDATE()),
        ValidUntil DATETIME NOT NULL,
        UsedReservationId INT NULL,
        UsedAt DATETIME NULL
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_UserCoupons_UserStatus' AND object_id = OBJECT_ID('dbo.UserCoupons'))
BEGIN
    CREATE INDEX IX_UserCoupons_UserStatus ON dbo.UserCoupons(UserId, Status, ValidUntil);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_UserCoupons_Recent' AND object_id = OBJECT_ID('dbo.UserCoupons'))
BEGIN
    CREATE INDEX IX_UserCoupons_Recent ON dbo.UserCoupons(IssuedAt DESC, Id DESC);
END;

IF COL_LENGTH('dbo.Reviews', 'UserId') IS NULL
BEGIN
    ALTER TABLE dbo.Reviews
    ADD UserId INT NULL;
END;

IF COL_LENGTH('dbo.Reviews', 'ReservationId') IS NULL
BEGIN
    ALTER TABLE dbo.Reviews
    ADD ReservationId INT NULL;
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Reviews_UserReservation' AND object_id = OBJECT_ID('dbo.Reviews'))
BEGIN
    CREATE INDEX IX_Reviews_UserReservation ON dbo.Reviews(UserId, ReservationId);
END;

IF COL_LENGTH('dbo.Reviews', 'IsFeatured') IS NULL
BEGIN
    ALTER TABLE dbo.Reviews
    ADD IsFeatured BIT NOT NULL CONSTRAINT DF_Reviews_IsFeatured DEFAULT(0);
END;

IF COL_LENGTH('dbo.Reviews', 'IsHidden') IS NULL
BEGIN
    ALTER TABLE dbo.Reviews
    ADD IsHidden BIT NOT NULL CONSTRAINT DF_Reviews_IsHidden DEFAULT(0);
END;

IF COL_LENGTH('dbo.Reviews', 'AdminReply') IS NULL
BEGIN
    ALTER TABLE dbo.Reviews
    ADD AdminReply NVARCHAR(500) NULL;
END;

IF COL_LENGTH('dbo.Reservations', 'CheckInCode') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations
    ADD CheckInCode NVARCHAR(20) NULL;
END;

IF COL_LENGTH('dbo.Reservations', 'CheckedInAt') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations
    ADD CheckedInAt DATETIME NULL;
END;

IF COL_LENGTH('dbo.Reservations', 'CheckInByUserId') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations
    ADD CheckInByUserId INT NULL;
END;

IF EXISTS (SELECT 1 FROM dbo.Reservations WHERE CheckInCode IS NULL OR CheckInCode = N'')
BEGIN
    UPDATE dbo.Reservations
    SET CheckInCode = RIGHT(N'000000' + CONVERT(NVARCHAR(20), ABS(CHECKSUM(NEWID())) % 1000000), 6)
    WHERE CheckInCode IS NULL OR CheckInCode = N'';
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Reservations_CheckInCode' AND object_id = OBJECT_ID('dbo.Reservations'))
BEGIN
    CREATE INDEX IX_Reservations_CheckInCode ON dbo.Reservations(CheckInCode, Status);
END;

IF OBJECT_ID('dbo.ReservationWaitlists', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ReservationWaitlists
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        SessionId INT NOT NULL,
        UserId INT NOT NULL,
        ContactName NVARCHAR(50) NOT NULL,
        Phone NVARCHAR(30) NOT NULL,
        PlayerCount INT NOT NULL,
        Note NVARCHAR(300) NULL,
        Status NVARCHAR(20) NOT NULL CONSTRAINT DF_ReservationWaitlists_Status DEFAULT(N'Pending'),
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_ReservationWaitlists_CreatedAt DEFAULT(GETDATE())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ReservationWaitlists_UserStatus' AND object_id = OBJECT_ID('dbo.ReservationWaitlists'))
BEGIN
    CREATE INDEX IX_ReservationWaitlists_UserStatus ON dbo.ReservationWaitlists(UserId, Status, CreatedAt DESC);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ReservationWaitlists_SessionStatus' AND object_id = OBJECT_ID('dbo.ReservationWaitlists'))
BEGIN
    CREATE INDEX IX_ReservationWaitlists_SessionStatus ON dbo.ReservationWaitlists(SessionId, Status, CreatedAt DESC);
END;

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ReservationWaitlists_Sessions')
BEGIN
    ALTER TABLE dbo.ReservationWaitlists
    ADD CONSTRAINT FK_ReservationWaitlists_Sessions FOREIGN KEY (SessionId) REFERENCES dbo.Sessions(Id);
END;

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ReservationWaitlists_Users')
BEGIN
    ALTER TABLE dbo.ReservationWaitlists
    ADD CONSTRAINT FK_ReservationWaitlists_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id);
END;

IF COL_LENGTH('dbo.RechargeRequests', 'RechargeOrderNo') IS NULL
BEGIN
    ALTER TABLE dbo.RechargeRequests
    ADD RechargeOrderNo NVARCHAR(32) NULL;
END;

EXEC(N'UPDATE dbo.RechargeRequests
SET RechargeOrderNo = N''RC'' + CONVERT(NVARCHAR(8), ISNULL(SubmittedAt, GETDATE()), 112)
    + RIGHT(REPLACE(CONVERT(NVARCHAR(36), NEWID()), N''-'', N''''), 8)
WHERE ISNULL(RechargeOrderNo, N'''') = N'''';');

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_RechargeRequests_RechargeOrderNo' AND object_id = OBJECT_ID('dbo.RechargeRequests'))
BEGIN
    EXEC(N'CREATE UNIQUE INDEX UX_RechargeRequests_RechargeOrderNo ON dbo.RechargeRequests(RechargeOrderNo) WHERE RechargeOrderNo IS NOT NULL;');
END;

IF OBJECT_ID('dbo.UserLoginSecurityLogs', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.UserLoginSecurityLogs
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NULL,
        Username NVARCHAR(50) NOT NULL,
        ResultType NVARCHAR(30) NOT NULL,
        IpAddress NVARCHAR(80) NULL,
        UserAgent NVARCHAR(500) NULL,
        Detail NVARCHAR(300) NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_UserLoginSecurityLogs_CreatedAt DEFAULT(GETDATE())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_UserLoginSecurityLogs_User_CreatedAt' AND object_id = OBJECT_ID('dbo.UserLoginSecurityLogs'))
BEGIN
    CREATE INDEX IX_UserLoginSecurityLogs_User_CreatedAt ON dbo.UserLoginSecurityLogs(UserId, CreatedAt DESC);
END;

IF OBJECT_ID('dbo.PasswordResetTickets', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PasswordResetTickets
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        TicketCode NVARCHAR(30) NOT NULL,
        ExpiresAt DATETIME NOT NULL,
        IsUsed BIT NOT NULL CONSTRAINT DF_PasswordResetTickets_IsUsed DEFAULT(0),
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_PasswordResetTickets_CreatedAt DEFAULT(GETDATE()),
        UsedAt DATETIME NULL
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_PasswordResetTickets_Code' AND object_id = OBJECT_ID('dbo.PasswordResetTickets'))
BEGIN
    CREATE UNIQUE INDEX UX_PasswordResetTickets_Code ON dbo.PasswordResetTickets(TicketCode);
END;

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_PasswordResetTickets_Users')
BEGIN
    ALTER TABLE dbo.PasswordResetTickets
    ADD CONSTRAINT FK_PasswordResetTickets_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id);
END;

IF OBJECT_ID('dbo.UserProfileChangeLogs', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.UserProfileChangeLogs
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        FieldName NVARCHAR(50) NOT NULL,
        BeforeValue NVARCHAR(1000) NULL,
        AfterValue NVARCHAR(1000) NULL,
        ChangedAt DATETIME NOT NULL CONSTRAINT DF_UserProfileChangeLogs_ChangedAt DEFAULT(GETDATE())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_UserProfileChangeLogs_User_ChangedAt' AND object_id = OBJECT_ID('dbo.UserProfileChangeLogs'))
BEGIN
    CREATE INDEX IX_UserProfileChangeLogs_User_ChangedAt ON dbo.UserProfileChangeLogs(UserId, ChangedAt DESC);
END;

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_UserProfileChangeLogs_Users')
BEGIN
    ALTER TABLE dbo.UserProfileChangeLogs
    ADD CONSTRAINT FK_UserProfileChangeLogs_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id);
END;

IF COL_LENGTH('dbo.Sessions', 'HostUserId') IS NULL
BEGIN
    ALTER TABLE dbo.Sessions
    ADD HostUserId INT NULL;
END;

IF COL_LENGTH('dbo.Sessions', 'HostBriefing') IS NULL
BEGIN
    ALTER TABLE dbo.Sessions
    ADD HostBriefing NVARCHAR(500) NULL;
END;

IF COL_LENGTH('dbo.Sessions', 'HostAcceptedAt') IS NULL
BEGIN
    ALTER TABLE dbo.Sessions
    ADD HostAcceptedAt DATETIME NULL;
END;

IF OBJECT_ID('dbo.ServiceMessages', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ServiceMessages
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        BusinessType NVARCHAR(30) NOT NULL,
        BusinessId INT NOT NULL,
        SenderUserId INT NOT NULL,
        SenderRole NVARCHAR(20) NOT NULL,
        Content NVARCHAR(800) NOT NULL,
        IsReadByAdmin BIT NOT NULL CONSTRAINT DF_ServiceMessages_IsReadByAdmin DEFAULT(0),
        IsReadByUser BIT NOT NULL CONSTRAINT DF_ServiceMessages_IsReadByUser DEFAULT(0),
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_ServiceMessages_CreatedAt DEFAULT(GETDATE())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServiceMessages_Business' AND object_id = OBJECT_ID('dbo.ServiceMessages'))
BEGIN
    CREATE INDEX IX_ServiceMessages_Business ON dbo.ServiceMessages(BusinessType, BusinessId, CreatedAt DESC);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServiceMessages_UnreadAdmin' AND object_id = OBJECT_ID('dbo.ServiceMessages'))
BEGIN
    CREATE INDEX IX_ServiceMessages_UnreadAdmin ON dbo.ServiceMessages(IsReadByAdmin, CreatedAt DESC);
END;

IF OBJECT_ID('dbo.UserNotificationReads', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.UserNotificationReads
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        NotificationKey NVARCHAR(200) NOT NULL,
        ReadAt DATETIME NOT NULL CONSTRAINT DF_UserNotificationReads_ReadAt DEFAULT(GETDATE())
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_UserNotificationReads_UserKey' AND object_id = OBJECT_ID('dbo.UserNotificationReads'))
BEGIN
    CREATE UNIQUE INDEX UX_UserNotificationReads_UserKey ON dbo.UserNotificationReads(UserId, NotificationKey);
END;

IF OBJECT_ID('dbo.DownloadOptions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DownloadOptions
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        PlatformName NVARCHAR(40) NOT NULL,
        PlatformCode NVARCHAR(40) NOT NULL,
        IconText NVARCHAR(20) NOT NULL,
        VersionText NVARCHAR(80) NOT NULL,
        Summary NVARCHAR(200) NOT NULL,
        DownloadUrl NVARCHAR(500) NOT NULL,
        ReleaseDate DATETIME NOT NULL,
        SortOrder INT NOT NULL CONSTRAINT DF_DownloadOptions_SortOrder DEFAULT(0),
        IsActive BIT NOT NULL CONSTRAINT DF_DownloadOptions_IsActive DEFAULT(1)
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DownloadOptions_ActiveSort' AND object_id = OBJECT_ID('dbo.DownloadOptions'))
BEGIN
    CREATE INDEX IX_DownloadOptions_ActiveSort ON dbo.DownloadOptions(IsActive, SortOrder, Id);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.DownloadOptions)
BEGIN
    INSERT INTO dbo.DownloadOptions(PlatformName, PlatformCode, IconText, VersionText, Summary, DownloadUrl, ReleaseDate, SortOrder, IsActive)
    VALUES
    (N'Android', N'android', N'安卓', N'玩家端 1.0 for Android', N'适合安卓手机玩家，下载后可查看剧本、预约和到店信息。', N'Download.aspx?platform=android', '2026-04-18', 1, 1),
    (N'iOS', N'ios', N'iOS', N'玩家端 1.0 for iOS', N'适合苹果手机玩家，支持玩家中心、好友互动和预约查看。', N'Download.aspx?platform=ios', '2026-04-18', 2, 1),
    (N'HarmonyOS', N'harmony', N'HM', N'玩家端 1.0 for HarmonyOS', N'适合鸿蒙设备玩家，保留移动端核心体验。', N'Download.aspx?platform=harmony', '2026-04-18', 3, 1),
    (N'Windows', N'windows', N'WIN', N'桌面端 1.0 for Windows', N'适合门店电脑和玩家桌面端访问，方便开本前查看资料。', N'Download.aspx?platform=windows', '2026-04-18', 4, 1),
    (N'macOS', N'macos', N'MAC', N'桌面端 1.0 for macOS', N'适合 macOS 玩家，支持网页端直接访问和资料浏览。', N'Download.aspx?platform=macos', '2026-04-18', 5, 1),
    (N'网页版', N'web', N'WEB', N'玩家网页版', N'无需安装，直接进入系统使用在线预约、好友和玩家中心。', N'Default.aspx', '2026-04-18', 6, 1);
END;

DECLARE @DemoPasswordHash NVARCHAR(64) = N'8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92';

MERGE dbo.Users AS target
USING
(
    VALUES
    (N'user1', N'玩家 1 号', N'user1@dm.local', N'13800001001'),
    (N'user2', N'玩家 2 号', N'user2@dm.local', N'13800001002'),
    (N'user3', N'玩家 3 号', N'user3@dm.local', N'13800001003'),
    (N'user4', N'玩家 4 号', N'user4@dm.local', N'13800001004'),
    (N'user5', N'玩家 5 号', N'user5@dm.local', N'13800001005'),
    (N'user6', N'玩家 6 号', N'user6@dm.local', N'13800001006')
) AS src(Username, DisplayName, Email, Phone)
ON target.Username = src.Username
WHEN MATCHED THEN
    UPDATE SET
        PasswordHash = @DemoPasswordHash,
        DisplayName = src.DisplayName,
        Email = src.Email,
        Phone = src.Phone,
        RoleCode = N'Player',
        ReviewStatus = N'Approved',
        ReviewRemark = N'门店联机演示账号',
        ReviewedAt = ISNULL(target.ReviewedAt, GETDATE()),
        Balance = CASE WHEN target.Balance < 600 THEN 1200 ELSE target.Balance END
WHEN NOT MATCHED THEN
    INSERT
    (
        Username,
        PasswordHash,
        DisplayName,
        Email,
        Phone,
        RoleCode,
        ReviewStatus,
        ReviewRemark,
        Balance,
        CreatedAt,
        ReviewedAt
    )
    VALUES
    (
        src.Username,
        @DemoPasswordHash,
        src.DisplayName,
        src.Email,
        src.Phone,
        N'Player',
        N'Approved',
        N'门店联机演示账号',
        1200,
        GETDATE(),
        GETDATE()
    );

DECLARE @DemoScriptId INT;
DECLARE @DemoRoomId INT;
DECLARE @DemoSessionId INT;

SELECT TOP 1 @DemoScriptId = Id
FROM dbo.Scripts
WHERE Name = N'潮声熄灯时'
  AND AuditStatus = N'Approved'
ORDER BY Id DESC;

SELECT TOP 1 @DemoRoomId = Id
FROM dbo.Rooms
WHERE Name LIKE N'%长夜%'
ORDER BY Id ASC;

IF @DemoScriptId IS NOT NULL AND @DemoRoomId IS NOT NULL
BEGIN
    SELECT TOP 1 @DemoSessionId = Id
    FROM dbo.Sessions
    WHERE ScriptId = @DemoScriptId
      AND RoomId = @DemoRoomId
      AND HostName = N'门店 DM 阿岚'
      AND SessionDateTime = '2026-04-18T19:30:00';

    IF @DemoSessionId IS NULL
    BEGIN
        INSERT INTO dbo.Sessions
        (
            ScriptId,
            RoomId,
            SessionDateTime,
            HostName,
            BasePrice,
            MaxPlayers,
            Status
        )
        VALUES
        (
            @DemoScriptId,
            @DemoRoomId,
            '2026-04-18T19:30:00',
            N'门店 DM 阿岚',
            228.00,
            6,
            N'开放预约'
        );

        SET @DemoSessionId = SCOPE_IDENTITY();
    END;

    DECLARE @SeedUsers TABLE
    (
        SortOrder INT NOT NULL,
        Username NVARCHAR(30) NOT NULL,
        UserId INT NOT NULL,
        DisplayName NVARCHAR(50) NOT NULL,
        Phone NVARCHAR(30) NOT NULL
    );

    INSERT INTO @SeedUsers(SortOrder, Username, UserId, DisplayName, Phone)
    SELECT
        CASE Username
            WHEN N'user1' THEN 1
            WHEN N'user2' THEN 2
            WHEN N'user3' THEN 3
            WHEN N'user4' THEN 4
            WHEN N'user5' THEN 5
            ELSE 6
        END,
        Username,
        Id,
        DisplayName,
        Phone
    FROM dbo.Users
    WHERE Username IN (N'user1', N'user2', N'user3', N'user4', N'user5', N'user6');

    DECLARE @SortOrder INT;
    DECLARE @UserId INT;
    DECLARE @DisplayName NVARCHAR(50);
    DECLARE @Phone NVARCHAR(30);
    DECLARE @WalletTransactionId INT;
    DECLARE @BalanceAfter DECIMAL(10,2);

    DECLARE user_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT SortOrder, UserId, DisplayName, Phone
    FROM @SeedUsers
    ORDER BY SortOrder ASC;

    OPEN user_cursor;
    FETCH NEXT FROM user_cursor INTO @SortOrder, @UserId, @DisplayName, @Phone;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.Reservations WHERE SessionId = @DemoSessionId AND UserId = @UserId)
        BEGIN
            UPDATE dbo.Users
            SET Balance = Balance - 228.00
            WHERE Id = @UserId
              AND Balance >= 228.00;

            SELECT @BalanceAfter = Balance
            FROM dbo.Users
            WHERE Id = @UserId;

            INSERT INTO dbo.WalletTransactions(UserId, TransactionType, Amount, BalanceAfter, Summary, CreatedAt)
            VALUES(@UserId, N'线下门店开本预订', 228.00, ISNULL(@BalanceAfter, 0), N'6 人同房演示场次《潮声熄灯时》预约扣费', GETDATE());

            SET @WalletTransactionId = SCOPE_IDENTITY();

            INSERT INTO dbo.Reservations
            (
                SessionId,
                UserId,
                ContactName,
                Phone,
                PlayerCount,
                UnitPrice,
                TotalAmount,
                PaymentStatus,
                PaymentTransactionId,
                Remark,
                CreatedAt,
                Status
            )
            VALUES
            (
                @DemoSessionId,
                @UserId,
                @DisplayName,
                @Phone,
                1,
                228.00,
                228.00,
                N'已支付',
                @WalletTransactionId,
                N'系统已为 6 位演示玩家创建同房开本数据',
                GETDATE(),
                N'已确认'
            );
        END;

        FETCH NEXT FROM user_cursor INTO @SortOrder, @UserId, @DisplayName, @Phone;
    END;

    CLOSE user_cursor;
    DEALLOCATE user_cursor;

    INSERT INTO dbo.StoreVisitRequests(UserId, ScriptId, ContactName, Phone, PreferredArriveTime, TeamSize, RequestStatus, Note, CreatedAt)
    SELECT
        su.UserId,
        @DemoScriptId,
        su.DisplayName,
        su.Phone,
        '2026-04-18T18:45:00',
        6,
        N'门店已排期',
        N'6 位演示玩家统一到店，已在线选本并完成支付。',
        GETDATE()
    FROM
    (
        SELECT TOP 1 UserId, DisplayName, Phone
        FROM @SeedUsers
        ORDER BY SortOrder ASC
    ) su
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.StoreVisitRequests r
        WHERE r.UserId = su.UserId
          AND r.ScriptId = @DemoScriptId
          AND r.PreferredArriveTime = '2026-04-18T18:45:00'
    );
END;

IF NOT EXISTS (SELECT 1 FROM dbo.FriendMessages)
   AND (SELECT COUNT(1) FROM dbo.Users WHERE ReviewStatus = N'Approved') >= 2
BEGIN
    DECLARE @SeedUserA INT;
    DECLARE @SeedUserB INT;

    SELECT TOP 1 @SeedUserA = Id
    FROM dbo.Users
    WHERE ReviewStatus = N'Approved'
    ORDER BY CASE WHEN Username = N'demo0408book' THEN 0 WHEN Username = N'admin' THEN 1 ELSE 2 END, Id ASC;

    SELECT TOP 1 @SeedUserB = Id
    FROM dbo.Users
    WHERE ReviewStatus = N'Approved'
      AND Id <> @SeedUserA
    ORDER BY CASE WHEN Username = N'admin' THEN 0 ELSE 1 END, Id ASC;

    IF @SeedUserA IS NOT NULL AND @SeedUserB IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.Friendships WHERE UserId = @SeedUserA AND FriendUserId = @SeedUserB)
        BEGIN
            INSERT INTO dbo.Friendships(UserId, FriendUserId, CreatedAt) VALUES(@SeedUserA, @SeedUserB, GETDATE());
        END;

        IF NOT EXISTS (SELECT 1 FROM dbo.Friendships WHERE UserId = @SeedUserB AND FriendUserId = @SeedUserA)
        BEGIN
            INSERT INTO dbo.Friendships(UserId, FriendUserId, CreatedAt) VALUES(@SeedUserB, @SeedUserA, GETDATE());
        END;

        INSERT INTO dbo.FriendMessages(SenderUserId, ReceiverUserId, MessageType, Content, AttachmentUrl, LocationText, CreatedAt)
        VALUES
        (@SeedUserA, @SeedUserB, N'Text', N'今晚《潮声熄灯时》要不要一起开车？', NULL, NULL, DATEADD(MINUTE, -40, GETDATE())),
        (@SeedUserB, @SeedUserA, N'Location', N'我已经到店了，定位发你。', NULL, N'雾城剧本研究所前台', DATEADD(MINUTE, -36, GETDATE())),
        (@SeedUserA, @SeedUserB, N'Photo', N'我把新换的角色海报也发你一张。', N'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=900&q=80', NULL, DATEADD(MINUTE, -30, GETDATE())),
        (@SeedUserB, @SeedUserA, N'Voice', N'我录了一段语音，把开场想法先说给你听。', NULL, NULL, DATEADD(MINUTE, -28, GETDATE())),
        (@SeedUserA, @SeedUserB, N'VideoCall', N'临开场前来个视频通话对一下阵容。', NULL, NULL, DATEADD(MINUTE, -18, GETDATE()));

        INSERT INTO dbo.FriendMoments(UserId, Content, ImageUrl, LocationText, Visibility, CreatedAt)
        VALUES
        (@SeedUserA, N'刚在长夜 B 厅开完一车，沉浸感直接拉满。', N'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=900&q=80', N'长夜 B 厅', N'Friends', DATEADD(HOUR, -6, GETDATE())),
        (@SeedUserB, N'今天拿到了新的侦探徽章，准备晚上继续冲还原本。', NULL, N'玩家互动区', N'Friends', DATEADD(HOUR, -3, GETDATE()));

        INSERT INTO dbo.MomentComments(MomentId, UserId, Content, CreatedAt)
        SELECT TOP 1 fm.Id, @SeedUserB, N'这场真的高光不断，下次还想一起开。', DATEADD(HOUR, -5, GETDATE())
        FROM dbo.FriendMoments fm
        WHERE fm.UserId = @SeedUserA
        ORDER BY fm.Id DESC;

        INSERT INTO dbo.MomentComments(MomentId, UserId, Content, CreatedAt)
        SELECT TOP 1 fm.Id, @SeedUserA, N'等你晚上来一起冲下一车。', DATEADD(HOUR, -2, GETDATE())
        FROM dbo.FriendMoments fm
        WHERE fm.UserId = @SeedUserB
        ORDER BY fm.Id DESC;

        INSERT INTO dbo.FriendMoneyTransfers(SenderUserId, ReceiverUserId, TransferType, Amount, Note, CreatedAt)
        VALUES(@SeedUserA, @SeedUserB, N'Transfer', 66.00, N'请你喝一杯店里的特调。', DATEADD(MINUTE, -12, GETDATE()));
    END;
END;";

            using (var connection = new SqlConnection(BuildDatabaseConnectionString(databaseName)))
            using (var command = connection.CreateCommand())
            {
                connection.Open();
                EnsureSchemaMigrationsTable(connection);
                ExecuteTrackedMigration(
                    connection,
                    IncrementalFeaturesMigrationKey,
                    "增量功能与兼容结构补丁",
                    ComputeChecksum(IncrementalFeaturesMigrationVersion + "\n" + sql),
                    () =>
                    {
                        EnsureUserPublicCodeSchema(connection);
                        EnsureWorkflowCompatibilitySchema(connection);
                        command.CommandText = sql;
                        command.ExecuteNonQuery();
                        EnsureGameLifecycleSchema(connection);
                    });
            }
        }

        private static void EnsureSchema(string databaseName, string scriptPath)
        {
            using (var connection = new SqlConnection(BuildDatabaseConnectionString(databaseName)))
            using (var command = connection.CreateCommand())
            {
                connection.Open();
                var scriptContent = File.ReadAllText(scriptPath);
                EnsureSchemaMigrationsTable(connection);
                ExecuteTrackedMigration(
                    connection,
                    BaseSchemaMigrationKey,
                    "基础建库脚本",
                    ComputeChecksum(scriptContent),
                    () =>
                    {
                        var batches = Regex.Split(scriptContent, @"^\s*GO\s*$(?:\r?\n)?", RegexOptions.Multiline | RegexOptions.IgnoreCase);

                        foreach (var batch in batches)
                        {
                            var sql = batch.Trim();
                            if (string.IsNullOrWhiteSpace(sql))
                            {
                                continue;
                            }

                            command.CommandText = sql;
                            command.Parameters.Clear();
                            command.ExecuteNonQuery();
                        }
                    });
            }
        }

        private static string EscapeSqlLiteral(string value)
        {
            return value.Replace("'", "''");
        }

        private static void EnsureSchemaMigrationsTable(SqlConnection connection)
        {
            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.SchemaMigrations', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SchemaMigrations
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        MigrationKey NVARCHAR(120) NOT NULL,
        Description NVARCHAR(200) NULL,
        ScriptChecksum NVARCHAR(64) NOT NULL,
        StartedAt DATETIME NOT NULL,
        CompletedAt DATETIME NULL,
        Succeeded BIT NOT NULL CONSTRAINT DF_SchemaMigrations_Succeeded DEFAULT(0),
        ErrorMessage NVARCHAR(MAX) NULL,
        UpdatedAt DATETIME NOT NULL CONSTRAINT DF_SchemaMigrations_UpdatedAt DEFAULT(GETDATE())
    );

    CREATE UNIQUE INDEX UX_SchemaMigrations_MigrationKey ON dbo.SchemaMigrations(MigrationKey);
END;");
        }

        private static void ExecuteTrackedMigration(SqlConnection connection, string migrationKey, string description, string scriptChecksum, Action applyMigration)
        {
            if (string.IsNullOrWhiteSpace(migrationKey))
            {
                throw new ArgumentException("Migration key is required.", nameof(migrationKey));
            }

            if (applyMigration == null)
            {
                throw new ArgumentNullException(nameof(applyMigration));
            }

            if (!ShouldApplyMigration(connection, migrationKey, scriptChecksum))
            {
                return;
            }

            MarkMigrationStarted(connection, migrationKey, description, scriptChecksum);
            try
            {
                applyMigration();
                MarkMigrationCompleted(connection, migrationKey, description, scriptChecksum, true, null);
            }
            catch (Exception ex)
            {
                MarkMigrationCompleted(connection, migrationKey, description, scriptChecksum, false, ex.ToString());
                throw;
            }
        }

        private static bool ShouldApplyMigration(SqlConnection connection, string migrationKey, string scriptChecksum)
        {
            using (var command = connection.CreateCommand())
            {
                command.CommandText = @"
SELECT TOP 1 Succeeded
FROM dbo.SchemaMigrations
WHERE MigrationKey = @MigrationKey
  AND ScriptChecksum = @ScriptChecksum;";
                command.Parameters.AddWithValue("@MigrationKey", migrationKey);
                command.Parameters.AddWithValue("@ScriptChecksum", scriptChecksum ?? string.Empty);

                var result = command.ExecuteScalar();
                return result == null || result == DBNull.Value || !Convert.ToBoolean(result);
            }
        }

        private static void MarkMigrationStarted(SqlConnection connection, string migrationKey, string description, string scriptChecksum)
        {
            using (var command = connection.CreateCommand())
            {
                command.CommandText = @"
MERGE dbo.SchemaMigrations AS target
USING (SELECT @MigrationKey AS MigrationKey) AS source
ON target.MigrationKey = source.MigrationKey
WHEN MATCHED THEN
    UPDATE SET
        Description = @Description,
        ScriptChecksum = @ScriptChecksum,
        StartedAt = GETDATE(),
        CompletedAt = NULL,
        Succeeded = 0,
        ErrorMessage = NULL,
        UpdatedAt = GETDATE()
WHEN NOT MATCHED THEN
    INSERT(MigrationKey, Description, ScriptChecksum, StartedAt, CompletedAt, Succeeded, ErrorMessage, UpdatedAt)
    VALUES(@MigrationKey, @Description, @ScriptChecksum, GETDATE(), NULL, 0, NULL, GETDATE());";
                command.Parameters.AddWithValue("@MigrationKey", migrationKey);
                command.Parameters.AddWithValue("@Description", (object)description ?? DBNull.Value);
                command.Parameters.AddWithValue("@ScriptChecksum", scriptChecksum ?? string.Empty);
                command.ExecuteNonQuery();
            }
        }

        private static void MarkMigrationCompleted(SqlConnection connection, string migrationKey, string description, string scriptChecksum, bool succeeded, string errorMessage)
        {
            using (var command = connection.CreateCommand())
            {
                command.CommandText = @"
UPDATE dbo.SchemaMigrations
SET Description = @Description,
    ScriptChecksum = @ScriptChecksum,
    CompletedAt = GETDATE(),
    Succeeded = @Succeeded,
    ErrorMessage = @ErrorMessage,
    UpdatedAt = GETDATE()
WHERE MigrationKey = @MigrationKey;";
                command.Parameters.AddWithValue("@MigrationKey", migrationKey);
                command.Parameters.AddWithValue("@Description", (object)description ?? DBNull.Value);
                command.Parameters.AddWithValue("@ScriptChecksum", scriptChecksum ?? string.Empty);
                command.Parameters.AddWithValue("@Succeeded", succeeded);
                command.Parameters.AddWithValue("@ErrorMessage", string.IsNullOrWhiteSpace(errorMessage) ? (object)DBNull.Value : errorMessage);
                command.ExecuteNonQuery();
            }
        }

        private static string ComputeChecksum(string content)
        {
            using (var sha256 = SHA256.Create())
            {
                var bytes = System.Text.Encoding.UTF8.GetBytes(content ?? string.Empty);
                var hash = sha256.ComputeHash(bytes);
                return BitConverter.ToString(hash).Replace("-", string.Empty).ToLowerInvariant();
            }
        }

        private static void EnsureUserPublicCodeSchema(SqlConnection connection)
        {
            ExecuteNonQuery(connection, @"
IF COL_LENGTH('dbo.Users', 'PublicUserCode') IS NULL
BEGIN
    ALTER TABLE dbo.Users
    ADD PublicUserCode NVARCHAR(24) NULL;
END;");

            ExecuteNonQuery(connection, @"
UPDATE dbo.Users
SET PublicUserCode = N'DM' + RIGHT(REPLICATE(N'0', 6) + CAST(Id AS NVARCHAR(12)), 6)
WHERE ISNULL(PublicUserCode, N'') = N'';");

            ExecuteNonQuery(connection, @"
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_Users_PublicUserCode' AND object_id = OBJECT_ID('dbo.Users'))
BEGIN
    CREATE UNIQUE INDEX UX_Users_PublicUserCode ON dbo.Users(PublicUserCode) WHERE PublicUserCode IS NOT NULL;
END;");
        }

        private static void EnsureWorkflowCompatibilitySchema(SqlConnection connection)
        {
            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.Reviews', 'U') IS NOT NULL AND COL_LENGTH('dbo.Reviews', 'UserId') IS NULL
BEGIN
    ALTER TABLE dbo.Reviews
    ADD UserId INT NULL;
END;");

            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.Reviews', 'U') IS NOT NULL AND COL_LENGTH('dbo.Reviews', 'ReservationId') IS NULL
BEGIN
    ALTER TABLE dbo.Reviews
    ADD ReservationId INT NULL;
END;");

            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.Reviews', 'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Reviews_UserReservation' AND object_id = OBJECT_ID('dbo.Reviews'))
BEGIN
    CREATE INDEX IX_Reviews_UserReservation ON dbo.Reviews(UserId, ReservationId);
END;");

            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.Reviews', 'U') IS NOT NULL AND COL_LENGTH('dbo.Reviews', 'IsFeatured') IS NULL
BEGIN
    ALTER TABLE dbo.Reviews
    ADD IsFeatured BIT NOT NULL CONSTRAINT DF_Reviews_IsFeatured DEFAULT(0);
END;");

            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.Reviews', 'U') IS NOT NULL AND COL_LENGTH('dbo.Reviews', 'IsHidden') IS NULL
BEGIN
    ALTER TABLE dbo.Reviews
    ADD IsHidden BIT NOT NULL CONSTRAINT DF_Reviews_IsHidden DEFAULT(0);
END;");

            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.Reviews', 'U') IS NOT NULL AND COL_LENGTH('dbo.Reviews', 'AdminReply') IS NULL
BEGIN
    ALTER TABLE dbo.Reviews
    ADD AdminReply NVARCHAR(500) NULL;
END;");

            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.Reservations', 'U') IS NOT NULL AND COL_LENGTH('dbo.Reservations', 'CouponId') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations
    ADD CouponId INT NULL;
END;");

            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.Reservations', 'U') IS NOT NULL AND COL_LENGTH('dbo.Reservations', 'DiscountAmount') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations
    ADD DiscountAmount DECIMAL(10,2) NOT NULL CONSTRAINT DF_Reservations_DiscountAmount DEFAULT(0);
END;");

            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.Reservations', 'U') IS NOT NULL AND COL_LENGTH('dbo.Reservations', 'CheckInCode') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations
    ADD CheckInCode NVARCHAR(20) NULL;
END;");

            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.Reservations', 'U') IS NOT NULL AND COL_LENGTH('dbo.Reservations', 'CheckedInAt') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations
    ADD CheckedInAt DATETIME NULL;
END;");

            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.Reservations', 'U') IS NOT NULL AND COL_LENGTH('dbo.Reservations', 'CheckInByUserId') IS NULL
BEGIN
    ALTER TABLE dbo.Reservations
    ADD CheckInByUserId INT NULL;
END;");

            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.AfterSaleRequests', 'U') IS NOT NULL AND COL_LENGTH('dbo.AfterSaleRequests', 'EvidenceUrl') IS NULL
BEGIN
    ALTER TABLE dbo.AfterSaleRequests
    ADD EvidenceUrl NVARCHAR(500) NULL;
END;");

            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.AfterSaleRequests', 'U') IS NOT NULL AND COL_LENGTH('dbo.AfterSaleRequests', 'RejectReason') IS NULL
BEGIN
    ALTER TABLE dbo.AfterSaleRequests
    ADD RejectReason NVARCHAR(500) NULL;
END;");

            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.AfterSaleRequests', 'U') IS NOT NULL AND COL_LENGTH('dbo.AfterSaleRequests', 'AppealReason') IS NULL
BEGIN
    ALTER TABLE dbo.AfterSaleRequests
    ADD AppealReason NVARCHAR(500) NULL;
END;");

            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.AfterSaleRequests', 'U') IS NOT NULL AND COL_LENGTH('dbo.AfterSaleRequests', 'AcceptedAt') IS NULL
BEGIN
    ALTER TABLE dbo.AfterSaleRequests
    ADD AcceptedAt DATETIME NULL;
END;");

            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.AfterSaleRequests', 'U') IS NOT NULL AND COL_LENGTH('dbo.AfterSaleRequests', 'RejectedAt') IS NULL
BEGIN
    ALTER TABLE dbo.AfterSaleRequests
    ADD RejectedAt DATETIME NULL;
END;");

            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.AfterSaleRequests', 'U') IS NOT NULL AND COL_LENGTH('dbo.AfterSaleRequests', 'AppealedAt') IS NULL
BEGIN
    ALTER TABLE dbo.AfterSaleRequests
    ADD AppealedAt DATETIME NULL;
END;");

            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.Reservations', 'U') IS NOT NULL AND COL_LENGTH('dbo.Reservations', 'CheckInCode') IS NOT NULL
BEGIN
    UPDATE dbo.Reservations
    SET CheckInCode = RIGHT(N'000000' + CONVERT(NVARCHAR(20), ABS(CHECKSUM(NEWID())) % 1000000), 6)
    WHERE CheckInCode IS NULL OR CheckInCode = N'';
END;");

            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.Reservations', 'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Reservations_CheckInCode' AND object_id = OBJECT_ID('dbo.Reservations'))
BEGIN
    CREATE INDEX IX_Reservations_CheckInCode ON dbo.Reservations(CheckInCode, Status);
END;");

            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.Sessions', 'U') IS NOT NULL AND COL_LENGTH('dbo.Sessions', 'HostUserId') IS NULL
BEGIN
    ALTER TABLE dbo.Sessions
    ADD HostUserId INT NULL;
END;");

            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.Sessions', 'U') IS NOT NULL AND COL_LENGTH('dbo.Sessions', 'HostBriefing') IS NULL
BEGIN
    ALTER TABLE dbo.Sessions
    ADD HostBriefing NVARCHAR(500) NULL;
END;");

            ExecuteNonQuery(connection, @"
IF OBJECT_ID('dbo.Sessions', 'U') IS NOT NULL AND COL_LENGTH('dbo.Sessions', 'HostAcceptedAt') IS NULL
BEGIN
    ALTER TABLE dbo.Sessions
    ADD HostAcceptedAt DATETIME NULL;
END;");
        }

        private static void EnsureGameLifecycleSchema(SqlConnection connection)
        {
            ExecuteNonQuery(connection, @"
IF COL_LENGTH('dbo.SessionGameStates', 'GameStartedAt') IS NULL
BEGIN
    ALTER TABLE dbo.SessionGameStates
    ADD GameStartedAt DATETIME NULL;
END;

IF COL_LENGTH('dbo.SessionGameStates', 'GameEndedAt') IS NULL
BEGIN
    ALTER TABLE dbo.SessionGameStates
    ADD GameEndedAt DATETIME NULL;
END;

IF COL_LENGTH('dbo.SessionGameStates', 'SettledAt') IS NULL
BEGIN
    ALTER TABLE dbo.SessionGameStates
    ADD SettledAt DATETIME NULL;
END;

IF COL_LENGTH('dbo.SessionGameStates', 'StartedByUserId') IS NULL
BEGIN
    ALTER TABLE dbo.SessionGameStates
    ADD StartedByUserId INT NULL;
END;

IF COL_LENGTH('dbo.SessionGameStates', 'EndedByUserId') IS NULL
BEGIN
    ALTER TABLE dbo.SessionGameStates
    ADD EndedByUserId INT NULL;
END;

IF COL_LENGTH('dbo.SessionGameStates', 'CaseKillerCharacterId') IS NULL
BEGIN
    ALTER TABLE dbo.SessionGameStates
    ADD CaseKillerCharacterId INT NULL;
END;

IF COL_LENGTH('dbo.SessionGameStates', 'CaseKillerCharacterName') IS NULL
BEGIN
    ALTER TABLE dbo.SessionGameStates
    ADD CaseKillerCharacterName NVARCHAR(50) NULL;
END;

IF COL_LENGTH('dbo.SessionGameStates', 'CaseTruthSummary') IS NULL
BEGIN
    ALTER TABLE dbo.SessionGameStates
    ADD CaseTruthSummary NVARCHAR(MAX) NULL;
END;

IF COL_LENGTH('dbo.SessionGameStates', 'DmNotes') IS NULL
BEGIN
    ALTER TABLE dbo.SessionGameStates
    ADD DmNotes NVARCHAR(MAX) NULL;
END;

IF COL_LENGTH('dbo.SessionGameStates', 'StageTimerStartedAt') IS NULL
BEGIN
    ALTER TABLE dbo.SessionGameStates
    ADD StageTimerStartedAt DATETIME NULL;
END;

IF COL_LENGTH('dbo.SessionGameStates', 'StageTimerDurationMinutes') IS NULL
BEGIN
    ALTER TABLE dbo.SessionGameStates
    ADD StageTimerDurationMinutes INT NULL;
END;

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_SessionGameStates_StartedByUsers')
BEGIN
    ALTER TABLE dbo.SessionGameStates
    ADD CONSTRAINT FK_SessionGameStates_StartedByUsers FOREIGN KEY (StartedByUserId) REFERENCES dbo.Users(Id);
END;

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_SessionGameStates_EndedByUsers')
BEGIN
    ALTER TABLE dbo.SessionGameStates
    ADD CONSTRAINT FK_SessionGameStates_EndedByUsers FOREIGN KEY (EndedByUserId) REFERENCES dbo.Users(Id);
END;

IF OBJECT_ID('dbo.PlayerBattleRecords', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PlayerBattleRecords
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
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
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_PlayerBattleRecords_SessionReservation' AND object_id = OBJECT_ID('dbo.PlayerBattleRecords'))
BEGIN
    CREATE UNIQUE INDEX UX_PlayerBattleRecords_SessionReservation ON dbo.PlayerBattleRecords(SessionId, ReservationId);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PlayerBattleRecords_User_CompletedAt' AND object_id = OBJECT_ID('dbo.PlayerBattleRecords'))
BEGIN
    CREATE INDEX IX_PlayerBattleRecords_User_CompletedAt ON dbo.PlayerBattleRecords(UserId, CompletedAt DESC);
END;");
        }

        private static void ExecuteNonQuery(SqlConnection connection, string sql)
        {
            using (var command = connection.CreateCommand())
            {
                command.CommandText = sql;
                command.ExecuteNonQuery();
            }
        }
    }
}
