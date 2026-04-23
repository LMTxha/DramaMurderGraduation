using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web.Data
{
    public class ContentRepository
    {
        private const string PublishedScriptBaseQuery = @"
SELECT TOP (@Top)
    s.Id,
    s.GenreId,
    g.Name AS GenreName,
    s.Name,
    s.Slogan,
    s.StoryBackground,
    s.FullScriptContent,
    s.CoverImage,
    s.DurationMinutes,
    s.PlayerMin,
    s.PlayerMax,
    s.Difficulty,
    s.Price,
    s.IsFeatured,
    s.Status,
    s.AuthorName,
    CAST(ISNULL((
        SELECT AVG(CAST(r.Rating AS DECIMAL(10,2)))
        FROM dbo.Reviews r
        WHERE r.ScriptId = s.Id
    ), 0) AS DECIMAL(10,2)) AS AverageRating,
    (
        SELECT COUNT(1)
        FROM dbo.Reviews r
        WHERE r.ScriptId = s.Id
    ) AS ReviewCount,
    (
        SELECT COUNT(1)
        FROM dbo.Sessions se
        WHERE se.ScriptId = s.Id AND se.Status = N'开放预约' AND se.SessionDateTime >= GETDATE()
    ) AS UpcomingSessionCount,
    s.CreatorUserId,
    ISNULL(u.DisplayName, N'') AS CreatorDisplayName,
    s.AuditStatus,
    s.AuditComment,
    s.SubmittedAt,
    s.ReviewedAt
FROM dbo.Scripts s
INNER JOIN dbo.Genres g ON g.Id = s.GenreId
LEFT JOIN dbo.Users u ON u.Id = s.CreatorUserId
WHERE s.AuditStatus = N'Approved'";

        public SiteSettings GetSiteSettings()
        {
            const string sql = @"
SELECT TOP 1 SiteName, HeroTitle, HeroSubtitle, WelcomeText, AboutTitle, AboutContent, Address, BusinessHours, ContactPhone, ContactWeChat
FROM dbo.SiteSettings
ORDER BY Id;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        return new SiteSettings();
                    }

                    return new SiteSettings
                    {
                        SiteName = GetString(reader, "SiteName"),
                        HeroTitle = GetString(reader, "HeroTitle"),
                        HeroSubtitle = GetString(reader, "HeroSubtitle"),
                        WelcomeText = GetString(reader, "WelcomeText"),
                        AboutTitle = GetString(reader, "AboutTitle"),
                        AboutContent = GetString(reader, "AboutContent"),
                        Address = GetString(reader, "Address"),
                        BusinessHours = GetString(reader, "BusinessHours"),
                        ContactPhone = GetString(reader, "ContactPhone"),
                        ContactWeChat = GetString(reader, "ContactWeChat")
                    };
                }
            }
        }

        public SiteMetrics GetSiteMetrics()
        {
            const string sql = @"
SELECT
    (SELECT COUNT(1) FROM dbo.Scripts WHERE AuditStatus = N'Approved') AS ScriptCount,
    (SELECT COUNT(1) FROM dbo.ScriptCharacters) AS CharacterCount,
    (SELECT COUNT(1) FROM dbo.Rooms) AS RoomCount,
    (SELECT COUNT(1) FROM dbo.Reservations) AS ReservationCount,
    CAST(ISNULL((SELECT AVG(CAST(Rating AS DECIMAL(10,2))) FROM dbo.Reviews), 0) AS DECIMAL(10,2)) AS AverageRating;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                connection.Open();
                using (var reader = command.ExecuteReader(CommandBehavior.SingleRow))
                {
                    if (!reader.Read())
                    {
                        return new SiteMetrics();
                    }

                    return new SiteMetrics
                    {
                        ScriptCount = GetInt32(reader, "ScriptCount"),
                        CharacterCount = GetInt32(reader, "CharacterCount"),
                        RoomCount = GetInt32(reader, "RoomCount"),
                        ReservationCount = GetInt32(reader, "ReservationCount"),
                        AverageRating = GetDecimal(reader, "AverageRating")
                    };
                }
            }
        }

        public IList<AnnouncementInfo> GetAnnouncements(int top)
        {
            const string sql = @"
SELECT TOP (@Top) Id, Title, Summary, PublishDate, IsImportant
FROM dbo.Announcements
ORDER BY IsImportant DESC, PublishDate DESC, Id DESC;";

            return ExecuteList(sql, command => command.Parameters.AddWithValue("@Top", top), reader => new AnnouncementInfo
            {
                Id = GetInt32(reader, "Id"),
                Title = GetString(reader, "Title"),
                Summary = GetString(reader, "Summary"),
                PublishDate = GetDateTime(reader, "PublishDate"),
                IsImportant = GetBoolean(reader, "IsImportant")
            });
        }

        public IList<DownloadOptionInfo> GetDownloadOptions()
        {
            const string sql = @"
SELECT Id, PlatformName, PlatformCode, IconText, VersionText, Summary, DownloadUrl, ReleaseDate, SortOrder
FROM dbo.DownloadOptions
WHERE IsActive = 1
ORDER BY SortOrder, Id;";

            return ExecuteList(sql, null, reader => new DownloadOptionInfo
            {
                Id = GetInt32(reader, "Id"),
                PlatformName = GetString(reader, "PlatformName"),
                PlatformCode = GetString(reader, "PlatformCode"),
                IconText = GetString(reader, "IconText"),
                VersionText = GetString(reader, "VersionText"),
                Summary = GetString(reader, "Summary"),
                DownloadUrl = GetString(reader, "DownloadUrl"),
                ReleaseDate = GetDateTime(reader, "ReleaseDate"),
                SortOrder = GetInt32(reader, "SortOrder")
            });
        }

        public DownloadOptionInfo GetDownloadOption(string platformCode)
        {
            const string sql = @"
SELECT TOP 1 Id, PlatformName, PlatformCode, IconText, VersionText, Summary, DownloadUrl, ReleaseDate, SortOrder
FROM dbo.DownloadOptions
WHERE IsActive = 1 AND PlatformCode = @PlatformCode
ORDER BY SortOrder, Id;";

            var options = ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@PlatformCode", platformCode ?? string.Empty);
            }, reader => new DownloadOptionInfo
            {
                Id = GetInt32(reader, "Id"),
                PlatformName = GetString(reader, "PlatformName"),
                PlatformCode = GetString(reader, "PlatformCode"),
                IconText = GetString(reader, "IconText"),
                VersionText = GetString(reader, "VersionText"),
                Summary = GetString(reader, "Summary"),
                DownloadUrl = GetString(reader, "DownloadUrl"),
                ReleaseDate = GetDateTime(reader, "ReleaseDate"),
                SortOrder = GetInt32(reader, "SortOrder")
            });

            return options.Count == 0 ? null : options[0];
        }

        public bool CreateAnnouncement(string title, string summary, bool isImportant, out string message)
        {
            if (string.IsNullOrWhiteSpace(title) || string.IsNullOrWhiteSpace(summary))
            {
                message = "请完整填写公告标题和内容。";
                return false;
            }

            const string sql = @"
INSERT INTO dbo.Announcements(Title, Summary, PublishDate, IsImportant)
VALUES(@Title, @Summary, CAST(GETDATE() AS DATE), @IsImportant);";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@Title", title.Trim());
                command.Parameters.AddWithValue("@Summary", summary.Trim());
                command.Parameters.AddWithValue("@IsImportant", isImportant);

                connection.Open();
                command.ExecuteNonQuery();
            }

            message = "公告已发布。";
            return true;
        }

        public IList<GenreInfo> GetGenres()
        {
            const string sql = @"
SELECT Id, Name, Description
FROM dbo.Genres
ORDER BY Id;";

            return ExecuteList(sql, null, reader => new GenreInfo
            {
                Id = GetInt32(reader, "Id"),
                Name = GetString(reader, "Name"),
                Description = GetString(reader, "Description")
            });
        }

        public IList<ScriptInfo> GetFeaturedScripts(int top)
        {
            return ExecuteScriptList(PublishedScriptBaseQuery + @"
AND s.IsFeatured = 1
ORDER BY s.Id;", command => command.Parameters.AddWithValue("@Top", top));
        }

        public IList<ScriptInfo> GetScripts(string keyword, int? genreId)
        {
            return ExecuteScriptList(PublishedScriptBaseQuery + @"
AND (@Keyword = N'' OR s.Name LIKE N'%' + @Keyword + N'%' OR s.Slogan LIKE N'%' + @Keyword + N'%')
AND (@GenreId IS NULL OR s.GenreId = @GenreId)
ORDER BY s.IsFeatured DESC, s.Id DESC;", command =>
            {
                command.Parameters.AddWithValue("@Top", 999);
                command.Parameters.AddWithValue("@Keyword", keyword ?? string.Empty);
                command.Parameters.AddWithValue("@GenreId", (object)genreId ?? DBNull.Value);
            });
        }

        public ScriptInfo GetScriptDetail(int scriptId)
        {
            var list = ExecuteScriptList(PublishedScriptBaseQuery + @"
AND s.Id = @ScriptId;", command =>
            {
                command.Parameters.AddWithValue("@Top", 1);
                command.Parameters.AddWithValue("@ScriptId", scriptId);
            });

            return list.Count > 0 ? list[0] : null;
        }

        public IList<ScriptCharacterInfo> GetCharactersByScript(int scriptId)
        {
            const string sql = @"
SELECT Id, ScriptId, Name, Gender, AgeRange, Profession, Personality, SecretLine, Description
FROM dbo.ScriptCharacters
WHERE ScriptId = @ScriptId
ORDER BY Id;";

            return ExecuteList(sql, command => command.Parameters.AddWithValue("@ScriptId", scriptId), reader => new ScriptCharacterInfo
            {
                Id = GetInt32(reader, "Id"),
                ScriptId = GetInt32(reader, "ScriptId"),
                Name = GetString(reader, "Name"),
                Gender = LocalizeImportedPlaceholder(GetString(reader, "Gender")),
                AgeRange = LocalizeImportedPlaceholder(GetString(reader, "AgeRange")),
                Profession = LocalizeImportedPlaceholder(GetString(reader, "Profession")),
                Personality = LocalizeImportedPlaceholder(GetString(reader, "Personality")),
                SecretLine = LocalizeImportedPlaceholder(GetString(reader, "SecretLine")),
                Description = LocalizeImportedPlaceholder(GetString(reader, "Description"))
            });
        }

        public IList<ScriptAssetInfo> GetScriptAssets(int scriptId)
        {
            const string sql = @"
SELECT
    Id,
    ScriptId,
    AssetType,
    Title,
    FileName,
    RelativePath,
    PublicUrl,
    FileExtension,
    FileSizeBytes,
    IsPrimary,
    SortOrder
FROM dbo.ScriptAssets
WHERE ScriptId = @ScriptId
ORDER BY IsPrimary DESC, SortOrder ASC, Id ASC;";

            return ExecuteList(sql, command => command.Parameters.AddWithValue("@ScriptId", scriptId), reader => new ScriptAssetInfo
            {
                Id = GetInt32(reader, "Id"),
                ScriptId = GetInt32(reader, "ScriptId"),
                AssetType = GetString(reader, "AssetType"),
                Title = GetString(reader, "Title"),
                FileName = GetString(reader, "FileName"),
                RelativePath = GetString(reader, "RelativePath"),
                PublicUrl = GetString(reader, "PublicUrl"),
                FileExtension = GetString(reader, "FileExtension"),
                FileSizeBytes = GetInt64(reader, "FileSizeBytes"),
                IsPrimary = GetBoolean(reader, "IsPrimary"),
                SortOrder = GetInt32(reader, "SortOrder")
            });
        }

        public IList<RoomInfo> GetRooms()
        {
            const string sql = @"
SELECT
    r.Id,
    r.Name,
    r.Theme,
    r.Capacity,
    r.Description,
    r.ImageUrl,
    r.Status,
    (
        SELECT COUNT(1)
        FROM dbo.Sessions s
        INNER JOIN dbo.Scripts sc ON sc.Id = s.ScriptId
        WHERE s.RoomId = r.Id
          AND s.Status = N'开放预约'
          AND s.SessionDateTime >= GETDATE()
          AND sc.AuditStatus = N'Approved'
    ) AS UpcomingSessionCount,
    ISNULL((
        SELECT TOP 1 s.Id
        FROM dbo.Sessions s
        INNER JOIN dbo.Scripts sc ON sc.Id = s.ScriptId
        WHERE s.RoomId = r.Id
          AND s.Status = N'开放预约'
          AND s.SessionDateTime >= GETDATE()
          AND sc.AuditStatus = N'Approved'
        ORDER BY s.SessionDateTime ASC
    ), 0) AS PrimarySessionId
FROM dbo.Rooms r
ORDER BY r.Id;";

            return ExecuteList(sql, null, reader => new RoomInfo
            {
                Id = GetInt32(reader, "Id"),
                Name = GetString(reader, "Name"),
                Theme = GetString(reader, "Theme"),
                Capacity = GetInt32(reader, "Capacity"),
                Description = GetString(reader, "Description"),
                ImageUrl = GetString(reader, "ImageUrl"),
                Status = GetString(reader, "Status"),
                UpcomingSessionCount = GetInt32(reader, "UpcomingSessionCount"),
                PrimarySessionId = GetInt32(reader, "PrimarySessionId")
            });
        }

        public IList<SessionInfo> GetUpcomingSessions(int top, int? scriptId = null)
        {
            const string sql = @"
SELECT TOP (@Top)
    s.Id,
    s.ScriptId,
    s.RoomId,
    sc.Name AS ScriptName,
    r.Name AS RoomName,
    s.SessionDateTime,
    s.HostName,
    s.BasePrice,
    s.MaxPlayers,
    ISNULL(SUM(CASE WHEN rv.Status IN (N'待确认', N'已确认', N'申请改期') THEN rv.PlayerCount ELSE 0 END), 0) AS ReservedPlayers,
    s.MaxPlayers - ISNULL(SUM(CASE WHEN rv.Status IN (N'待确认', N'已确认', N'申请改期') THEN rv.PlayerCount ELSE 0 END), 0) AS RemainingSeats,
    s.Status
FROM dbo.Sessions s
INNER JOIN dbo.Scripts sc ON sc.Id = s.ScriptId
INNER JOIN dbo.Rooms r ON r.Id = s.RoomId
LEFT JOIN dbo.Reservations rv ON rv.SessionId = s.Id
WHERE s.SessionDateTime >= GETDATE()
  AND sc.AuditStatus = N'Approved'
  AND (@ScriptId IS NULL OR s.ScriptId = @ScriptId)
GROUP BY s.Id, s.ScriptId, s.RoomId, sc.Name, r.Name, s.SessionDateTime, s.HostName, s.BasePrice, s.MaxPlayers, s.Status
HAVING s.Status = N'开放预约'
ORDER BY s.SessionDateTime ASC;";

            return ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@ScriptId", (object)scriptId ?? DBNull.Value);
            }, MapSession);
        }

        public IList<DmSessionInfo> GetDmSessions(int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    s.Id AS SessionId,
    s.ScriptId,
    sc.Name AS ScriptName,
    r.Name AS RoomName,
    s.HostName,
    s.SessionDateTime,
    s.Status,
    s.MaxPlayers,
    COUNT(DISTINCT CASE WHEN rv.Status IN (N'待确认', N'已确认', N'玩家已确认', N'已到店') AND ISNULL(rvUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director') THEN rv.Id END) AS ReservationCount,
    COUNT(DISTINCT CASE WHEN ISNULL(rvUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director') THEN a.Id END) AS AssignedCount,
    SUM(CASE WHEN a.IsReady = 1 AND ISNULL(rvUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director') THEN 1 ELSE 0 END) AS ReadyCount,
    COUNT(DISTINCT CASE WHEN ISNULL(rvUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director') THEN v.Id END) AS VoteCount,
    ISNULL(gs.StageName, N'未初始化') AS CurrentStageName,
    CAST(CASE WHEN st.GameStartedAt IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS IsGameStarted,
    CAST(CASE WHEN st.GameEndedAt IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS IsGameEnded,
    CAST(CASE WHEN st.SettledAt IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS IsSettled,
    ISNULL(MIN(CASE WHEN rv.Status IN (N'待确认', N'已确认', N'玩家已确认', N'已到店') AND ISNULL(rvUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director') THEN rv.Id END), 0) AS HostReservationId
FROM dbo.Sessions s
INNER JOIN dbo.Scripts sc ON sc.Id = s.ScriptId
INNER JOIN dbo.Rooms r ON r.Id = s.RoomId
LEFT JOIN dbo.Reservations rv ON rv.SessionId = s.Id
LEFT JOIN dbo.Users rvUser ON rvUser.Id = rv.UserId
LEFT JOIN dbo.SessionGameStates st ON st.SessionId = s.Id
LEFT JOIN dbo.GameStages gs ON gs.Id = st.CurrentStageId
LEFT JOIN dbo.SessionCharacterAssignments a ON a.SessionId = s.Id AND a.ReservationId = rv.Id
LEFT JOIN dbo.SessionVotes v ON v.SessionId = s.Id AND v.ReservationId = rv.Id
WHERE sc.AuditStatus = N'Approved'
  AND (
      s.SessionDateTime >= DATEADD(day, -1, GETDATE())
      OR st.GameEndedAt IS NULL
  )
GROUP BY
    s.Id, s.ScriptId, sc.Name, r.Name, s.HostName, s.SessionDateTime, s.Status, s.MaxPlayers,
    gs.StageName, st.GameStartedAt, st.GameEndedAt, st.SettledAt
ORDER BY
    CASE WHEN st.GameEndedAt IS NULL THEN 0 ELSE 1 END,
    s.SessionDateTime ASC,
    s.Id ASC;";

            return ExecuteList(sql, command => command.Parameters.AddWithValue("@Top", top), reader => new DmSessionInfo
            {
                SessionId = GetInt32(reader, "SessionId"),
                ScriptId = GetInt32(reader, "ScriptId"),
                ScriptName = GetString(reader, "ScriptName"),
                RoomName = GetString(reader, "RoomName"),
                HostName = GetString(reader, "HostName"),
                SessionDateTime = GetDateTime(reader, "SessionDateTime"),
                Status = GetString(reader, "Status"),
                MaxPlayers = GetInt32(reader, "MaxPlayers"),
                ReservationCount = GetInt32(reader, "ReservationCount"),
                AssignedCount = GetInt32(reader, "AssignedCount"),
                ReadyCount = GetInt32(reader, "ReadyCount"),
                VoteCount = GetInt32(reader, "VoteCount"),
                CurrentStageName = GetString(reader, "CurrentStageName"),
                IsGameStarted = GetBoolean(reader, "IsGameStarted"),
                IsGameEnded = GetBoolean(reader, "IsGameEnded"),
                IsSettled = GetBoolean(reader, "IsSettled"),
                HostReservationId = GetInt32(reader, "HostReservationId")
            });
        }

        public SessionInfo GetSessionById(int sessionId)
        {
            const string sql = @"
SELECT
    s.Id,
    s.ScriptId,
    s.RoomId,
    sc.Name AS ScriptName,
    r.Name AS RoomName,
    s.SessionDateTime,
    s.HostName,
    s.BasePrice,
    s.MaxPlayers,
    ISNULL(SUM(CASE WHEN rv.Status IN (N'待确认', N'已确认', N'申请改期') THEN rv.PlayerCount ELSE 0 END), 0) AS ReservedPlayers,
    s.MaxPlayers - ISNULL(SUM(CASE WHEN rv.Status IN (N'待确认', N'已确认', N'申请改期') THEN rv.PlayerCount ELSE 0 END), 0) AS RemainingSeats,
    s.Status
FROM dbo.Sessions s
INNER JOIN dbo.Scripts sc ON sc.Id = s.ScriptId
INNER JOIN dbo.Rooms r ON r.Id = s.RoomId
LEFT JOIN dbo.Reservations rv ON rv.SessionId = s.Id
WHERE s.Id = @SessionId
  AND s.Status = N'开放预约'
  AND s.SessionDateTime >= GETDATE()
  AND sc.AuditStatus = N'Approved'
GROUP BY s.Id, s.ScriptId, s.RoomId, sc.Name, r.Name, s.SessionDateTime, s.HostName, s.BasePrice, s.MaxPlayers, s.Status;";

            var sessions = ExecuteList(sql, command => command.Parameters.AddWithValue("@SessionId", sessionId), MapSession);
            return sessions.Count > 0 ? sessions[0] : null;
        }

        public bool CreateAdminSession(int scriptId, int roomId, DateTime sessionDateTime, string hostName, decimal basePrice, int maxPlayers, out string message)
        {
            if (sessionDateTime < DateTime.Now.AddHours(1))
            {
                message = "场次时间至少需要晚于当前时间 1 小时。";
                return false;
            }

            if (string.IsNullOrWhiteSpace(hostName))
            {
                message = "请填写主持 DM 名称。";
                return false;
            }

            if (basePrice < 0)
            {
                message = "价格不能小于 0。";
                return false;
            }

            if (maxPlayers < 2 || maxPlayers > 12)
            {
                message = "场次人数请填写 2 到 12 人。";
                return false;
            }

            const string sql = @"
IF NOT EXISTS (SELECT 1 FROM dbo.Scripts WHERE Id = @ScriptId AND AuditStatus = N'Approved')
BEGIN
    RAISERROR(N'所选剧本未通过审核，不能直接排期。', 16, 1);
    RETURN;
END

IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE Id = @RoomId)
BEGIN
    RAISERROR(N'未找到对应房间。', 16, 1);
    RETURN;
END

IF EXISTS
(
    SELECT 1
    FROM dbo.Sessions
    WHERE RoomId = @RoomId
      AND ABS(DATEDIFF(MINUTE, SessionDateTime, @SessionDateTime)) < 180
      AND Status IN (N'开放预约', N'已满', N'进行中')
)
BEGIN
    RAISERROR(N'该房间在前后 3 小时内已有排期，请调整时间。', 16, 1);
    RETURN;
END

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
    @ScriptId,
    @RoomId,
    @SessionDateTime,
    @HostName,
    @BasePrice,
    @MaxPlayers,
    N'开放预约'
);";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@ScriptId", scriptId);
                command.Parameters.AddWithValue("@RoomId", roomId);
                command.Parameters.AddWithValue("@SessionDateTime", sessionDateTime);
                command.Parameters.AddWithValue("@HostName", hostName.Trim());
                command.Parameters.AddWithValue("@BasePrice", basePrice);
                command.Parameters.AddWithValue("@MaxPlayers", maxPlayers);

                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "新场次已创建，并已开放预约。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public bool UpdateRoomStatus(int roomId, string status, out string message)
        {
            var allowedStatuses = new[] { "启用中", "维护中", "暂停接待" };
            if (Array.IndexOf(allowedStatuses, status ?? string.Empty) < 0)
            {
                message = "房间状态不合法。";
                return false;
            }

            const string sql = @"
IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE Id = @RoomId)
BEGIN
    RAISERROR(N'未找到对应房间。', 16, 1);
    RETURN;
END

UPDATE dbo.Rooms
SET Status = @Status
WHERE Id = @RoomId;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@RoomId", roomId);
                command.Parameters.AddWithValue("@Status", status);

                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "房间状态已更新。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public bool CreateStoreVisitRequest(int? userId, int? scriptId, DateTime preferredArriveTime, int teamSize, string contactName, string phone, string note, out string message)
        {
            const string sql = @"
IF @PreferredArriveTime < DATEADD(HOUR, -1, GETDATE())
BEGIN
    RAISERROR(N'到店时间不能早于当前时间，请重新选择。', 16, 1);
    RETURN;
END

IF @TeamSize < 2 OR @TeamSize > 8
BEGIN
    RAISERROR(N'到店人数请填写 2 到 8 人之间的整数。', 16, 1);
    RETURN;
END

IF @ScriptId IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM dbo.Scripts WHERE Id = @ScriptId AND AuditStatus = N'Approved')
BEGIN
    RAISERROR(N'所选剧本当前不可预约，请重新选择。', 16, 1);
    RETURN;
END

INSERT INTO dbo.StoreVisitRequests
(
    UserId,
    ScriptId,
    ContactName,
    Phone,
    PreferredArriveTime,
    TeamSize,
    RequestStatus,
    Note,
    CreatedAt
)
VALUES
(
    @UserId,
    @ScriptId,
    @ContactName,
    @Phone,
    @PreferredArriveTime,
    @TeamSize,
    N'待门店联系',
    NULLIF(@Note, N''),
    GETDATE()
);";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", (object)userId ?? DBNull.Value);
                command.Parameters.AddWithValue("@ScriptId", (object)scriptId ?? DBNull.Value);
                command.Parameters.AddWithValue("@PreferredArriveTime", preferredArriveTime);
                command.Parameters.AddWithValue("@TeamSize", teamSize);
                command.Parameters.AddWithValue("@ContactName", contactName ?? string.Empty);
                command.Parameters.AddWithValue("@Phone", phone ?? string.Empty);
                command.Parameters.AddWithValue("@Note", (object)note ?? DBNull.Value);

                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "到店联系单已提交，门店会根据你选择的剧本和到店时间安排开本。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public IList<StoreVisitRequestInfo> GetStoreVisitRequests(int top, int? userId = null, string statusFilter = null, string keyword = null, string dateFilter = null)
        {
            const string sql = @"
SELECT TOP (@Top)
    r.Id,
    r.UserId,
    r.ScriptId,
    ISNULL(s.Name, N'门店推荐安排') AS ScriptName,
    r.ContactName,
    r.Phone,
    r.PreferredArriveTime,
    r.TeamSize,
    r.RequestStatus,
    r.AssignedRoomName,
    r.AdminRemark,
    r.AdminReply,
    r.Note,
    r.ConfirmStatus,
    r.PlayerConfirmRemark,
    r.CreatedAt,
    r.ProcessedAt,
    r.RepliedAt,
    r.PlayerConfirmedAt
FROM dbo.StoreVisitRequests r
LEFT JOIN dbo.Scripts s ON s.Id = r.ScriptId
WHERE (@UserId IS NULL OR r.UserId = @UserId)
  AND (@StatusFilter IS NULL OR r.RequestStatus = @StatusFilter OR r.ConfirmStatus = @StatusFilter)
  AND (
        @Keyword IS NULL
        OR r.ContactName LIKE N'%' + @Keyword + N'%'
        OR r.Phone LIKE N'%' + @Keyword + N'%'
        OR ISNULL(s.Name, N'') LIKE N'%' + @Keyword + N'%'
        OR ISNULL(r.AssignedRoomName, N'') LIKE N'%' + @Keyword + N'%'
      )
  AND (
        @DateFilter IS NULL
        OR (@DateFilter = N'Today' AND CONVERT(date, r.PreferredArriveTime) = CONVERT(date, GETDATE()))
        OR (@DateFilter = N'Tomorrow' AND CONVERT(date, r.PreferredArriveTime) = CONVERT(date, DATEADD(day, 1, GETDATE())))
        OR (@DateFilter = N'Next7Days' AND r.PreferredArriveTime >= CONVERT(date, GETDATE()) AND r.PreferredArriveTime < DATEADD(day, 8, CONVERT(date, GETDATE())))
      )
ORDER BY r.CreatedAt DESC, r.Id DESC;";

            return ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@UserId", (object)userId ?? DBNull.Value);
                command.Parameters.AddWithValue("@StatusFilter", string.IsNullOrWhiteSpace(statusFilter) ? (object)DBNull.Value : statusFilter);
                command.Parameters.AddWithValue("@Keyword", string.IsNullOrWhiteSpace(keyword) ? (object)DBNull.Value : keyword.Trim());
                command.Parameters.AddWithValue("@DateFilter", string.IsNullOrWhiteSpace(dateFilter) ? (object)DBNull.Value : dateFilter);
            }, MapStoreVisitRequest);
        }

        public bool ReviewStoreVisitRequest(int requestId, string requestStatus, string assignedRoomName, string adminRemark, string adminReply, int adminUserId, out string message)
        {
            const string sql = @"
IF NOT EXISTS (SELECT 1 FROM dbo.StoreVisitRequests WHERE Id = @RequestId)
BEGIN
    RAISERROR(N'未找到对应的到店联系单。', 16, 1);
    RETURN;
END

UPDATE dbo.StoreVisitRequests
SET RequestStatus = @RequestStatus,
    AssignedRoomName = NULLIF(@AssignedRoomName, N''),
    AdminRemark = NULLIF(@AdminRemark, N''),
    AdminReply = NULLIF(@AdminReply, N''),
    ProcessedAt = GETDATE(),
    RepliedAt = CASE WHEN NULLIF(@AdminReply, N'') IS NULL THEN RepliedAt ELSE GETDATE() END,
    ProcessedByUserId = @AdminUserId
WHERE Id = @RequestId;

IF NULLIF(@AdminReply, N'') IS NOT NULL
BEGIN
    INSERT INTO dbo.AdminReplyLogs(BusinessType, BusinessId, AdminUserId, ReplyContent, VisibleToUser, CreatedAt)
    VALUES(N'StoreVisit', @RequestId, @AdminUserId, @AdminReply, 1, GETDATE());
END

INSERT INTO dbo.BusinessActionLogs(BusinessType, BusinessId, ActionType, ActionTitle, ActionContent, OperatorUserId, CreatedAt)
VALUES(N'StoreVisit', @RequestId, @RequestStatus, N'门店处理到店联系单', @AdminRemark, @AdminUserId, GETDATE());";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@RequestId", requestId);
                command.Parameters.AddWithValue("@RequestStatus", requestStatus ?? string.Empty);
                command.Parameters.AddWithValue("@AssignedRoomName", (object)assignedRoomName ?? DBNull.Value);
                command.Parameters.AddWithValue("@AdminRemark", (object)adminRemark ?? DBNull.Value);
                command.Parameters.AddWithValue("@AdminReply", (object)adminReply ?? DBNull.Value);
                command.Parameters.AddWithValue("@AdminUserId", adminUserId);

                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "到店联系单已更新。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public IList<ReviewInfo> GetLatestReviews(int top, int? scriptId = null)
        {
            const string sql = @"
SELECT TOP (@Top)
    r.Id,
    r.ScriptId,
    s.Name AS ScriptName,
    r.ReviewerName,
    r.Rating,
    r.Content,
    r.ReviewDate,
    r.HighlightTag
FROM dbo.Reviews r
INNER JOIN dbo.Scripts s ON s.Id = r.ScriptId
WHERE s.AuditStatus = N'Approved'
  AND (@ScriptId IS NULL OR r.ScriptId = @ScriptId)
ORDER BY r.ReviewDate DESC, r.Id DESC;";

            return ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@ScriptId", (object)scriptId ?? DBNull.Value);
            }, reader => new ReviewInfo
            {
                Id = GetInt32(reader, "Id"),
                ScriptId = GetInt32(reader, "ScriptId"),
                ScriptName = GetString(reader, "ScriptName"),
                ReviewerName = GetString(reader, "ReviewerName"),
                Rating = GetInt32(reader, "Rating"),
                Content = GetString(reader, "Content"),
                ReviewDate = GetDateTime(reader, "ReviewDate"),
                HighlightTag = GetString(reader, "HighlightTag")
            });
        }

        public bool CreateReservation(BookingCreateRequest request, out int reservationId, out string message)
        {
            const string sql = @"
DECLARE @RemainingSeats INT;
DECLARE @UnitPrice DECIMAL(10,2);
DECLARE @TotalAmount DECIMAL(10,2);
DECLARE @BalanceAfter DECIMAL(10,2);
DECLARE @WalletTransactionId INT;
DECLARE @ReservationId INT;

SELECT
    @RemainingSeats = s.MaxPlayers - ISNULL(SUM(CASE WHEN r.Status IN (N'待确认', N'已确认', N'申请改期') THEN r.PlayerCount ELSE 0 END), 0),
    @UnitPrice = s.BasePrice
FROM dbo.Sessions s WITH (UPDLOCK, HOLDLOCK)
INNER JOIN dbo.Scripts sc ON sc.Id = s.ScriptId
LEFT JOIN dbo.Reservations r ON r.SessionId = s.Id
WHERE s.Id = @SessionId
  AND s.Status = N'开放预约'
  AND sc.AuditStatus = N'Approved'
GROUP BY s.MaxPlayers, s.BasePrice;

IF @RemainingSeats IS NULL
BEGIN
    RAISERROR(N'当前场次不存在或已停止预约。', 16, 1);
    RETURN;
END

IF @RemainingSeats < @PlayerCount
BEGIN
    RAISERROR(N'可预约人数不足，请选择其他场次。', 16, 1);
    RETURN;
END

SET @TotalAmount = @UnitPrice * @PlayerCount;

UPDATE dbo.Users
SET Balance = Balance - @TotalAmount
WHERE Id = @UserId
  AND ReviewStatus = N'Approved'
  AND Balance >= @TotalAmount;

IF @@ROWCOUNT = 0
BEGIN
    RAISERROR(N'账户余额不足，请先充值后再预约。', 16, 1);
    RETURN;
END

SELECT @BalanceAfter = Balance
FROM dbo.Users
WHERE Id = @UserId;

INSERT INTO dbo.WalletTransactions(UserId, TransactionType, Amount, BalanceAfter, Summary, CreatedAt)
VALUES(@UserId, N'预约扣费', @TotalAmount, @BalanceAfter, N'预约场次自动扣费', GETDATE());

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
    @SessionId,
    @UserId,
    @ContactName,
    @Phone,
    @PlayerCount,
    @UnitPrice,
    @TotalAmount,
    N'已支付',
    @WalletTransactionId,
    @Remark,
    GETDATE(),
    N'待确认'
);

SET @ReservationId = SCOPE_IDENTITY();
SELECT @ReservationId;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                reservationId = 0;
                command.Parameters.AddWithValue("@UserId", request.UserId);
                command.Parameters.AddWithValue("@SessionId", request.SessionId);
                command.Parameters.AddWithValue("@ContactName", request.ContactName);
                command.Parameters.AddWithValue("@Phone", request.Phone);
                command.Parameters.AddWithValue("@PlayerCount", request.PlayerCount);
                command.Parameters.AddWithValue("@Remark", (object)request.Remark ?? DBNull.Value);

                connection.Open();
                using (var transaction = connection.BeginTransaction())
                {
                    command.Transaction = transaction;
                    try
                    {
                        reservationId = Convert.ToInt32(command.ExecuteScalar());
                        transaction.Commit();
                        message = "预约提交成功，系统已自动完成余额扣费。";
                        return true;
                    }
                    catch (SqlException ex)
                    {
                        transaction.Rollback();
                        reservationId = 0;
                        message = ex.Message;
                        return false;
                    }
                }
            }
        }

        public IList<ReservationInfo> GetRecentReservations(int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    r.Id,
    r.SessionId,
    r.ContactName,
    r.Phone,
    s.Name AS ScriptName,
    rm.Name AS RoomName,
    se.HostName,
    r.PlayerCount,
    ISNULL(r.UnitPrice, se.BasePrice) AS UnitPrice,
    ISNULL(r.TotalAmount, se.BasePrice * r.PlayerCount) AS TotalAmount,
    ISNULL(NULLIF(r.PaymentStatus, N''), N'线下确认') AS PaymentStatus,
    se.SessionDateTime,
    r.Status,
    r.AdminReply,
    r.RepliedAt,
    r.ConfirmStatus,
    r.PlayerConfirmRemark,
    r.PlayerConfirmedAt
FROM dbo.Reservations r
INNER JOIN dbo.Sessions se ON se.Id = r.SessionId
INNER JOIN dbo.Scripts s ON s.Id = se.ScriptId
INNER JOIN dbo.Rooms rm ON rm.Id = se.RoomId
WHERE s.AuditStatus = N'Approved'
ORDER BY r.CreatedAt DESC, r.Id DESC;";

            return ExecuteList(sql, command => command.Parameters.AddWithValue("@Top", top), reader => new ReservationInfo
            {
                Id = GetInt32(reader, "Id"),
                SessionId = GetInt32(reader, "SessionId"),
                ContactName = GetString(reader, "ContactName"),
                PhoneMasked = MaskPhone(GetString(reader, "Phone")),
                ScriptName = GetString(reader, "ScriptName"),
                RoomName = GetString(reader, "RoomName"),
                HostName = GetString(reader, "HostName"),
                PlayerCount = GetInt32(reader, "PlayerCount"),
                UnitPrice = GetDecimal(reader, "UnitPrice"),
                TotalAmount = GetDecimal(reader, "TotalAmount"),
                PaymentStatus = GetString(reader, "PaymentStatus"),
                SessionDateTime = GetDateTime(reader, "SessionDateTime"),
                Status = GetString(reader, "Status"),
                AdminReply = GetString(reader, "AdminReply"),
                RepliedAt = GetNullableDateTime(reader, "RepliedAt"),
                ConfirmStatus = GetString(reader, "ConfirmStatus"),
                PlayerConfirmRemark = GetString(reader, "PlayerConfirmRemark"),
                PlayerConfirmedAt = GetNullableDateTime(reader, "PlayerConfirmedAt")
            });
        }

        public ReservationInfo GetReservationDetail(int reservationId, int? userId = null)
        {
            const string sql = @"
SELECT TOP 1
    r.Id,
    r.SessionId,
    se.ScriptId,
    r.ContactName,
    r.Phone,
    s.Name AS ScriptName,
    rm.Name AS RoomName,
    se.HostName,
    r.PlayerCount,
    ISNULL(r.UnitPrice, se.BasePrice) AS UnitPrice,
    ISNULL(r.TotalAmount, se.BasePrice * r.PlayerCount) AS TotalAmount,
    ISNULL(NULLIF(r.PaymentStatus, N''), N'线下确认') AS PaymentStatus,
    se.SessionDateTime,
    r.Status,
    r.AdminReply,
    r.RepliedAt
FROM dbo.Reservations r
INNER JOIN dbo.Sessions se ON se.Id = r.SessionId
INNER JOIN dbo.Scripts s ON s.Id = se.ScriptId
INNER JOIN dbo.Rooms rm ON rm.Id = se.RoomId
WHERE r.Id = @ReservationId
  AND (@UserId IS NULL OR r.UserId = @UserId);";

            var items = ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@UserId", (object)userId ?? DBNull.Value);
            }, reader => new ReservationInfo
            {
                Id = GetInt32(reader, "Id"),
                SessionId = GetInt32(reader, "SessionId"),
                ScriptId = GetInt32(reader, "ScriptId"),
                ContactName = GetString(reader, "ContactName"),
                PhoneMasked = MaskPhone(GetString(reader, "Phone")),
                ScriptName = GetString(reader, "ScriptName"),
                RoomName = GetString(reader, "RoomName"),
                HostName = GetString(reader, "HostName"),
                PlayerCount = GetInt32(reader, "PlayerCount"),
                UnitPrice = GetDecimal(reader, "UnitPrice"),
                TotalAmount = GetDecimal(reader, "TotalAmount"),
                PaymentStatus = GetString(reader, "PaymentStatus"),
                SessionDateTime = GetDateTime(reader, "SessionDateTime"),
                Status = GetString(reader, "Status"),
                AdminReply = GetString(reader, "AdminReply"),
                RepliedAt = GetNullableDateTime(reader, "RepliedAt")
            });

            return items.Count > 0 ? items[0] : null;
        }

        public IList<ReservationInfo> GetReservationsForAdmin(int top, string statusFilter = null, string keyword = null, string dateFilter = null)
        {
            const string sql = @"
SELECT TOP (@Top)
    r.Id,
    r.SessionId,
    r.ContactName,
    r.Phone,
    s.Name AS ScriptName,
    rm.Name AS RoomName,
    se.HostName,
    r.PlayerCount,
    ISNULL(r.UnitPrice, se.BasePrice) AS UnitPrice,
    ISNULL(r.TotalAmount, se.BasePrice * r.PlayerCount) AS TotalAmount,
    ISNULL(NULLIF(r.PaymentStatus, N''), N'线下确认') AS PaymentStatus,
    r.Remark,
    r.AdminRemark,
    r.AdminReply,
    r.ConfirmStatus,
    r.PlayerConfirmRemark,
    r.CreatedAt,
    se.SessionDateTime,
    r.Status,
    r.ProcessedAt,
    r.RepliedAt,
    r.PlayerConfirmedAt
FROM dbo.Reservations r
INNER JOIN dbo.Sessions se ON se.Id = r.SessionId
INNER JOIN dbo.Scripts s ON s.Id = se.ScriptId
INNER JOIN dbo.Rooms rm ON rm.Id = se.RoomId
WHERE (@StatusFilter IS NULL OR r.Status = @StatusFilter OR r.ConfirmStatus = @StatusFilter)
  AND (
        @Keyword IS NULL
        OR r.ContactName LIKE N'%' + @Keyword + N'%'
        OR r.Phone LIKE N'%' + @Keyword + N'%'
        OR s.Name LIKE N'%' + @Keyword + N'%'
        OR rm.Name LIKE N'%' + @Keyword + N'%'
      )
  AND (
        @DateFilter IS NULL
        OR (@DateFilter = N'Today' AND CONVERT(date, se.SessionDateTime) = CONVERT(date, GETDATE()))
        OR (@DateFilter = N'Tomorrow' AND CONVERT(date, se.SessionDateTime) = CONVERT(date, DATEADD(day, 1, GETDATE())))
        OR (@DateFilter = N'Next7Days' AND se.SessionDateTime >= CONVERT(date, GETDATE()) AND se.SessionDateTime < DATEADD(day, 8, CONVERT(date, GETDATE())))
      )
ORDER BY
    CASE WHEN r.Status IN (N'待确认', N'已确认', N'已到店') THEN 0 ELSE 1 END,
    se.SessionDateTime ASC,
    r.CreatedAt DESC,
    r.Id DESC;";

            return ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@StatusFilter", string.IsNullOrWhiteSpace(statusFilter) ? (object)DBNull.Value : statusFilter);
                command.Parameters.AddWithValue("@Keyword", string.IsNullOrWhiteSpace(keyword) ? (object)DBNull.Value : keyword.Trim());
                command.Parameters.AddWithValue("@DateFilter", string.IsNullOrWhiteSpace(dateFilter) ? (object)DBNull.Value : dateFilter);
            }, MapAdminReservationInfo);
        }

        public bool ReviewReservation(int reservationId, string reservationStatus, string paymentStatus, string adminRemark, string adminReply, int adminUserId, out string message)
        {
            const string sql = @"
IF NOT EXISTS (SELECT 1 FROM dbo.Reservations WHERE Id = @ReservationId)
BEGIN
    RAISERROR(N'未找到对应的预约订单。', 16, 1);
    RETURN;
END

UPDATE dbo.Reservations
SET Status = @ReservationStatus,
    PaymentStatus = CASE WHEN @PaymentStatus IS NULL OR @PaymentStatus = N'' THEN PaymentStatus ELSE @PaymentStatus END,
    AdminRemark = NULLIF(@AdminRemark, N''),
    AdminReply = NULLIF(@AdminReply, N''),
    ProcessedAt = GETDATE(),
    RepliedAt = CASE WHEN NULLIF(@AdminReply, N'') IS NULL THEN RepliedAt ELSE GETDATE() END,
    ProcessedByUserId = @AdminUserId
WHERE Id = @ReservationId;

IF NULLIF(@AdminReply, N'') IS NOT NULL
BEGIN
    INSERT INTO dbo.AdminReplyLogs(BusinessType, BusinessId, AdminUserId, ReplyContent, VisibleToUser, CreatedAt)
    VALUES(N'Reservation', @ReservationId, @AdminUserId, @AdminReply, 1, GETDATE());
END

INSERT INTO dbo.BusinessActionLogs(BusinessType, BusinessId, ActionType, ActionTitle, ActionContent, OperatorUserId, CreatedAt)
VALUES(N'Reservation', @ReservationId, @ReservationStatus, N'门店处理预约订单', @AdminRemark, @AdminUserId, GETDATE());";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@ReservationStatus", reservationStatus ?? string.Empty);
                command.Parameters.AddWithValue("@PaymentStatus", string.IsNullOrWhiteSpace(paymentStatus) ? (object)DBNull.Value : paymentStatus);
                command.Parameters.AddWithValue("@AdminRemark", (object)adminRemark ?? DBNull.Value);
                command.Parameters.AddWithValue("@AdminReply", (object)adminReply ?? DBNull.Value);
                command.Parameters.AddWithValue("@AdminUserId", adminUserId);

                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "预约订单状态已更新。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public bool ConfirmStoreVisitRequestByPlayer(int requestId, int userId, out string message)
        {
            const string sql = @"
UPDATE dbo.StoreVisitRequests
SET ConfirmStatus = N'已收到',
    RequestStatus = CASE WHEN RequestStatus = N'已安排排期' THEN N'玩家已确认' ELSE RequestStatus END,
    PlayerConfirmRemark = NULL,
    PlayerConfirmedAt = GETDATE()
WHERE Id = @RequestId
  AND UserId = @UserId;

IF @@ROWCOUNT = 0
BEGIN
    RAISERROR(N'未找到可确认的到店联系单。', 16, 1);
    RETURN;
END

INSERT INTO dbo.BusinessActionLogs(BusinessType, BusinessId, ActionType, ActionTitle, ActionContent, OperatorUserId, CreatedAt)
VALUES(N'StoreVisit', @RequestId, N'玩家已确认', N'玩家确认收到门店回复', NULL, @UserId, GETDATE());";

            return ExecuteNonQuery(sql, command =>
            {
                command.Parameters.AddWithValue("@RequestId", requestId);
                command.Parameters.AddWithValue("@UserId", userId);
            }, "已确认收到门店回复。", out message);
        }

        public bool RequestStoreVisitReschedule(int requestId, int userId, string remark, out string message)
        {
            const string sql = @"
IF NULLIF(@Remark, N'') IS NULL
BEGIN
    RAISERROR(N'请填写希望改期的时间或原因。', 16, 1);
    RETURN;
END

UPDATE dbo.StoreVisitRequests
SET ConfirmStatus = N'申请改期',
    RequestStatus = N'玩家申请改期',
    PlayerConfirmRemark = @Remark,
    PlayerConfirmedAt = GETDATE()
WHERE Id = @RequestId
  AND UserId = @UserId;

IF @@ROWCOUNT = 0
BEGIN
    RAISERROR(N'未找到可申请改期的到店联系单。', 16, 1);
    RETURN;
END

INSERT INTO dbo.BusinessActionLogs(BusinessType, BusinessId, ActionType, ActionTitle, ActionContent, OperatorUserId, CreatedAt)
VALUES(N'StoreVisit', @RequestId, N'申请改期', N'玩家申请到店改期', @Remark, @UserId, GETDATE());";

            return ExecuteNonQuery(sql, command =>
            {
                command.Parameters.AddWithValue("@RequestId", requestId);
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@Remark", (object)(remark ?? string.Empty));
            }, "已提交改期申请，等待门店重新回复。", out message);
        }

        public bool ConfirmReservationByPlayer(int reservationId, int userId, out string message)
        {
            const string sql = @"
UPDATE dbo.Reservations
SET ConfirmStatus = N'已收到',
    Status = CASE WHEN Status = N'已确认' THEN N'玩家已确认' ELSE Status END,
    PlayerConfirmRemark = NULL,
    PlayerConfirmedAt = GETDATE()
WHERE Id = @ReservationId
  AND UserId = @UserId;

IF @@ROWCOUNT = 0
BEGIN
    RAISERROR(N'未找到可确认的预约订单。', 16, 1);
    RETURN;
END

INSERT INTO dbo.BusinessActionLogs(BusinessType, BusinessId, ActionType, ActionTitle, ActionContent, OperatorUserId, CreatedAt)
VALUES(N'Reservation', @ReservationId, N'玩家已确认', N'玩家确认收到预约回复', NULL, @UserId, GETDATE());";

            return ExecuteNonQuery(sql, command =>
            {
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@UserId", userId);
            }, "已确认收到预约回复。", out message);
        }

        public bool RequestReservationReschedule(int reservationId, int userId, string remark, out string message)
        {
            const string sql = @"
IF NULLIF(@Remark, N'') IS NULL
BEGIN
    RAISERROR(N'请填写希望改期的时间或原因。', 16, 1);
    RETURN;
END

UPDATE dbo.Reservations
SET ConfirmStatus = N'申请改期',
    Status = N'申请改期',
    PlayerConfirmRemark = @Remark,
    PlayerConfirmedAt = GETDATE()
WHERE Id = @ReservationId
  AND UserId = @UserId;

IF @@ROWCOUNT = 0
BEGIN
    RAISERROR(N'未找到可申请改期的预约订单。', 16, 1);
    RETURN;
END

INSERT INTO dbo.BusinessActionLogs(BusinessType, BusinessId, ActionType, ActionTitle, ActionContent, OperatorUserId, CreatedAt)
VALUES(N'Reservation', @ReservationId, N'申请改期', N'玩家申请预约改期', @Remark, @UserId, GETDATE());";

            return ExecuteNonQuery(sql, command =>
            {
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@Remark", (object)(remark ?? string.Empty));
            }, "已提交改期申请，等待门店重新回复。", out message);
        }

        public IList<AdminReplyLogInfo> GetRecentAdminReplyLogs(int top, string businessType = null, int? businessId = null)
        {
            const string sql = @"
SELECT TOP (@Top)
    l.Id,
    l.BusinessType,
    l.BusinessId,
    l.AdminUserId,
    ISNULL(u.DisplayName, N'门店管理员') AS AdminName,
    l.ReplyContent,
    l.VisibleToUser,
    l.CreatedAt
FROM dbo.AdminReplyLogs l
LEFT JOIN dbo.Users u ON u.Id = l.AdminUserId
WHERE (@BusinessType IS NULL OR l.BusinessType = @BusinessType)
  AND (@BusinessId IS NULL OR l.BusinessId = @BusinessId)
ORDER BY l.CreatedAt DESC, l.Id DESC;";

            return ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@BusinessType", string.IsNullOrWhiteSpace(businessType) ? (object)DBNull.Value : businessType);
                command.Parameters.AddWithValue("@BusinessId", (object)businessId ?? DBNull.Value);
            }, reader => new AdminReplyLogInfo
            {
                Id = GetInt32(reader, "Id"),
                BusinessType = GetString(reader, "BusinessType"),
                BusinessId = GetInt32(reader, "BusinessId"),
                AdminUserId = GetNullableInt32(reader, "AdminUserId"),
                AdminName = GetString(reader, "AdminName"),
                ReplyContent = GetString(reader, "ReplyContent"),
                VisibleToUser = GetBoolean(reader, "VisibleToUser"),
                CreatedAt = GetDateTime(reader, "CreatedAt")
            });
        }

        public IList<BusinessActionLogInfo> GetRecentBusinessActionLogs(int top, string businessType = null, int? businessId = null)
        {
            const string sql = @"
SELECT TOP (@Top)
    l.Id,
    l.BusinessType,
    l.BusinessId,
    l.ActionType,
    l.ActionTitle,
    l.ActionContent,
    l.OperatorUserId,
    ISNULL(u.DisplayName, N'绯荤粺') AS OperatorName,
    l.CreatedAt
FROM dbo.BusinessActionLogs l
LEFT JOIN dbo.Users u ON u.Id = l.OperatorUserId
WHERE (@BusinessType IS NULL OR l.BusinessType = @BusinessType)
  AND (@BusinessId IS NULL OR l.BusinessId = @BusinessId)
ORDER BY l.CreatedAt DESC, l.Id DESC;";

            return ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@BusinessType", string.IsNullOrWhiteSpace(businessType) ? (object)DBNull.Value : businessType);
                command.Parameters.AddWithValue("@BusinessId", (object)businessId ?? DBNull.Value);
            }, reader => new BusinessActionLogInfo
            {
                Id = GetInt32(reader, "Id"),
                BusinessType = GetString(reader, "BusinessType"),
                BusinessId = GetInt32(reader, "BusinessId"),
                ActionType = GetString(reader, "ActionType"),
                ActionTitle = GetString(reader, "ActionTitle"),
                ActionContent = GetString(reader, "ActionContent"),
                OperatorUserId = GetNullableInt32(reader, "OperatorUserId"),
                OperatorName = GetString(reader, "OperatorName"),
                CreatedAt = GetDateTime(reader, "CreatedAt")
            });
        }

        public IList<RoomParticipantInfo> GetRoomParticipants(int sessionId)
        {
            const string sql = @"
SELECT
    r.Id AS ReservationId,
    r.UserId,
    ISNULL(u.DisplayName, r.ContactName) AS DisplayName,
    r.ContactName,
    rm.Name AS RoomName,
    r.PlayerCount,
    r.Status,
    ISNULL(p.CameraEnabled, 0) AS CameraEnabled,
    ISNULL(p.MicrophoneEnabled, 0) AS MicrophoneEnabled,
    p.VideoSnapshot,
    p.UpdatedAt
FROM dbo.Reservations r
INNER JOIN dbo.Sessions s ON s.Id = r.SessionId
INNER JOIN dbo.Rooms rm ON rm.Id = s.RoomId
LEFT JOIN dbo.Users u ON u.Id = r.UserId
LEFT JOIN dbo.RoomPresence p ON p.ReservationId = r.Id
WHERE r.SessionId = @SessionId
ORDER BY r.Id ASC;";

            return ExecuteList(sql, command => command.Parameters.AddWithValue("@SessionId", sessionId), reader => new RoomParticipantInfo
            {
                ReservationId = GetInt32(reader, "ReservationId"),
                UserId = GetNullableInt32(reader, "UserId"),
                DisplayName = GetString(reader, "DisplayName"),
                ContactName = GetString(reader, "ContactName"),
                RoomName = GetString(reader, "RoomName"),
                PlayerCount = GetInt32(reader, "PlayerCount"),
                Status = GetString(reader, "Status"),
                CameraEnabled = GetBoolean(reader, "CameraEnabled"),
                MicrophoneEnabled = GetBoolean(reader, "MicrophoneEnabled"),
                VideoSnapshot = GetString(reader, "VideoSnapshot"),
                UpdatedAt = GetNullableDateTime(reader, "UpdatedAt")
            });
        }

        public IList<RoomMessageInfo> GetRoomMessages(int sessionId, int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    Id,
    SessionId,
    ReservationId,
    UserId,
    SenderName,
    MessageType,
    Content,
    MediaData,
    DurationSeconds,
    SentAt
FROM dbo.RoomMessages
WHERE SessionId = @SessionId
ORDER BY Id DESC;";

            var messages = ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@SessionId", sessionId);
            }, reader => new RoomMessageInfo
            {
                Id = GetInt32(reader, "Id"),
                SessionId = GetInt32(reader, "SessionId"),
                ReservationId = GetInt32(reader, "ReservationId"),
                UserId = GetNullableInt32(reader, "UserId"),
                SenderName = GetString(reader, "SenderName"),
                MessageType = GetString(reader, "MessageType"),
                Content = GetString(reader, "Content"),
                MediaData = GetString(reader, "MediaData"),
                DurationSeconds = GetNullableInt32(reader, "DurationSeconds"),
                SentAt = GetDateTime(reader, "SentAt")
            });

            var orderedMessages = new List<RoomMessageInfo>(messages);
            orderedMessages.Reverse();
            return orderedMessages;
        }

        public bool AddRoomTextMessage(int sessionId, int reservationId, int? userId, string senderName, string content, out string message)
        {
            const string sql = @"
INSERT INTO dbo.RoomMessages(SessionId, ReservationId, UserId, SenderName, MessageType, Content, MediaData, DurationSeconds, SentAt)
VALUES(@SessionId, @ReservationId, @UserId, @SenderName, N'Text', @Content, NULL, NULL, GETDATE());";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@SessionId", sessionId);
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@UserId", (object)userId ?? DBNull.Value);
                command.Parameters.AddWithValue("@SenderName", senderName);
                command.Parameters.AddWithValue("@Content", content);
                connection.Open();
                command.ExecuteNonQuery();
                message = "消息已发送。";
                return true;
            }
        }

        public bool AddRoomVoiceMessage(int sessionId, int reservationId, int? userId, string senderName, string audioDataUrl, int durationSeconds, out string message)
        {
            const string sql = @"
INSERT INTO dbo.RoomMessages(SessionId, ReservationId, UserId, SenderName, MessageType, Content, MediaData, DurationSeconds, SentAt)
VALUES(@SessionId, @ReservationId, @UserId, @SenderName, N'Voice', @Content, @MediaData, @DurationSeconds, GETDATE());";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@SessionId", sessionId);
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@UserId", (object)userId ?? DBNull.Value);
                command.Parameters.AddWithValue("@SenderName", senderName);
                command.Parameters.AddWithValue("@Content", "发送了一条语音留言");
                command.Parameters.AddWithValue("@MediaData", audioDataUrl);
                command.Parameters.AddWithValue("@DurationSeconds", durationSeconds);
                connection.Open();
                command.ExecuteNonQuery();
                message = "语音留言已发送。";
                return true;
            }
        }

        public void UpsertRoomPresence(int sessionId, int reservationId, int? userId, string displayName, bool cameraEnabled, bool microphoneEnabled, string snapshotDataUrl)
        {
            const string sql = @"
IF EXISTS (SELECT 1 FROM dbo.RoomPresence WHERE ReservationId = @ReservationId)
BEGIN
    UPDATE dbo.RoomPresence
    SET SessionId = @SessionId,
        UserId = @UserId,
        DisplayName = @DisplayName,
        CameraEnabled = @CameraEnabled,
        MicrophoneEnabled = @MicrophoneEnabled,
        VideoSnapshot = CASE WHEN @SnapshotDataUrl = N'' THEN VideoSnapshot ELSE @SnapshotDataUrl END,
        UpdatedAt = GETDATE()
    WHERE ReservationId = @ReservationId;
END
ELSE
BEGIN
    INSERT INTO dbo.RoomPresence(SessionId, ReservationId, UserId, DisplayName, CameraEnabled, MicrophoneEnabled, VideoSnapshot, UpdatedAt)
    VALUES(@SessionId, @ReservationId, @UserId, @DisplayName, @CameraEnabled, @MicrophoneEnabled, NULLIF(@SnapshotDataUrl, N''), GETDATE());
END";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@SessionId", sessionId);
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@UserId", (object)userId ?? DBNull.Value);
                command.Parameters.AddWithValue("@DisplayName", displayName);
                command.Parameters.AddWithValue("@CameraEnabled", cameraEnabled);
                command.Parameters.AddWithValue("@MicrophoneEnabled", microphoneEnabled);
                command.Parameters.AddWithValue("@SnapshotDataUrl", snapshotDataUrl ?? string.Empty);
                connection.Open();
                command.ExecuteNonQuery();
            }
        }

        public bool CreateScriptSubmission(int creatorUserId, ScriptSubmissionRequest request, out string message)
        {
            const string sql = @"
INSERT INTO dbo.Scripts
(
    GenreId,
    Name,
    Slogan,
    StoryBackground,
    CoverImage,
    DurationMinutes,
    PlayerMin,
    PlayerMax,
    Difficulty,
    Price,
    IsFeatured,
    Status,
    AuthorName,
    CreatorUserId,
    AuditStatus,
    AuditComment,
    SubmittedAt,
    ReviewedAt
)
VALUES
(
    @GenreId,
    @Name,
    @Slogan,
    @StoryBackground,
    @CoverImage,
    @DurationMinutes,
    @PlayerMin,
    @PlayerMax,
    @Difficulty,
    @Price,
    0,
    N'待排期',
    @AuthorName,
    @CreatorUserId,
    N'Pending',
    NULL,
    GETDATE(),
    NULL
);";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@GenreId", request.GenreId);
                command.Parameters.AddWithValue("@Name", request.Name);
                command.Parameters.AddWithValue("@Slogan", request.Slogan);
                command.Parameters.AddWithValue("@StoryBackground", request.StoryBackground);
                command.Parameters.AddWithValue("@CoverImage", request.CoverImage);
                command.Parameters.AddWithValue("@DurationMinutes", request.DurationMinutes);
                command.Parameters.AddWithValue("@PlayerMin", request.PlayerMin);
                command.Parameters.AddWithValue("@PlayerMax", request.PlayerMax);
                command.Parameters.AddWithValue("@Difficulty", request.Difficulty);
                command.Parameters.AddWithValue("@Price", request.Price);
                command.Parameters.AddWithValue("@AuthorName", request.AuthorName);
                command.Parameters.AddWithValue("@CreatorUserId", creatorUserId);

                connection.Open();
                command.ExecuteNonQuery();
                message = "剧本投稿已提交，等待管理员审核。";
                return true;
            }
        }

        public IList<ScriptInfo> GetScriptsByCreator(int creatorUserId)
        {
            const string sql = @"
SELECT
    s.Id,
    s.GenreId,
    g.Name AS GenreName,
    s.Name,
    s.Slogan,
    s.StoryBackground,
    s.FullScriptContent,
    s.CoverImage,
    s.DurationMinutes,
    s.PlayerMin,
    s.PlayerMax,
    s.Difficulty,
    s.Price,
    s.IsFeatured,
    s.Status,
    s.AuthorName,
    CAST(ISNULL((
        SELECT AVG(CAST(r.Rating AS DECIMAL(10,2)))
        FROM dbo.Reviews r
        WHERE r.ScriptId = s.Id
    ), 0) AS DECIMAL(10,2)) AS AverageRating,
    (
        SELECT COUNT(1)
        FROM dbo.Reviews r
        WHERE r.ScriptId = s.Id
    ) AS ReviewCount,
    (
        SELECT COUNT(1)
        FROM dbo.Sessions se
        WHERE se.ScriptId = s.Id AND se.Status = N'开放预约' AND se.SessionDateTime >= GETDATE()
    ) AS UpcomingSessionCount,
    s.CreatorUserId,
    ISNULL(u.DisplayName, N'') AS CreatorDisplayName,
    s.AuditStatus,
    s.AuditComment,
    s.SubmittedAt,
    s.ReviewedAt
FROM dbo.Scripts s
INNER JOIN dbo.Genres g ON g.Id = s.GenreId
LEFT JOIN dbo.Users u ON u.Id = s.CreatorUserId
WHERE s.CreatorUserId = @CreatorUserId
ORDER BY s.SubmittedAt DESC, s.Id DESC;";

            return ExecuteScriptList(sql, command =>
            {
                command.Parameters.AddWithValue("@CreatorUserId", creatorUserId);
            }, usesTop: false);
        }

        public IList<ScriptInfo> GetPendingScriptSubmissions()
        {
            const string sql = @"
SELECT
    s.Id,
    s.GenreId,
    g.Name AS GenreName,
    s.Name,
    s.Slogan,
    s.StoryBackground,
    s.FullScriptContent,
    s.CoverImage,
    s.DurationMinutes,
    s.PlayerMin,
    s.PlayerMax,
    s.Difficulty,
    s.Price,
    s.IsFeatured,
    s.Status,
    s.AuthorName,
    CAST(0 AS DECIMAL(10,2)) AS AverageRating,
    0 AS ReviewCount,
    0 AS UpcomingSessionCount,
    s.CreatorUserId,
    ISNULL(u.DisplayName, N'') AS CreatorDisplayName,
    s.AuditStatus,
    s.AuditComment,
    s.SubmittedAt,
    s.ReviewedAt
FROM dbo.Scripts s
INNER JOIN dbo.Genres g ON g.Id = s.GenreId
LEFT JOIN dbo.Users u ON u.Id = s.CreatorUserId
WHERE s.AuditStatus = N'Pending'
ORDER BY s.SubmittedAt ASC, s.Id ASC;";

            return ExecuteScriptList(sql, null, usesTop: false);
        }

        public bool ReviewScriptSubmission(int scriptId, bool approved, string comment, out string message)
        {
            const string sql = @"
UPDATE dbo.Scripts
SET AuditStatus = @AuditStatus,
    AuditComment = @AuditComment,
    ReviewedAt = GETDATE(),
    Status = CASE WHEN @AuditStatus = N'Approved' THEN N'开放预约' ELSE Status END
WHERE Id = @ScriptId;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@AuditStatus", approved ? "Approved" : "Rejected");
                command.Parameters.AddWithValue("@AuditComment", (object)comment ?? DBNull.Value);
                command.Parameters.AddWithValue("@ScriptId", scriptId);

                connection.Open();
                var affectedRows = command.ExecuteNonQuery();
                message = affectedRows > 0 ? "剧本审核已处理。" : "未找到对应投稿。";
                return affectedRows > 0;
            }
        }

        public IList<ScriptInfo> GetAllScriptsForAdmin()
        {
            const string sql = @"
SELECT
    s.Id,
    s.GenreId,
    g.Name AS GenreName,
    s.Name,
    s.Slogan,
    s.StoryBackground,
    s.FullScriptContent,
    s.CoverImage,
    s.DurationMinutes,
    s.PlayerMin,
    s.PlayerMax,
    s.Difficulty,
    s.Price,
    s.IsFeatured,
    s.Status,
    s.AuthorName,
    CAST(ISNULL((
        SELECT AVG(CAST(r.Rating AS DECIMAL(10,2)))
        FROM dbo.Reviews r
        WHERE r.ScriptId = s.Id
    ), 0) AS DECIMAL(10,2)) AS AverageRating,
    (
        SELECT COUNT(1)
        FROM dbo.Reviews r
        WHERE r.ScriptId = s.Id
    ) AS ReviewCount,
    (
        SELECT COUNT(1)
        FROM dbo.Sessions se
        WHERE se.ScriptId = s.Id
    ) AS UpcomingSessionCount,
    s.CreatorUserId,
    ISNULL(u.DisplayName, N'') AS CreatorDisplayName,
    s.AuditStatus,
    s.AuditComment,
    s.SubmittedAt,
    s.ReviewedAt
FROM dbo.Scripts s
INNER JOIN dbo.Genres g ON g.Id = s.GenreId
LEFT JOIN dbo.Users u ON u.Id = s.CreatorUserId
ORDER BY s.Id DESC;";

            return ExecuteScriptList(sql, null, usesTop: false);
        }

        public bool DeleteScript(int scriptId, out string message)
        {
            const string sql = @"
IF NOT EXISTS (SELECT 1 FROM dbo.Scripts WHERE Id = @ScriptId)
BEGIN
    RAISERROR(N'未找到对应剧本。', 16, 1);
    RETURN;
END

DELETE r
FROM dbo.Reservations r
INNER JOIN dbo.Sessions s ON s.Id = r.SessionId
WHERE s.ScriptId = @ScriptId;

DELETE FROM dbo.Sessions WHERE ScriptId = @ScriptId;
DELETE FROM dbo.Reviews WHERE ScriptId = @ScriptId;
DELETE FROM dbo.ScriptCharacters WHERE ScriptId = @ScriptId;
DELETE FROM dbo.Scripts WHERE Id = @ScriptId;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@ScriptId", scriptId);
                connection.Open();

                using (var transaction = connection.BeginTransaction())
                {
                    command.Transaction = transaction;
                    try
                    {
                        command.ExecuteNonQuery();
                        transaction.Commit();
                        message = "剧本及其关联数据已删除。";
                        return true;
                    }
                    catch (SqlException ex)
                    {
                        transaction.Rollback();
                        message = ex.Message;
                        return false;
                    }
                }
            }
        }

        private IList<ScriptInfo> ExecuteScriptList(string sql, Action<SqlCommand> parameterize, bool usesTop = true)
        {
            return ExecuteList(sql, command =>
            {
                parameterize?.Invoke(command);

                if (usesTop)
                {
                    var hasTop = false;
                    foreach (SqlParameter parameter in command.Parameters)
                    {
                        if (parameter.ParameterName == "@Top")
                        {
                            hasTop = true;
                            break;
                        }
                    }

                    if (!hasTop)
                    {
                        command.Parameters.AddWithValue("@Top", 999);
                    }
                }
            }, reader => new ScriptInfo
            {
                Id = GetInt32(reader, "Id"),
                GenreId = GetInt32(reader, "GenreId"),
                GenreName = GetString(reader, "GenreName"),
                Name = GetString(reader, "Name"),
                Slogan = LocalizeImportedPlaceholder(GetString(reader, "Slogan")),
                StoryBackground = LocalizeImportedPlaceholder(GetString(reader, "StoryBackground")),
                FullScriptContent = LocalizeImportedPlaceholder(GetString(reader, "FullScriptContent")),
                CoverImage = GetString(reader, "CoverImage"),
                DurationMinutes = GetInt32(reader, "DurationMinutes"),
                PlayerMin = GetInt32(reader, "PlayerMin"),
                PlayerMax = GetInt32(reader, "PlayerMax"),
                Difficulty = LocalizeImportedPlaceholder(GetString(reader, "Difficulty")),
                Price = GetDecimal(reader, "Price"),
                IsFeatured = GetBoolean(reader, "IsFeatured"),
                Status = GetString(reader, "Status"),
                AuthorName = LocalizeImportedPlaceholder(GetString(reader, "AuthorName")),
                AverageRating = GetDecimal(reader, "AverageRating"),
                ReviewCount = GetInt32(reader, "ReviewCount"),
                UpcomingSessionCount = GetInt32(reader, "UpcomingSessionCount"),
                CreatorUserId = GetNullableInt32(reader, "CreatorUserId"),
                CreatorDisplayName = GetString(reader, "CreatorDisplayName"),
                AuditStatus = GetString(reader, "AuditStatus"),
                AuditComment = LocalizeImportedPlaceholder(GetString(reader, "AuditComment")),
                SubmittedAt = GetNullableDateTime(reader, "SubmittedAt"),
                ReviewedAt = GetNullableDateTime(reader, "ReviewedAt")
            });
        }

        private IList<T> ExecuteList<T>(string sql, Action<SqlCommand> parameterize, Func<SqlDataReader, T> map)
        {
            var results = new List<T>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                parameterize?.Invoke(command);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(map(reader));
                    }
                }
            }

            return results;
        }

        private bool ExecuteNonQuery(string sql, Action<SqlCommand> parameterize, string successMessage, out string message)
        {
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                parameterize?.Invoke(command);
                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = successMessage;
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        private static SessionInfo MapSession(SqlDataReader reader)
        {
            return new SessionInfo
            {
                Id = GetInt32(reader, "Id"),
                ScriptId = GetInt32(reader, "ScriptId"),
                RoomId = GetInt32(reader, "RoomId"),
                ScriptName = GetString(reader, "ScriptName"),
                RoomName = GetString(reader, "RoomName"),
                SessionDateTime = GetDateTime(reader, "SessionDateTime"),
                HostName = GetString(reader, "HostName"),
                BasePrice = GetDecimal(reader, "BasePrice"),
                MaxPlayers = GetInt32(reader, "MaxPlayers"),
                ReservedPlayers = GetInt32(reader, "ReservedPlayers"),
                RemainingSeats = GetInt32(reader, "RemainingSeats"),
                Status = GetString(reader, "Status")
            };
        }

        private static StoreVisitRequestInfo MapStoreVisitRequest(SqlDataReader reader)
        {
            var phone = GetString(reader, "Phone");

            return new StoreVisitRequestInfo
            {
                Id = GetInt32(reader, "Id"),
                UserId = GetNullableInt32(reader, "UserId"),
                ScriptId = GetNullableInt32(reader, "ScriptId"),
                ScriptName = GetString(reader, "ScriptName"),
                ContactName = GetString(reader, "ContactName"),
                Phone = phone,
                PhoneMasked = MaskPhone(phone),
                PreferredArriveTime = GetDateTime(reader, "PreferredArriveTime"),
                TeamSize = GetInt32(reader, "TeamSize"),
                RequestStatus = GetString(reader, "RequestStatus"),
                AssignedRoomName = GetString(reader, "AssignedRoomName"),
                AdminRemark = GetString(reader, "AdminRemark"),
                AdminReply = GetString(reader, "AdminReply"),
                Note = GetString(reader, "Note"),
                ConfirmStatus = GetString(reader, "ConfirmStatus"),
                PlayerConfirmRemark = GetString(reader, "PlayerConfirmRemark"),
                CreatedAt = GetDateTime(reader, "CreatedAt"),
                ProcessedAt = GetNullableDateTime(reader, "ProcessedAt"),
                RepliedAt = GetNullableDateTime(reader, "RepliedAt"),
                PlayerConfirmedAt = GetNullableDateTime(reader, "PlayerConfirmedAt")
            };
        }

        private static ReservationInfo MapAdminReservationInfo(SqlDataReader reader)
        {
            var phone = GetString(reader, "Phone");

            return new ReservationInfo
            {
                Id = GetInt32(reader, "Id"),
                SessionId = GetInt32(reader, "SessionId"),
                ContactName = GetString(reader, "ContactName"),
                Phone = phone,
                PhoneMasked = MaskPhone(phone),
                ScriptName = GetString(reader, "ScriptName"),
                RoomName = GetString(reader, "RoomName"),
                HostName = GetString(reader, "HostName"),
                PlayerCount = GetInt32(reader, "PlayerCount"),
                UnitPrice = GetDecimal(reader, "UnitPrice"),
                TotalAmount = GetDecimal(reader, "TotalAmount"),
                PaymentStatus = GetString(reader, "PaymentStatus"),
                Remark = GetString(reader, "Remark"),
                AdminRemark = GetString(reader, "AdminRemark"),
                AdminReply = GetString(reader, "AdminReply"),
                ConfirmStatus = GetString(reader, "ConfirmStatus"),
                PlayerConfirmRemark = GetString(reader, "PlayerConfirmRemark"),
                CreatedAt = GetDateTime(reader, "CreatedAt"),
                SessionDateTime = GetDateTime(reader, "SessionDateTime"),
                Status = GetString(reader, "Status"),
                ProcessedAt = GetNullableDateTime(reader, "ProcessedAt"),
                RepliedAt = GetNullableDateTime(reader, "RepliedAt"),
                PlayerConfirmedAt = GetNullableDateTime(reader, "PlayerConfirmedAt")
            };
        }

        private static string GetString(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? string.Empty : Convert.ToString(reader[columnName]);
        }

        private static string LocalizeImportedPlaceholder(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return value;
            }

            var text = value.Trim();
            switch (text)
            {
                case "Original package imported without content rewrite":
                    return "原始剧本资料包已完整导入，正文和素材保持原样。";
                case "Original Package Import":
                    return "原始资料包导入";
                case "Bulk imported from local playable package library.":
                    return "已从本地可玩剧本资料库批量导入。";
                case "Unknown":
                    return "未标注";
                case "See original package":
                    return "详见原始资料包";
                case "Imported Package":
                    return "导入资料包";
                case "Original role data is preserved inside the imported package files.":
                    return "原始角色资料已保留在导入的剧本文件中，可在原始剧本资料包中打开对应 PDF 查看。";
                case "Cinematic":
                case "Immersive":
                    return "沉浸";
                case "Story":
                    return "剧情";
            }

            if (text.StartsWith("Original playable script package imported intact. Files indexed: PDFs=", StringComparison.OrdinalIgnoreCase))
            {
                return text
                    .Replace("Original playable script package imported intact. Files indexed: PDFs=", "原始可玩剧本资料包已完整导入。文件索引：PDF ")
                    .Replace(", Images=", " 个，图片 ")
                    .Replace(", Media=", " 个，媒体 ")
                    .Replace(".", " 个。");
            }

            return text
                .Replace("Original script package:", "原始剧本资料包：")
                .Replace("Package folder:", "资料包目录：")
                .Replace("Primary document:", "主文档：")
                .Replace("Detected files:", "识别到的文件：")
                .Replace("Original file index:", "原始文件索引：")
                .Replace("Image=", "图片=")
                .Replace("Media=", "媒体=");
        }

        private static int GetInt32(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? 0 : Convert.ToInt32(reader[columnName]);
        }

        private static int? GetNullableInt32(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? (int?)null : Convert.ToInt32(reader[columnName]);
        }

        private static long GetInt64(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? 0L : Convert.ToInt64(reader[columnName]);
        }

        private static decimal GetDecimal(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? 0M : Convert.ToDecimal(reader[columnName]);
        }

        private static DateTime GetDateTime(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? DateTime.MinValue : Convert.ToDateTime(reader[columnName]);
        }

        private static DateTime? GetNullableDateTime(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader[columnName]);
        }

        private static bool GetBoolean(SqlDataReader reader, string columnName)
        {
            return reader[columnName] != DBNull.Value && Convert.ToBoolean(reader[columnName]);
        }

        private static string MaskPhone(string phone)
        {
            if (string.IsNullOrWhiteSpace(phone) || phone.Length < 7)
            {
                return phone;
            }

            return phone.Substring(0, 3) + "****" + phone.Substring(phone.Length - 4);
        }
    }
}



