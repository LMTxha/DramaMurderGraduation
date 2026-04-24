using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
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

        public IList<RecommendationInfo> GetRepurchaseRecommendations(int userId, int top)
        {
            const string sql = @"
WITH UserPreference AS
(
    SELECT
        ISNULL(NULLIF(MAX(pp.FavoriteGenre), N''), N'') AS FavoriteGenre,
        (
            SELECT TOP 1 rv.PlayerCount
            FROM dbo.Reservations rv
            INNER JOIN dbo.Sessions se ON se.Id = rv.SessionId
            WHERE rv.UserId = @UserId
              AND rv.Status IN (N'已完成', N'已到店', N'已确认', N'玩家已确认')
            GROUP BY rv.PlayerCount
            ORDER BY COUNT(1) DESC, MAX(rv.CreatedAt) DESC, rv.PlayerCount DESC
        ) AS PreferredPlayerCount
    FROM dbo.Users u
    LEFT JOIN dbo.PlayerProfiles pp ON pp.UserId = u.Id
    WHERE u.Id = @UserId
)
SELECT TOP (@Top)
    s.Id,
    s.Name AS Title,
    ISNULL(NULLIF(s.Slogan, N''), LEFT(s.StoryBackground, 88)) AS Summary,
    s.CoverImage,
    ISNULL(pref.PreferredPlayerCount, 0) AS PlayerCount,
    s.PlayerMin AS MinPlayerCount,
    s.PlayerMax AS MaxPlayerCount,
    s.Difficulty,
    reviewStat.AverageRating AS Rating,
    CASE
        WHEN pref.FavoriteGenre <> N'' AND g.Name = pref.FavoriteGenre THEN N'偏好题材'
        WHEN pref.PreferredPlayerCount IS NOT NULL AND pref.PreferredPlayerCount BETWEEN s.PlayerMin AND s.PlayerMax THEN N'适合组车'
        WHEN sessionStat.UpcomingSessionCount > 0 THEN N'近期可约'
        ELSE N'口碑推荐'
    END AS HighlightTag,
    g.Name AS GenreName,
    sessionStat.UpcomingSessionCount,
    sessionStat.NextSessionDateTime,
    CASE
        WHEN pref.FavoriteGenre <> N'' AND g.Name = pref.FavoriteGenre
             AND pref.PreferredPlayerCount IS NOT NULL
             AND pref.PreferredPlayerCount BETWEEN s.PlayerMin AND s.PlayerMax
            THEN N'延续你常玩的' + pref.FavoriteGenre + N'题材，也适合你常组的' + CAST(pref.PreferredPlayerCount AS nvarchar(10)) + N'人车'
        WHEN pref.FavoriteGenre <> N'' AND g.Name = pref.FavoriteGenre
            THEN N'延续你常玩的' + pref.FavoriteGenre + N'题材，适合作为下一场安排'
        WHEN pref.PreferredPlayerCount IS NOT NULL AND pref.PreferredPlayerCount BETWEEN s.PlayerMin AND s.PlayerMax
            THEN N'适合你常组的' + CAST(pref.PreferredPlayerCount AS nvarchar(10)) + N'人车，拉好友继续开团更顺手'
        WHEN reviewStat.AverageRating >= 4.5
            THEN N'口碑评分稳定在高位，适合优先排进下一场'
        ELSE N'近期可约场次较多，方便你直接续下一局'
    END AS RecommendationReason,
    CASE
        WHEN sessionStat.UpcomingSessionCount > 0 AND sessionStat.NextSessionDateTime IS NOT NULL
            THEN N'最近场次 ' + CONVERT(nvarchar(16), sessionStat.NextSessionDateTime, 120) + N' / 可约 ' + CAST(sessionStat.UpcomingSessionCount AS nvarchar(10)) + N' 场'
        WHEN sessionStat.UpcomingSessionCount > 0
            THEN N'当前仍有开放预约场次'
        ELSE N'当前可先查看详情，等待下一轮排期'
    END AS SecondaryReason,
    N'Booking.aspx?scriptId=' + CAST(s.Id AS nvarchar(20)) AS DestinationUrl
FROM dbo.Scripts s
INNER JOIN dbo.Genres g ON g.Id = s.GenreId
CROSS JOIN UserPreference pref
OUTER APPLY
(
    SELECT
        CAST(ISNULL(AVG(CAST(r.Rating AS decimal(10,2))), 0) AS decimal(10,2)) AS AverageRating,
        COUNT(1) AS ReviewCount
    FROM dbo.Reviews r
    WHERE r.ScriptId = s.Id
) reviewStat
OUTER APPLY
(
    SELECT
        COUNT(1) AS UpcomingSessionCount,
        MIN(se.SessionDateTime) AS NextSessionDateTime
    FROM dbo.Sessions se
    WHERE se.ScriptId = s.Id
      AND se.Status = N'开放预约'
      AND se.SessionDateTime >= GETDATE()
) sessionStat
OUTER APPLY
(
    SELECT COUNT(1) AS PlayedCount
    FROM dbo.Reservations rv
    INNER JOIN dbo.Sessions se ON se.Id = rv.SessionId
    WHERE rv.UserId = @UserId
      AND se.ScriptId = s.Id
      AND rv.Status IN (N'已完成', N'已到店')
) playedStat
WHERE s.AuditStatus = N'Approved'
  AND playedStat.PlayedCount = 0
ORDER BY
    (
        CASE WHEN pref.FavoriteGenre <> N'' AND g.Name = pref.FavoriteGenre THEN 35 ELSE 0 END +
        CASE WHEN pref.PreferredPlayerCount IS NOT NULL AND pref.PreferredPlayerCount BETWEEN s.PlayerMin AND s.PlayerMax THEN 25 ELSE 0 END +
        CASE WHEN sessionStat.UpcomingSessionCount > 0 THEN 20 ELSE 0 END +
        CASE WHEN reviewStat.AverageRating >= 4.5 THEN 12 WHEN reviewStat.AverageRating >= 4.0 THEN 8 WHEN reviewStat.AverageRating >= 3.5 THEN 4 ELSE 0 END +
        CASE WHEN s.IsFeatured = 1 THEN 6 ELSE 0 END +
        CASE WHEN reviewStat.ReviewCount >= 5 THEN 4 ELSE 0 END
    ) DESC,
    CASE WHEN sessionStat.NextSessionDateTime IS NULL THEN 1 ELSE 0 END,
    sessionStat.NextSessionDateTime ASC,
    reviewStat.AverageRating DESC,
    s.Id DESC;";

            return ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@Top", top);
            }, reader => new RecommendationInfo
            {
                Id = GetInt32(reader, "Id"),
                Title = GetString(reader, "Title"),
                Summary = LocalizeImportedPlaceholder(GetString(reader, "Summary")),
                CoverImage = GetString(reader, "CoverImage"),
                PlayerCount = GetInt32(reader, "PlayerCount"),
                MinPlayerCount = GetInt32(reader, "MinPlayerCount"),
                MaxPlayerCount = GetInt32(reader, "MaxPlayerCount"),
                Difficulty = LocalizeImportedPlaceholder(GetString(reader, "Difficulty")),
                Rating = GetDecimal(reader, "Rating"),
                HighlightTag = GetString(reader, "HighlightTag"),
                GenreName = GetString(reader, "GenreName"),
                UpcomingSessionCount = GetInt32(reader, "UpcomingSessionCount"),
                NextSessionDateTime = GetNullableDateTime(reader, "NextSessionDateTime"),
                RecommendationReason = GetString(reader, "RecommendationReason"),
                SecondaryReason = GetString(reader, "SecondaryReason"),
                DestinationUrl = GetString(reader, "DestinationUrl")
            });
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
    s.HostUserId,
    s.HostBriefing,
    s.HostAcceptedAt,
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
GROUP BY s.Id, s.ScriptId, s.RoomId, sc.Name, r.Name, s.SessionDateTime, s.HostName, s.HostUserId, s.HostBriefing, s.HostAcceptedAt, s.BasePrice, s.MaxPlayers, s.Status
HAVING s.Status = N'开放预约'
ORDER BY s.SessionDateTime ASC;";

            return ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@ScriptId", (object)scriptId ?? DBNull.Value);
            }, MapSession);
        }

        public IList<SessionInfo> GetUpcomingSessionsForWaitlist(int top, int? scriptId = null)
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
    s.HostUserId,
    s.HostBriefing,
    s.HostAcceptedAt,
    s.BasePrice,
    s.MaxPlayers,
    ISNULL(SUM(CASE WHEN rv.Status IN (N'待确认', N'已确认', N'申请改期', N'玩家已确认', N'已到店') THEN rv.PlayerCount ELSE 0 END), 0) AS ReservedPlayers,
    s.MaxPlayers - ISNULL(SUM(CASE WHEN rv.Status IN (N'待确认', N'已确认', N'申请改期', N'玩家已确认', N'已到店') THEN rv.PlayerCount ELSE 0 END), 0) AS RemainingSeats,
    s.Status
FROM dbo.Sessions s
INNER JOIN dbo.Scripts sc ON sc.Id = s.ScriptId
INNER JOIN dbo.Rooms r ON r.Id = s.RoomId
LEFT JOIN dbo.Reservations rv ON rv.SessionId = s.Id
WHERE s.SessionDateTime >= GETDATE()
  AND s.Status = N'开放预约'
  AND sc.AuditStatus = N'Approved'
  AND (@ScriptId IS NULL OR s.ScriptId = @ScriptId)
GROUP BY s.Id, s.ScriptId, s.RoomId, sc.Name, r.Name, s.SessionDateTime, s.HostName, s.HostUserId, s.HostBriefing, s.HostAcceptedAt, s.BasePrice, s.MaxPlayers, s.Status
ORDER BY
    CASE WHEN s.MaxPlayers - ISNULL(SUM(CASE WHEN rv.Status IN (N'待确认', N'已确认', N'申请改期', N'玩家已确认', N'已到店') THEN rv.PlayerCount ELSE 0 END), 0) <= 0 THEN 0 ELSE 1 END,
    s.SessionDateTime ASC;";

            return ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@ScriptId", (object)scriptId ?? DBNull.Value);
            }, MapSession);
        }

        public IList<DmSessionInfo> GetDmSessions(int top, int? hostUserId = null)
        {
            const string sql = @"
SELECT TOP (@Top)
    s.Id AS SessionId,
    s.ScriptId,
    sc.Name AS ScriptName,
    r.Name AS RoomName,
    s.HostName,
    s.HostUserId,
    s.HostBriefing,
    s.HostAcceptedAt,
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
    ISNULL(MIN(CASE WHEN rv.Status IN (N'待确认', N'已确认', N'玩家已确认', N'已到店') AND ISNULL(rvUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director') THEN rv.Id END), 0) AS HostReservationId,
    LEFT(
        ISNULL(
            NULLIF(
                STUFF(
                    (
                        SELECT N'；' + note.NoteText
                        FROM
                        (
                            SELECT DISTINCT NULLIF(LTRIM(RTRIM(ISNULL(rv2.Remark, N''))), N'') AS NoteText
                            FROM dbo.Reservations rv2
                            LEFT JOIN dbo.Users rv2User ON rv2User.Id = rv2.UserId
                            WHERE rv2.SessionId = s.Id
                              AND ISNULL(rv2User.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')

                            UNION

                            SELECT DISTINCT NULLIF(LTRIM(RTRIM(ISNULL(rv2.PlayerConfirmRemark, N''))), N'') AS NoteText
                            FROM dbo.Reservations rv2
                            LEFT JOIN dbo.Users rv2User ON rv2User.Id = rv2.UserId
                            WHERE rv2.SessionId = s.Id
                              AND ISNULL(rv2User.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')

                            UNION

                            SELECT DISTINCT NULLIF(LTRIM(RTRIM(ISNULL(sm.Content, N''))), N'') AS NoteText
                            FROM dbo.ServiceMessages sm
                            INNER JOIN dbo.Reservations rv2 ON rv2.Id = sm.BusinessId AND sm.BusinessType = N'Reservation'
                            LEFT JOIN dbo.Users rv2User ON rv2User.Id = rv2.UserId
                            WHERE rv2.SessionId = s.Id
                              AND sm.SenderRole = N'User'
                              AND ISNULL(rv2User.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')
                        ) note
                        WHERE note.NoteText IS NOT NULL
                        FOR XML PATH(''), TYPE
                    ).value('.', 'nvarchar(max)')
                , 1, 1, N'')
            , N'')
        , N'暂无玩家备注')
    , 240) AS PlayerNoteSummary
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
  AND (@HostUserId IS NULL OR s.HostUserId = @HostUserId)
  AND (
      s.SessionDateTime >= DATEADD(day, -1, GETDATE())
      OR st.GameEndedAt IS NULL
  )
GROUP BY
    s.Id, s.ScriptId, sc.Name, r.Name, s.HostName, s.HostUserId, s.HostBriefing, s.HostAcceptedAt, s.SessionDateTime, s.Status, s.MaxPlayers,
    gs.StageName, st.GameStartedAt, st.GameEndedAt, st.SettledAt
ORDER BY
    CASE WHEN st.GameEndedAt IS NULL THEN 0 ELSE 1 END,
    s.SessionDateTime ASC,
    s.Id ASC;";

            return ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@HostUserId", (object)hostUserId ?? DBNull.Value);
            }, reader => new DmSessionInfo
            {
                SessionId = GetInt32(reader, "SessionId"),
                ScriptId = GetInt32(reader, "ScriptId"),
                ScriptName = GetString(reader, "ScriptName"),
                RoomName = GetString(reader, "RoomName"),
                HostName = GetString(reader, "HostName"),
                HostUserId = GetNullableInt32(reader, "HostUserId"),
                HostBriefing = GetString(reader, "HostBriefing"),
                HostAcceptedAt = GetNullableDateTime(reader, "HostAcceptedAt"),
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
                HostReservationId = GetInt32(reader, "HostReservationId"),
                PlayerNoteSummary = GetString(reader, "PlayerNoteSummary")
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
    s.HostUserId,
    s.HostBriefing,
    s.HostAcceptedAt,
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
GROUP BY s.Id, s.ScriptId, s.RoomId, sc.Name, r.Name, s.SessionDateTime, s.HostName, s.HostUserId, s.HostBriefing, s.HostAcceptedAt, s.BasePrice, s.MaxPlayers, s.Status;";

            var sessions = ExecuteList(sql, command => command.Parameters.AddWithValue("@SessionId", sessionId), MapSession);
            return sessions.Count > 0 ? sessions[0] : null;
        }

        public bool CreateAdminSession(int scriptId, int roomId, DateTime sessionDateTime, string hostName, int? hostUserId, string hostBriefing, decimal basePrice, int maxPlayers, out string message)
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
    HostUserId,
    HostBriefing,
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
    @HostUserId,
    @HostBriefing,
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
                command.Parameters.AddWithValue("@HostUserId", (object)hostUserId ?? DBNull.Value);
                command.Parameters.AddWithValue("@HostBriefing", string.IsNullOrWhiteSpace(hostBriefing) ? (object)DBNull.Value : hostBriefing.Trim());
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
    r.HighlightTag,
    r.UserId,
    r.ReservationId,
    rm.Name AS RoomName,
    se.SessionDateTime,
    ISNULL(rv.TotalAmount, rv.UnitPrice * rv.PlayerCount) AS ReservationAmount,
    rv.Status AS ReservationStatus,
    ISNULL(r.IsFeatured, 0) AS IsFeatured,
    ISNULL(r.IsHidden, 0) AS IsHidden,
    r.AdminReply
FROM dbo.Reviews r
INNER JOIN dbo.Scripts s ON s.Id = r.ScriptId
LEFT JOIN dbo.Reservations rv ON rv.Id = r.ReservationId
LEFT JOIN dbo.Sessions se ON se.Id = rv.SessionId
LEFT JOIN dbo.Rooms rm ON rm.Id = se.RoomId
WHERE s.AuditStatus = N'Approved'
  AND ISNULL(r.IsHidden, 0) = 0
  AND (@ScriptId IS NULL OR r.ScriptId = @ScriptId)
ORDER BY ISNULL(r.IsFeatured, 0) DESC, r.ReviewDate DESC, r.Id DESC;";

            return ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@ScriptId", (object)scriptId ?? DBNull.Value);
            }, MapReview);
        }

        public bool AcceptDmAssignment(int sessionId, int hostUserId, out string message)
        {
            const string sql = @"
UPDATE dbo.Sessions
SET HostAcceptedAt = GETDATE()
WHERE Id = @SessionId
  AND HostUserId = @HostUserId;

IF @@ROWCOUNT = 0
BEGIN
    RAISERROR(N'未找到分配给你的主持场次。', 16, 1);
    RETURN;
END

INSERT INTO dbo.BusinessActionLogs(BusinessType, BusinessId, ActionType, ActionTitle, ActionContent, OperatorUserId, CreatedAt)
VALUES(N'Session', @SessionId, N'DM接单', N'DM 已接收主持任务', NULL, @HostUserId, GETDATE());";

            return ExecuteNonQuery(sql, command =>
            {
                command.Parameters.AddWithValue("@SessionId", sessionId);
                command.Parameters.AddWithValue("@HostUserId", hostUserId);
            }, "已接收主持任务。", out message);
        }

        public IList<ReservationInfo> GetReviewableReservations(int userId, int top)
        {
            const string sql = @"
SELECT TOP (@Top)
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
    r.CouponId,
    ISNULL(r.DiscountAmount, 0) AS DiscountAmount,
    ISNULL(c.Title, N'') AS CouponTitle,
    ISNULL(NULLIF(r.PaymentStatus, N''), N'线下确认') AS PaymentStatus,
    ISNULL(r.CheckInCode, N'') AS CheckInCode,
    r.CheckedInAt,
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
LEFT JOIN dbo.UserCoupons c ON c.Id = r.CouponId
WHERE r.UserId = @UserId
  AND r.Status NOT IN (N'已取消')
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.Reviews rv
      WHERE rv.ReservationId = r.Id
        AND rv.UserId = @UserId
  )
ORDER BY se.SessionDateTime DESC, r.CreatedAt DESC, r.Id DESC;";

            return ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@UserId", userId);
            }, MapAdminReservationInfo);
        }

        public bool CreateReservationReview(int reservationId, int userId, int rating, string content, string highlightTag, out string message)
        {
            const string sql = @"
IF @Rating < 1 OR @Rating > 5
BEGIN
    RAISERROR(N'评分必须在 1 到 5 之间。', 16, 1);
    RETURN;
END

IF NULLIF(@Content, N'') IS NULL
BEGIN
    RAISERROR(N'请填写真实体验内容。', 16, 1);
    RETURN;
END

DECLARE @ScriptId INT;
DECLARE @ReviewerName NVARCHAR(50);

SELECT
    @ScriptId = se.ScriptId,
    @ReviewerName = u.DisplayName
FROM dbo.Reservations r
INNER JOIN dbo.Sessions se ON se.Id = r.SessionId
INNER JOIN dbo.Users u ON u.Id = r.UserId
WHERE r.Id = @ReservationId
  AND r.UserId = @UserId
  AND r.Status NOT IN (N'已取消');

IF @ScriptId IS NULL
BEGIN
    RAISERROR(N'未找到可评价的预约订单。', 16, 1);
    RETURN;
END

IF EXISTS (SELECT 1 FROM dbo.Reviews WHERE ReservationId = @ReservationId AND UserId = @UserId)
BEGIN
    RAISERROR(N'这笔预约已经提交过评价。', 16, 1);
    RETURN;
END

INSERT INTO dbo.Reviews
(
    ScriptId,
    ReviewerName,
    Rating,
    Content,
    ReviewDate,
    HighlightTag,
    UserId,
    ReservationId
)
VALUES
(
    @ScriptId,
    @ReviewerName,
    @Rating,
    @Content,
    GETDATE(),
    CASE WHEN NULLIF(@HighlightTag, N'') IS NULL THEN N'真实体验' ELSE @HighlightTag END,
    @UserId,
    @ReservationId
);

INSERT INTO dbo.BusinessActionLogs(BusinessType, BusinessId, ActionType, ActionTitle, ActionContent, OperatorUserId, CreatedAt)
VALUES(N'Review', SCOPE_IDENTITY(), N'提交评价', N'用户提交消费后评价', @Content, @UserId, GETDATE());";

            return ExecuteNonQuery(sql, command =>
            {
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@Rating", rating);
                command.Parameters.AddWithValue("@Content", (content ?? string.Empty).Trim());
                command.Parameters.AddWithValue("@HighlightTag", (object)(highlightTag ?? string.Empty).Trim());
            }, "评价已提交，已同步到剧本评分与点评列表。", out message);
        }

        public IList<ReviewInfo> GetReviewsForAdmin(int top)
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
    r.HighlightTag,
    r.UserId,
    r.ReservationId,
    rm.Name AS RoomName,
    se.SessionDateTime,
    ISNULL(rv.TotalAmount, rv.UnitPrice * rv.PlayerCount) AS ReservationAmount,
    rv.Status AS ReservationStatus,
    ISNULL(r.IsFeatured, 0) AS IsFeatured,
    ISNULL(r.IsHidden, 0) AS IsHidden,
    r.AdminReply
FROM dbo.Reviews r
INNER JOIN dbo.Scripts s ON s.Id = r.ScriptId
LEFT JOIN dbo.Reservations rv ON rv.Id = r.ReservationId
LEFT JOIN dbo.Sessions se ON se.Id = rv.SessionId
LEFT JOIN dbo.Rooms rm ON rm.Id = se.RoomId
ORDER BY
    CASE WHEN r.Rating <= 2 AND ISNULL(r.AdminReply, N'') = N'' THEN 0 ELSE 1 END,
    r.ReviewDate DESC,
    r.Id DESC;";

            return ExecuteList(sql, command => command.Parameters.AddWithValue("@Top", top), MapReview);
        }

        public ReviewInfo GetReservationReview(int reservationId, int? userId = null)
        {
            const string sql = @"
SELECT TOP 1
    r.Id,
    r.ScriptId,
    s.Name AS ScriptName,
    r.ReviewerName,
    r.Rating,
    r.Content,
    r.ReviewDate,
    r.HighlightTag,
    r.UserId,
    r.ReservationId,
    rm.Name AS RoomName,
    se.SessionDateTime,
    ISNULL(rv.TotalAmount, rv.UnitPrice * rv.PlayerCount) AS ReservationAmount,
    rv.Status AS ReservationStatus,
    ISNULL(r.IsFeatured, 0) AS IsFeatured,
    ISNULL(r.IsHidden, 0) AS IsHidden,
    r.AdminReply
FROM dbo.Reviews r
INNER JOIN dbo.Scripts s ON s.Id = r.ScriptId
INNER JOIN dbo.Reservations rv ON rv.Id = r.ReservationId
INNER JOIN dbo.Sessions se ON se.Id = rv.SessionId
INNER JOIN dbo.Rooms rm ON rm.Id = se.RoomId
WHERE r.ReservationId = @ReservationId
  AND (@UserId IS NULL OR r.UserId = @UserId)
ORDER BY r.ReviewDate DESC, r.Id DESC;";

            var reviews = ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@UserId", (object)userId ?? DBNull.Value);
            }, MapReview);

            return reviews.Count > 0 ? reviews[0] : null;
        }

        public bool ModerateReview(int reviewId, bool isFeatured, bool isHidden, string adminReply, int adminUserId, out string message)
        {
            const string sql = @"
UPDATE dbo.Reviews
SET IsFeatured = @IsFeatured,
    IsHidden = @IsHidden,
    AdminReply = NULLIF(@AdminReply, N'')
WHERE Id = @ReviewId;

IF @@ROWCOUNT = 0
BEGIN
    RAISERROR(N'未找到对应评价。', 16, 1);
    RETURN;
END

INSERT INTO dbo.BusinessActionLogs(BusinessType, BusinessId, ActionType, ActionTitle, ActionContent, OperatorUserId, CreatedAt)
VALUES(N'Review', @ReviewId, N'评价管理', N'管理员处理玩家评价', @AdminReply, @AdminUserId, GETDATE());";

            return ExecuteNonQuery(sql, command =>
            {
                command.Parameters.AddWithValue("@ReviewId", reviewId);
                command.Parameters.AddWithValue("@IsFeatured", isFeatured);
                command.Parameters.AddWithValue("@IsHidden", isHidden);
                command.Parameters.AddWithValue("@AdminReply", (object)(adminReply ?? string.Empty).Trim());
                command.Parameters.AddWithValue("@AdminUserId", adminUserId);
            }, "评价管理设置已保存。", out message);
        }

        public IList<CouponInfo> GetAvailableCoupons(int userId, decimal orderAmount)
        {
            const string sql = @"
SELECT
    c.Id,
    c.UserId,
    u.DisplayName AS UserDisplayName,
    u.Username,
    c.Title,
    c.CouponType,
    c.DiscountAmount,
    c.MinSpend,
    c.Status,
    c.Source,
    c.IssuedAt,
    c.ValidFrom,
    c.ValidUntil,
    c.UsedReservationId,
    c.UsedAt
FROM dbo.UserCoupons c
INNER JOIN dbo.Users u ON u.Id = c.UserId
WHERE c.UserId = @UserId
  AND c.Status = N'未使用'
  AND c.ValidFrom <= GETDATE()
  AND c.ValidUntil >= GETDATE()
  AND c.MinSpend <= @OrderAmount
ORDER BY c.ValidUntil ASC, c.DiscountAmount DESC, c.Id DESC;";

            return ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@OrderAmount", orderAmount < 0 ? 0 : orderAmount);
            }, MapCoupon);
        }

        public IList<CouponInfo> GetRecentCouponsForAdmin(int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    c.Id,
    c.UserId,
    u.DisplayName AS UserDisplayName,
    u.Username,
    c.Title,
    c.CouponType,
    c.DiscountAmount,
    c.MinSpend,
    c.Status,
    c.Source,
    c.IssuedAt,
    c.ValidFrom,
    c.ValidUntil,
    c.UsedReservationId,
    c.UsedAt
FROM dbo.UserCoupons c
INNER JOIN dbo.Users u ON u.Id = c.UserId
ORDER BY c.IssuedAt DESC, c.Id DESC;";

            return ExecuteList(sql, command => command.Parameters.AddWithValue("@Top", top), MapCoupon);
        }

        public bool IssueCoupon(int userId, string title, decimal discountAmount, decimal minSpend, int validDays, string source, int adminUserId, out string message)
        {
            const string sql = @"
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Id = @UserId AND ReviewStatus = N'Approved')
BEGIN
    RAISERROR(N'发券用户不存在或尚未通过审核。', 16, 1);
    RETURN;
END

IF @DiscountAmount <= 0
BEGIN
    RAISERROR(N'优惠金额必须大于 0。', 16, 1);
    RETURN;
END

IF @ValidDays <= 0
BEGIN
    SET @ValidDays = 30;
END

INSERT INTO dbo.UserCoupons
(
    UserId,
    Title,
    CouponType,
    DiscountAmount,
    MinSpend,
    Status,
    Source,
    IssuedByUserId,
    IssuedAt,
    ValidFrom,
    ValidUntil
)
VALUES
(
    @UserId,
    @Title,
    N'Amount',
    @DiscountAmount,
    CASE WHEN @MinSpend < 0 THEN 0 ELSE @MinSpend END,
    N'未使用',
    NULLIF(@Source, N''),
    @AdminUserId,
    GETDATE(),
    GETDATE(),
    DATEADD(day, @ValidDays, GETDATE())
);

INSERT INTO dbo.BusinessActionLogs(BusinessType, BusinessId, ActionType, ActionTitle, ActionContent, OperatorUserId, CreatedAt)
VALUES(N'Coupon', SCOPE_IDENTITY(), N'发放优惠券', N'管理员发放复购优惠券', @Title, @AdminUserId, GETDATE());";

            return ExecuteNonQuery(sql, command =>
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@Title", string.IsNullOrWhiteSpace(title) ? "复购优惠券" : title.Trim());
                command.Parameters.AddWithValue("@DiscountAmount", discountAmount);
                command.Parameters.AddWithValue("@MinSpend", minSpend);
                command.Parameters.AddWithValue("@ValidDays", validDays);
                command.Parameters.AddWithValue("@Source", (object)(source ?? string.Empty).Trim());
                command.Parameters.AddWithValue("@AdminUserId", adminUserId);
            }, "优惠券已发放，用户预约时可以直接抵扣。", out message);
        }

        public bool CreateReservation(BookingCreateRequest request, out int reservationId, out string message)
        {
            const string sql = @"
DECLARE @RemainingSeats INT;
DECLARE @UnitPrice DECIMAL(10,2);
DECLARE @OriginalAmount DECIMAL(10,2);
DECLARE @DiscountAmount DECIMAL(10,2);
DECLARE @TotalAmount DECIMAL(10,2);
DECLARE @BalanceAfter DECIMAL(10,2);
DECLARE @WalletTransactionId INT;
DECLARE @ReservationId INT;
DECLARE @CouponMatches INT;

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

SET @OriginalAmount = @UnitPrice * @PlayerCount;
SET @DiscountAmount = 0;
SET @CouponMatches = 0;

IF @CouponId IS NOT NULL
BEGIN
    SELECT
        @CouponMatches = COUNT(1),
        @DiscountAmount = MAX(CASE WHEN DiscountAmount > @OriginalAmount THEN @OriginalAmount ELSE DiscountAmount END)
    FROM dbo.UserCoupons WITH (UPDLOCK, HOLDLOCK)
    WHERE Id = @CouponId
      AND UserId = @UserId
      AND Status = N'未使用'
      AND ValidFrom <= GETDATE()
      AND ValidUntil >= GETDATE()
      AND MinSpend <= @OriginalAmount;

    IF @CouponMatches = 0
    BEGIN
        RAISERROR(N'所选优惠券不可用，可能已使用、已过期或未达到满减门槛。', 16, 1);
        RETURN;
    END
END

SET @TotalAmount = @OriginalAmount - ISNULL(@DiscountAmount, 0);
IF @TotalAmount < 0
BEGIN
    SET @TotalAmount = 0;
END

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
    CouponId,
    DiscountAmount,
    PaymentStatus,
    PaymentTransactionId,
    CheckInCode,
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
    @CouponId,
    ISNULL(@DiscountAmount, 0),
    N'已支付',
    @WalletTransactionId,
    RIGHT(N'000000' + CONVERT(NVARCHAR(20), ABS(CHECKSUM(NEWID())) % 1000000), 6),
    @Remark,
    GETDATE(),
    N'待确认'
);

SET @ReservationId = SCOPE_IDENTITY();

UPDATE dbo.ReservationWaitlists
SET Status = N'Booked'
WHERE SessionId = @SessionId
  AND UserId = @UserId
  AND Status = N'Pending';

IF @CouponId IS NOT NULL
BEGIN
    UPDATE dbo.UserCoupons
    SET Status = N'已使用',
        UsedReservationId = @ReservationId,
        UsedAt = GETDATE()
    WHERE Id = @CouponId
      AND UserId = @UserId;
END

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
                command.Parameters.AddWithValue("@CouponId", (object)request.CouponId ?? DBNull.Value);

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
    r.CouponId,
    ISNULL(r.DiscountAmount, 0) AS DiscountAmount,
    ISNULL(c.Title, N'') AS CouponTitle,
    ISNULL(NULLIF(r.PaymentStatus, N''), N'线下确认') AS PaymentStatus,
    ISNULL(r.CheckInCode, N'') AS CheckInCode,
    r.CheckedInAt,
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
LEFT JOIN dbo.UserCoupons c ON c.Id = r.CouponId
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
                CouponId = GetNullableInt32(reader, "CouponId"),
                DiscountAmount = GetDecimal(reader, "DiscountAmount"),
                CouponTitle = GetString(reader, "CouponTitle"),
                PaymentStatus = GetString(reader, "PaymentStatus"),
                CheckInCode = GetString(reader, "CheckInCode"),
                CheckedInAt = GetNullableDateTime(reader, "CheckedInAt"),
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
    r.CouponId,
    ISNULL(r.DiscountAmount, 0) AS DiscountAmount,
    ISNULL(c.Title, N'') AS CouponTitle,
    ISNULL(NULLIF(r.PaymentStatus, N''), N'线下确认') AS PaymentStatus,
    ISNULL(r.CheckInCode, N'') AS CheckInCode,
    r.CheckedInAt,
    r.Remark,
    r.AdminRemark,
    r.ConfirmStatus,
    r.PlayerConfirmRemark,
    r.CreatedAt,
    se.SessionDateTime,
    r.Status,
    r.AdminReply,
    r.ProcessedAt,
    r.PlayerConfirmedAt,
    r.RepliedAt,
    CASE WHEN EXISTS (SELECT 1 FROM dbo.Reviews rv WHERE rv.ReservationId = r.Id) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS HasReview
FROM dbo.Reservations r
INNER JOIN dbo.Sessions se ON se.Id = r.SessionId
INNER JOIN dbo.Scripts s ON s.Id = se.ScriptId
INNER JOIN dbo.Rooms rm ON rm.Id = se.RoomId
LEFT JOIN dbo.UserCoupons c ON c.Id = r.CouponId
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
                CouponId = GetNullableInt32(reader, "CouponId"),
                DiscountAmount = GetDecimal(reader, "DiscountAmount"),
                CouponTitle = GetString(reader, "CouponTitle"),
                PaymentStatus = GetString(reader, "PaymentStatus"),
                CheckInCode = GetString(reader, "CheckInCode"),
                CheckedInAt = GetNullableDateTime(reader, "CheckedInAt"),
                Remark = GetString(reader, "Remark"),
                AdminRemark = GetString(reader, "AdminRemark"),
                ConfirmStatus = GetString(reader, "ConfirmStatus"),
                PlayerConfirmRemark = GetString(reader, "PlayerConfirmRemark"),
                CreatedAt = GetDateTime(reader, "CreatedAt"),
                SessionDateTime = GetDateTime(reader, "SessionDateTime"),
                Status = GetString(reader, "Status"),
                AdminReply = GetString(reader, "AdminReply"),
                ProcessedAt = GetNullableDateTime(reader, "ProcessedAt"),
                PlayerConfirmedAt = GetNullableDateTime(reader, "PlayerConfirmedAt"),
                RepliedAt = GetNullableDateTime(reader, "RepliedAt"),
                HasReview = GetBoolean(reader, "HasReview")
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
    r.CouponId,
    ISNULL(r.DiscountAmount, 0) AS DiscountAmount,
    ISNULL(c.Title, N'') AS CouponTitle,
    ISNULL(NULLIF(r.PaymentStatus, N''), N'线下确认') AS PaymentStatus,
    ISNULL(r.CheckInCode, N'') AS CheckInCode,
    r.CheckedInAt,
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
LEFT JOIN dbo.UserCoupons c ON c.Id = r.CouponId
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

        public IList<ReservationInfo> GetReservationsForUser(int userId, int top)
        {
            const string sql = @"
SELECT TOP (@Top)
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
    r.CouponId,
    ISNULL(r.DiscountAmount, 0) AS DiscountAmount,
    ISNULL(c.Title, N'') AS CouponTitle,
    ISNULL(NULLIF(r.PaymentStatus, N''), N'线下确认') AS PaymentStatus,
    ISNULL(r.CheckInCode, N'') AS CheckInCode,
    r.CheckedInAt,
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
    r.PlayerConfirmedAt,
    latestAfterSale.Id AS LatestAfterSaleId,
    latestAfterSale.RequestType AS LatestAfterSaleType,
    latestAfterSale.Status AS LatestAfterSaleStatus,
    latestAfterSale.CreatedAt AS LatestAfterSaleCreatedAt
FROM dbo.Reservations r
INNER JOIN dbo.Sessions se ON se.Id = r.SessionId
INNER JOIN dbo.Scripts s ON s.Id = se.ScriptId
INNER JOIN dbo.Rooms rm ON rm.Id = se.RoomId
LEFT JOIN dbo.UserCoupons c ON c.Id = r.CouponId
OUTER APPLY
(
    SELECT TOP 1 Id, RequestType, Status, CreatedAt
    FROM dbo.AfterSaleRequests a
    WHERE a.ReservationId = r.Id
    ORDER BY a.CreatedAt DESC, a.Id DESC
) latestAfterSale
WHERE r.UserId = @UserId
ORDER BY r.CreatedAt DESC, r.Id DESC;";

            return ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@UserId", userId);
            }, MapUserReservationInfo);
        }

        public bool JoinReservationWaitlist(int userId, int sessionId, string contactName, string phone, int playerCount, string note, out string message)
        {
            const string sql = @"
DECLARE @RemainingSeats INT;
DECLARE @SessionExists INT;

SELECT
    @SessionExists = COUNT(1),
    @RemainingSeats = s.MaxPlayers - ISNULL(SUM(CASE WHEN r.Status IN (N'待确认', N'已确认', N'申请改期', N'玩家已确认', N'已到店') THEN r.PlayerCount ELSE 0 END), 0)
FROM dbo.Sessions s WITH (UPDLOCK, HOLDLOCK)
INNER JOIN dbo.Scripts sc ON sc.Id = s.ScriptId
LEFT JOIN dbo.Reservations r ON r.SessionId = s.Id
WHERE s.Id = @SessionId
  AND s.Status = N'开放预约'
  AND s.SessionDateTime >= GETDATE()
  AND sc.AuditStatus = N'Approved'
GROUP BY s.MaxPlayers;

IF ISNULL(@SessionExists, 0) = 0
BEGIN
    RAISERROR(N'当前场次不存在或已停止预约。', 16, 1);
    RETURN;
END

IF @RemainingSeats >= @PlayerCount
BEGIN
    RAISERROR(N'当前场次仍可直接预约，无需加入候补。', 16, 1);
    RETURN;
END

IF EXISTS
(
    SELECT 1
    FROM dbo.ReservationWaitlists
    WHERE SessionId = @SessionId
      AND UserId = @UserId
      AND Status = N'Pending'
)
BEGIN
    RAISERROR(N'你已经在这个场次的候补队列里，无需重复提交。', 16, 1);
    RETURN;
END

INSERT INTO dbo.ReservationWaitlists(SessionId, UserId, ContactName, Phone, PlayerCount, Note, Status, CreatedAt)
VALUES(@SessionId, @UserId, @ContactName, @Phone, @PlayerCount, NULLIF(@Note, N''), N'Pending', GETDATE());";

            return ExecuteNonQuery(sql, command =>
            {
                command.Parameters.AddWithValue("@SessionId", sessionId);
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@ContactName", (contactName ?? string.Empty).Trim());
                command.Parameters.AddWithValue("@Phone", (phone ?? string.Empty).Trim());
                command.Parameters.AddWithValue("@PlayerCount", playerCount);
                command.Parameters.AddWithValue("@Note", (note ?? string.Empty).Trim());
            }, "已加入候补队列，场次腾出名额后会在通知中心提醒你。", out message);
        }

        public IList<ReservationWaitlistInfo> GetReservationWaitlistsForUser(int userId, int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    w.Id,
    w.SessionId,
    w.UserId,
    w.ContactName,
    w.Phone,
    w.PlayerCount,
    w.Note,
    w.Status,
    w.CreatedAt,
    s.Name AS ScriptName,
    rm.Name AS RoomName,
    se.HostName,
    se.SessionDateTime,
    se.MaxPlayers - ISNULL(activeReservation.ReservedPlayers, 0) AS RemainingSeats
FROM dbo.ReservationWaitlists w
INNER JOIN dbo.Sessions se ON se.Id = w.SessionId
INNER JOIN dbo.Scripts s ON s.Id = se.ScriptId
INNER JOIN dbo.Rooms rm ON rm.Id = se.RoomId
OUTER APPLY
(
    SELECT ISNULL(SUM(r.PlayerCount), 0) AS ReservedPlayers
    FROM dbo.Reservations r
    WHERE r.SessionId = se.Id
      AND r.Status IN (N'待确认', N'已确认', N'申请改期', N'玩家已确认', N'已到店')
) activeReservation
WHERE w.UserId = @UserId
ORDER BY
    CASE WHEN w.Status = N'Pending' THEN 0 ELSE 1 END,
    w.CreatedAt DESC,
    w.Id DESC;";

            return ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@UserId", userId);
            }, MapReservationWaitlistInfo);
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

        public bool CreateAfterSaleRequest(int reservationId, int userId, string requestType, string reason, decimal requestedAmount, string evidenceUrl, out string message)
        {
            const string sql = @"
IF NULLIF(@Reason, N'') IS NULL
BEGIN
    RAISERROR(N'请填写售后原因，方便门店处理。', 16, 1);
    RETURN;
END

DECLARE @ReservationAmount DECIMAL(10,2);

SELECT @ReservationAmount = ISNULL(TotalAmount, UnitPrice * PlayerCount)
FROM dbo.Reservations
WHERE Id = @ReservationId
  AND UserId = @UserId;

IF @ReservationAmount IS NULL
BEGIN
    RAISERROR(N'未找到可申请售后的预约订单。', 16, 1);
    RETURN;
END

IF EXISTS
(
    SELECT 1
    FROM dbo.AfterSaleRequests
    WHERE ReservationId = @ReservationId
      AND Status IN (N'待处理', N'已受理', N'待复审')
)
BEGIN
    RAISERROR(N'该订单已有正在处理中的售后申请，请等待管理员回复。', 16, 1);
    RETURN;
END

IF @RequestedAmount < 0
BEGIN
    SET @RequestedAmount = 0;
END

IF @RequestedAmount > @ReservationAmount
BEGIN
    SET @RequestedAmount = @ReservationAmount;
END

INSERT INTO dbo.AfterSaleRequests
(
    ReservationId,
    UserId,
    RequestType,
    Reason,
    RequestedAmount,
    EvidenceUrl,
    Status,
    CreatedAt
)
VALUES
(
    @ReservationId,
    @UserId,
    @RequestType,
    @Reason,
    NULLIF(@RequestedAmount, 0),
    NULLIF(@EvidenceUrl, N''),
    N'待处理',
    GETDATE()
);

INSERT INTO dbo.BusinessActionLogs(BusinessType, BusinessId, ActionType, ActionTitle, ActionContent, OperatorUserId, CreatedAt)
VALUES(N'AfterSale', SCOPE_IDENTITY(), N'提交售后', N'用户提交售后申请', @Reason, @UserId, GETDATE());";

            return ExecuteNonQuery(sql, command =>
            {
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@RequestType", NormalizeAfterSaleType(requestType));
                command.Parameters.AddWithValue("@Reason", (reason ?? string.Empty).Trim());
                command.Parameters.AddWithValue("@RequestedAmount", requestedAmount);
                command.Parameters.AddWithValue("@EvidenceUrl", (evidenceUrl ?? string.Empty).Trim());
            }, "售后申请已提交，等待管理员处理。", out message);
        }

        public IList<AfterSaleRequestInfo> GetAfterSaleRequests(int top, string statusFilter = null, int? userId = null)
        {
            const string sql = @"
SELECT TOP (@Top)
    a.Id,
    a.ReservationId,
    a.UserId,
    a.RequestType,
    a.Reason,
    ISNULL(a.RequestedAmount, 0) AS RequestedAmount,
    a.Status,
    a.AdminReply,
    a.AdminRemark,
    a.EvidenceUrl,
    a.RejectReason,
    a.AppealReason,
    a.RefundTransactionId,
    ISNULL(a.RefundedAmount, 0) AS RefundedAmount,
    a.CreatedAt,
    a.AcceptedAt,
    a.RejectedAt,
    a.AppealedAt,
    a.ProcessedAt,
    r.ContactName,
    r.Phone,
    ISNULL(r.TotalAmount, r.UnitPrice * r.PlayerCount) AS ReservationAmount,
    s.Name AS ScriptName,
    rm.Name AS RoomName,
    se.HostName,
    se.SessionDateTime
FROM dbo.AfterSaleRequests a
INNER JOIN dbo.Reservations r ON r.Id = a.ReservationId
INNER JOIN dbo.Sessions se ON se.Id = r.SessionId
INNER JOIN dbo.Scripts s ON s.Id = se.ScriptId
INNER JOIN dbo.Rooms rm ON rm.Id = se.RoomId
WHERE (@StatusFilter IS NULL OR a.Status = @StatusFilter)
  AND (@UserId IS NULL OR a.UserId = @UserId)
ORDER BY
    CASE WHEN a.Status IN (N'待处理', N'已受理', N'待复审') THEN 0 ELSE 1 END,
    a.CreatedAt DESC,
    a.Id DESC;";

            return ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@StatusFilter", string.IsNullOrWhiteSpace(statusFilter) ? (object)DBNull.Value : statusFilter);
                command.Parameters.AddWithValue("@UserId", (object)userId ?? DBNull.Value);
            }, MapAfterSaleRequest);
        }

        public bool SubmitAfterSaleAppeal(int requestId, int userId, string appealReason, string evidenceUrl, out string message)
        {
            const string sql = @"
IF NULLIF(@AppealReason, N'') IS NULL
BEGIN
    RAISERROR(N'请填写申诉原因后再提交复审。', 16, 1);
    RETURN;
END

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.AfterSaleRequests
    WHERE Id = @RequestId
      AND UserId = @UserId
      AND Status = N'已驳回'
)
BEGIN
    RAISERROR(N'当前售后单不支持再次申诉。', 16, 1);
    RETURN;
END

UPDATE dbo.AfterSaleRequests
SET
    Status = N'待复审',
    AppealReason = @AppealReason,
    AppealedAt = GETDATE(),
    EvidenceUrl = CASE WHEN NULLIF(@EvidenceUrl, N'') IS NULL THEN EvidenceUrl ELSE @EvidenceUrl END,
    AdminReply = NULL,
    ProcessedAt = NULL,
    ProcessedByUserId = NULL
WHERE Id = @RequestId;

INSERT INTO dbo.BusinessActionLogs(BusinessType, BusinessId, ActionType, ActionTitle, ActionContent, OperatorUserId, CreatedAt)
VALUES(N'AfterSale', @RequestId, N'提交申诉', N'用户发起二次申诉', @AppealReason, @UserId, GETDATE());";

            return ExecuteNonQuery(sql, command =>
            {
                command.Parameters.AddWithValue("@RequestId", requestId);
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@AppealReason", (appealReason ?? string.Empty).Trim());
                command.Parameters.AddWithValue("@EvidenceUrl", (evidenceUrl ?? string.Empty).Trim());
            }, "申诉已提交，售后单已进入复审。", out message);
        }

        public bool ReviewAfterSaleRequest(int requestId, string status, string adminReply, string adminRemark, string rejectReason, int adminUserId, out string message)
        {
            const string sql = @"
DECLARE @ReservationId INT;
DECLARE @UserId INT;
DECLARE @ReservationAmount DECIMAL(10,2);
DECLARE @RequestedAmount DECIMAL(10,2);
DECLARE @RefundAmount DECIMAL(10,2);
DECLARE @ExistingRefundTransactionId INT;
DECLARE @BalanceAfter DECIMAL(10,2);
DECLARE @WalletTransactionId INT;
DECLARE @CurrentStatus NVARCHAR(30);

SELECT
    @ReservationId = a.ReservationId,
    @UserId = a.UserId,
    @CurrentStatus = a.Status,
    @RequestedAmount = ISNULL(a.RequestedAmount, 0),
    @ExistingRefundTransactionId = a.RefundTransactionId,
    @ReservationAmount = ISNULL(r.TotalAmount, r.UnitPrice * r.PlayerCount)
FROM dbo.AfterSaleRequests a
INNER JOIN dbo.Reservations r ON r.Id = a.ReservationId
WHERE a.Id = @RequestId;

IF @ReservationId IS NULL
BEGIN
    RAISERROR(N'未找到对应的售后申请。', 16, 1);
    RETURN;
END

IF @Status = N'已驳回' AND NULLIF(@RejectReason, N'') IS NULL
BEGIN
    RAISERROR(N'驳回售后时请填写具体驳回原因。', 16, 1);
    RETURN;
END

IF @Status = N'退款完成' AND @ExistingRefundTransactionId IS NULL
BEGIN
    SET @RefundAmount = CASE WHEN @RequestedAmount > 0 THEN @RequestedAmount ELSE @ReservationAmount END;
    IF @RefundAmount > @ReservationAmount
    BEGIN
        SET @RefundAmount = @ReservationAmount;
    END

    IF @RefundAmount <= 0
    BEGIN
        RAISERROR(N'退款金额必须大于 0。', 16, 1);
        RETURN;
    END

    UPDATE dbo.Users
    SET Balance = Balance + @RefundAmount
    WHERE Id = @UserId;

    SELECT @BalanceAfter = Balance
    FROM dbo.Users
    WHERE Id = @UserId;

    INSERT INTO dbo.WalletTransactions(UserId, TransactionType, Amount, BalanceAfter, Summary, CreatedAt)
    VALUES(@UserId, N'预约退款', @RefundAmount, @BalanceAfter, N'预约售后退款', GETDATE());

    SET @WalletTransactionId = SCOPE_IDENTITY();
END

UPDATE dbo.AfterSaleRequests
SET Status = @Status,
    AdminReply = NULLIF(@AdminReply, N''),
    AdminRemark = NULLIF(@AdminRemark, N''),
    RejectReason = CASE WHEN @Status = N'已驳回' THEN NULLIF(@RejectReason, N'') ELSE RejectReason END,
    AcceptedAt = CASE
        WHEN @Status IN (N'已受理', N'退款完成') AND AcceptedAt IS NULL THEN GETDATE()
        ELSE AcceptedAt
    END,
    RejectedAt = CASE WHEN @Status = N'已驳回' THEN GETDATE() ELSE RejectedAt END,
    ProcessedByUserId = @AdminUserId,
    ProcessedAt = CASE
        WHEN @Status IN (N'已驳回', N'退款完成', N'已关闭') THEN GETDATE()
        WHEN @Status IN (N'已受理', N'待复审') THEN ProcessedAt
        ELSE GETDATE()
    END,
    RefundTransactionId = CASE WHEN @WalletTransactionId IS NULL THEN RefundTransactionId ELSE @WalletTransactionId END,
    RefundedAmount = CASE WHEN @WalletTransactionId IS NULL THEN RefundedAmount ELSE @RefundAmount END
WHERE Id = @RequestId;

IF @Status = N'退款完成'
BEGIN
    UPDATE dbo.Reservations
    SET Status = CASE WHEN Status = N'已取消' THEN Status ELSE N'已取消' END,
        PaymentStatus = N'已退款',
        ProcessedAt = GETDATE(),
        ProcessedByUserId = @AdminUserId
    WHERE Id = @ReservationId;
END

IF NULLIF(@AdminReply, N'') IS NOT NULL
BEGIN
    INSERT INTO dbo.AdminReplyLogs(BusinessType, BusinessId, AdminUserId, ReplyContent, VisibleToUser, CreatedAt)
    VALUES(N'AfterSale', @RequestId, @AdminUserId, @AdminReply, 1, GETDATE());
END

INSERT INTO dbo.BusinessActionLogs(BusinessType, BusinessId, ActionType, ActionTitle, ActionContent, OperatorUserId, CreatedAt)
VALUES(N'AfterSale', @RequestId, @Status, N'管理员处理售后申请', @AdminRemark, @AdminUserId, GETDATE());";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@RequestId", requestId);
                command.Parameters.AddWithValue("@Status", string.IsNullOrWhiteSpace(status) ? "已受理" : status.Trim());
                command.Parameters.AddWithValue("@AdminReply", (object)adminReply ?? DBNull.Value);
                command.Parameters.AddWithValue("@AdminRemark", (object)adminRemark ?? DBNull.Value);
                command.Parameters.AddWithValue("@RejectReason", (object)rejectReason ?? DBNull.Value);
                command.Parameters.AddWithValue("@AdminUserId", adminUserId);

                connection.Open();
                using (var transaction = connection.BeginTransaction())
                {
                    command.Transaction = transaction;
                    try
                    {
                        command.ExecuteNonQuery();
                        transaction.Commit();
                        message = "售后申请已处理。";
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

        public bool CheckInReservationByCode(string checkInCode, int adminUserId, out string message)
        {
            const string sql = @"
DECLARE @ReservationId INT;

SELECT TOP 1 @ReservationId = Id
FROM dbo.Reservations
WHERE CheckInCode = @CheckInCode
  AND Status IN (N'待确认', N'已确认', N'玩家已确认');

IF @ReservationId IS NULL
BEGIN
    RAISERROR(N'核销码无效，或该订单已取消/已核销。', 16, 1);
    RETURN;
END

UPDATE dbo.Reservations
SET Status = N'已到店',
    ConfirmStatus = CASE WHEN ConfirmStatus IS NULL OR ConfirmStatus = N'' THEN N'门店已核销' ELSE ConfirmStatus END,
    CheckedInAt = GETDATE(),
    CheckInByUserId = @AdminUserId,
    ProcessedAt = GETDATE(),
    ProcessedByUserId = @AdminUserId
WHERE Id = @ReservationId;

INSERT INTO dbo.AdminReplyLogs(BusinessType, BusinessId, AdminUserId, ReplyContent, VisibleToUser, CreatedAt)
VALUES(N'Reservation', @ReservationId, @AdminUserId, N'门店已完成到店核销，请按现场 DM 引导进入房间。', 1, GETDATE());

INSERT INTO dbo.BusinessActionLogs(BusinessType, BusinessId, ActionType, ActionTitle, ActionContent, OperatorUserId, CreatedAt)
VALUES(N'Reservation', @ReservationId, N'到店核销', N'门店核销预约订单', N'核销码：' + @CheckInCode, @AdminUserId, GETDATE());";

            return ExecuteNonQuery(sql, command =>
            {
                command.Parameters.AddWithValue("@CheckInCode", (checkInCode ?? string.Empty).Trim());
                command.Parameters.AddWithValue("@AdminUserId", adminUserId);
            }, "到店核销成功，订单已登记为已到店。", out message);
        }

        public bool AddServiceMessage(string businessType, int businessId, int senderUserId, bool senderIsAdmin, string content, out string message)
        {
            const string sql = @"
IF NULLIF(@Content, N'') IS NULL
BEGIN
    RAISERROR(N'消息内容不能为空。', 16, 1);
    RETURN;
END

IF @SenderIsAdmin = 0 AND NOT EXISTS
(
    SELECT 1
    FROM dbo.Reservations r
    WHERE @BusinessType = N'Reservation'
      AND r.Id = @BusinessId
      AND r.UserId = @SenderUserId
    UNION ALL
    SELECT 1
    FROM dbo.StoreVisitRequests s
    WHERE @BusinessType = N'StoreVisit'
      AND s.Id = @BusinessId
      AND s.UserId = @SenderUserId
    UNION ALL
    SELECT 1
    FROM dbo.AfterSaleRequests a
    WHERE @BusinessType = N'AfterSale'
      AND a.Id = @BusinessId
      AND a.UserId = @SenderUserId
)
BEGIN
    RAISERROR(N'你不能向不属于自己的业务单发送消息。', 16, 1);
    RETURN;
END

INSERT INTO dbo.ServiceMessages
(
    BusinessType,
    BusinessId,
    SenderUserId,
    SenderRole,
    Content,
    IsReadByAdmin,
    IsReadByUser,
    CreatedAt
)
VALUES
(
    @BusinessType,
    @BusinessId,
    @SenderUserId,
    CASE WHEN @SenderIsAdmin = 1 THEN N'Admin' ELSE N'User' END,
    @Content,
    CASE WHEN @SenderIsAdmin = 1 THEN 1 ELSE 0 END,
    CASE WHEN @SenderIsAdmin = 1 THEN 0 ELSE 1 END,
    GETDATE()
);

IF @SenderIsAdmin = 1
BEGIN
    INSERT INTO dbo.AdminReplyLogs(BusinessType, BusinessId, AdminUserId, ReplyContent, VisibleToUser, CreatedAt)
    VALUES(@BusinessType, @BusinessId, @SenderUserId, @Content, 1, GETDATE());
END";

            return ExecuteNonQuery(sql, command =>
            {
                command.Parameters.AddWithValue("@BusinessType", NormalizeServiceBusinessType(businessType));
                command.Parameters.AddWithValue("@BusinessId", businessId);
                command.Parameters.AddWithValue("@SenderUserId", senderUserId);
                command.Parameters.AddWithValue("@SenderIsAdmin", senderIsAdmin);
                command.Parameters.AddWithValue("@Content", (content ?? string.Empty).Trim());
            }, "消息已发送。", out message);
        }

        public IList<ServiceMessageInfo> GetServiceMessages(string businessType, int businessId, int currentUserId, bool isAdmin, int top)
        {
            const string sql = @"
IF @IsAdmin = 0 AND NOT EXISTS
(
    SELECT 1
    FROM dbo.Reservations r
    WHERE @BusinessType = N'Reservation'
      AND r.Id = @BusinessId
      AND r.UserId = @CurrentUserId
    UNION ALL
    SELECT 1
    FROM dbo.StoreVisitRequests s
    WHERE @BusinessType = N'StoreVisit'
      AND s.Id = @BusinessId
      AND s.UserId = @CurrentUserId
    UNION ALL
    SELECT 1
    FROM dbo.AfterSaleRequests a
    WHERE @BusinessType = N'AfterSale'
      AND a.Id = @BusinessId
      AND a.UserId = @CurrentUserId
)
BEGIN
    SELECT TOP 0
        CAST(0 AS INT) AS Id,
        CAST(N'' AS NVARCHAR(30)) AS BusinessType,
        CAST(0 AS INT) AS BusinessId,
        CAST(0 AS INT) AS SenderUserId,
        CAST(N'' AS NVARCHAR(80)) AS SenderName,
        CAST(N'' AS NVARCHAR(20)) AS SenderRole,
        CAST(N'' AS NVARCHAR(800)) AS Content,
        CAST(0 AS BIT) AS IsReadByAdmin,
        CAST(0 AS BIT) AS IsReadByUser,
        GETDATE() AS CreatedAt;
    RETURN;
END

SELECT TOP (@Top)
    m.Id,
    m.BusinessType,
    m.BusinessId,
    m.SenderUserId,
    ISNULL(u.DisplayName, N'系统') AS SenderName,
    m.SenderRole,
    m.Content,
    m.IsReadByAdmin,
    m.IsReadByUser,
    m.CreatedAt
FROM dbo.ServiceMessages m
LEFT JOIN dbo.Users u ON u.Id = m.SenderUserId
WHERE m.BusinessType = @BusinessType
  AND m.BusinessId = @BusinessId
ORDER BY m.CreatedAt ASC, m.Id ASC;";

            return ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@BusinessType", NormalizeServiceBusinessType(businessType));
                command.Parameters.AddWithValue("@BusinessId", businessId);
                command.Parameters.AddWithValue("@CurrentUserId", currentUserId);
                command.Parameters.AddWithValue("@IsAdmin", isAdmin);
            }, MapServiceMessage);
        }

        public bool MarkServiceMessagesAsRead(string businessType, int businessId, int currentUserId, bool isAdmin, out string message)
        {
            const string sql = @"
IF @IsAdmin = 0 AND NOT EXISTS
(
    SELECT 1
    FROM dbo.Reservations r
    WHERE @BusinessType = N'Reservation'
      AND r.Id = @BusinessId
      AND r.UserId = @CurrentUserId
    UNION ALL
    SELECT 1
    FROM dbo.StoreVisitRequests s
    WHERE @BusinessType = N'StoreVisit'
      AND s.Id = @BusinessId
      AND s.UserId = @CurrentUserId
    UNION ALL
    SELECT 1
    FROM dbo.AfterSaleRequests a
    WHERE @BusinessType = N'AfterSale'
      AND a.Id = @BusinessId
      AND a.UserId = @CurrentUserId
)
BEGIN
    RAISERROR(N'你不能操作不属于自己的业务单消息。', 16, 1);
    RETURN;
END

UPDATE dbo.ServiceMessages
SET
    IsReadByAdmin = CASE WHEN @IsAdmin = 1 AND SenderRole = N'User' THEN 1 ELSE IsReadByAdmin END,
    IsReadByUser = CASE WHEN @IsAdmin = 0 AND SenderRole = N'Admin' THEN 1 ELSE IsReadByUser END
WHERE BusinessType = @BusinessType
  AND BusinessId = @BusinessId;";

            return ExecuteNonQuery(sql, command =>
            {
                command.Parameters.AddWithValue("@BusinessType", NormalizeServiceBusinessType(businessType));
                command.Parameters.AddWithValue("@BusinessId", businessId);
                command.Parameters.AddWithValue("@CurrentUserId", currentUserId);
                command.Parameters.AddWithValue("@IsAdmin", isAdmin);
            }, "消息状态已更新。", out message);
        }

        public IList<ServiceMessageInfo> GetRecentServiceMessagesForAdmin(int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    m.Id,
    m.BusinessType,
    m.BusinessId,
    m.SenderUserId,
    ISNULL(u.DisplayName, N'系统') AS SenderName,
    m.SenderRole,
    m.Content,
    m.IsReadByAdmin,
    m.IsReadByUser,
    m.CreatedAt
FROM dbo.ServiceMessages m
LEFT JOIN dbo.Users u ON u.Id = m.SenderUserId
ORDER BY
    CASE WHEN m.SenderRole = N'User' AND m.IsReadByAdmin = 0 THEN 0 ELSE 1 END,
    m.CreatedAt DESC,
    m.Id DESC;";

            return ExecuteList(sql, command => command.Parameters.AddWithValue("@Top", top), MapServiceMessage);
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

        public IList<AdminReplyLogInfo> GetUserVisibleReplyLogs(int userId, int top)
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
WHERE l.VisibleToUser = 1
  AND
  (
      (l.BusinessType = N'Reservation' AND EXISTS
      (
          SELECT 1
          FROM dbo.Reservations r
          WHERE r.Id = l.BusinessId
            AND r.UserId = @UserId
      ))
      OR
      (l.BusinessType = N'StoreVisit' AND EXISTS
      (
          SELECT 1
          FROM dbo.StoreVisitRequests s
          WHERE s.Id = l.BusinessId
            AND s.UserId = @UserId
      ))
      OR
      (l.BusinessType = N'AfterSale' AND EXISTS
      (
          SELECT 1
          FROM dbo.AfterSaleRequests a
          WHERE a.Id = l.BusinessId
            AND a.UserId = @UserId
      ))
  )
ORDER BY l.CreatedAt DESC, l.Id DESC;";

            return ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@UserId", userId);
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

        public IList<UserNotificationInfo> GetUserNotifications(int userId, int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    n.NotificationKey,
    Category,
    Title,
    Content,
    TargetUrl,
    CAST(CASE WHEN readLog.Id IS NULL THEN 0 ELSE 1 END AS BIT) AS IsRead,
    CreatedAt
FROM
(
    SELECT
        N'reply:' + l.BusinessType + N':' + CONVERT(NVARCHAR(20), l.BusinessId) + N':' + CONVERT(NVARCHAR(20), l.Id) AS NotificationKey,
        N'订单回复' AS Category,
        CASE l.BusinessType
            WHEN N'Reservation' THEN N'预约订单有新回复'
            WHEN N'StoreVisit' THEN N'到店联系单有新回复'
            WHEN N'AfterSale' THEN N'售后申请有新回复'
            ELSE N'门店有新回复'
        END AS Title,
        l.ReplyContent AS Content,
        N'PlayerHub.aspx?tab=orders' AS TargetUrl,
        l.CreatedAt
    FROM dbo.AdminReplyLogs l
    WHERE l.VisibleToUser = 1
      AND
      (
          (l.BusinessType = N'Reservation' AND EXISTS
          (
              SELECT 1 FROM dbo.Reservations r
              WHERE r.Id = l.BusinessId AND r.UserId = @UserId
          ))
          OR
          (l.BusinessType = N'StoreVisit' AND EXISTS
          (
              SELECT 1 FROM dbo.StoreVisitRequests s
              WHERE s.Id = l.BusinessId AND s.UserId = @UserId
          ))
          OR
          (l.BusinessType = N'AfterSale' AND EXISTS
          (
              SELECT 1 FROM dbo.AfterSaleRequests a
              WHERE a.Id = l.BusinessId AND a.UserId = @UserId
          ))
      )

    UNION ALL

    SELECT
        N'service:' + m.BusinessType + N':' + CONVERT(NVARCHAR(20), m.BusinessId) + N':' + CONVERT(NVARCHAR(20), m.Id),
        N'客服会话',
        N'门店客服回复了你',
        m.Content,
        N'PlayerHub.aspx?tab=orders',
        m.CreatedAt
    FROM dbo.ServiceMessages m
    WHERE m.SenderRole = N'Admin'
      AND
      (
          (m.BusinessType = N'Reservation' AND EXISTS
          (
              SELECT 1 FROM dbo.Reservations r
              WHERE r.Id = m.BusinessId AND r.UserId = @UserId
          ))
          OR
          (m.BusinessType = N'StoreVisit' AND EXISTS
          (
              SELECT 1 FROM dbo.StoreVisitRequests s
              WHERE s.Id = m.BusinessId AND s.UserId = @UserId
          ))
          OR
          (m.BusinessType = N'AfterSale' AND EXISTS
          (
              SELECT 1 FROM dbo.AfterSaleRequests a
              WHERE a.Id = m.BusinessId AND a.UserId = @UserId
          ))
      )

    UNION ALL

    SELECT
        N'coupon:' + CONVERT(NVARCHAR(20), c.Id),
        N'优惠券',
        N'你收到一张优惠券',
        c.Title + N'，可抵扣 ¥' + CONVERT(NVARCHAR(30), CONVERT(DECIMAL(10,2), c.DiscountAmount)),
        N'Booking.aspx',
        c.IssuedAt
    FROM dbo.UserCoupons c
    WHERE c.UserId = @UserId

    UNION ALL

    SELECT
        N'reminder-day:' + CONVERT(NVARCHAR(20), rv.Id) + N':' + CONVERT(NVARCHAR(16), s.SessionDateTime, 120),
        N'到店提醒',
        N'明日开场提醒：' + sc.Name,
        N'请提前确认人数与出发时间。开场 ' + CONVERT(NVARCHAR(16), s.SessionDateTime, 120) + N'，房间 ' + r.Name + N'，核销码 ' + ISNULL(rv.CheckInCode, N'待生成'),
        N'OrderDetails.aspx?reservationId=' + CONVERT(NVARCHAR(20), rv.Id),
        DATEADD(HOUR, -24, s.SessionDateTime)
    FROM dbo.Reservations rv
    INNER JOIN dbo.Sessions s ON s.Id = rv.SessionId
    INNER JOIN dbo.Scripts sc ON sc.Id = s.ScriptId
    INNER JOIN dbo.Rooms r ON r.Id = s.RoomId
    WHERE rv.UserId = @UserId
      AND s.SessionDateTime >= DATEADD(HOUR, 24, GETDATE())
      AND s.SessionDateTime < DATEADD(HOUR, 48, GETDATE())
      AND rv.Status IN (N'待确认', N'已确认', N'玩家已确认', N'申请改期')

    UNION ALL

    SELECT
        N'reminder-go:' + CONVERT(NVARCHAR(20), rv.Id) + N':' + CONVERT(NVARCHAR(16), s.SessionDateTime, 120),
        N'到店提醒',
        N'出发提醒：' + sc.Name,
        N'距离开场不足 2 小时。请携带核销码 ' + ISNULL(rv.CheckInCode, N'待生成') + N'，按时前往 ' + r.Name,
        N'CheckInPass.aspx?reservationId=' + CONVERT(NVARCHAR(20), rv.Id),
        DATEADD(HOUR, -2, s.SessionDateTime)
    FROM dbo.Reservations rv
    INNER JOIN dbo.Sessions s ON s.Id = rv.SessionId
    INNER JOIN dbo.Scripts sc ON sc.Id = s.ScriptId
    INNER JOIN dbo.Rooms r ON r.Id = s.RoomId
    WHERE rv.UserId = @UserId
      AND s.SessionDateTime >= GETDATE()
      AND s.SessionDateTime < DATEADD(HOUR, 2, GETDATE())
      AND rv.Status IN (N'待确认', N'已确认', N'玩家已确认', N'申请改期')

    UNION ALL

    SELECT
        N'reminder-door:' + CONVERT(NVARCHAR(20), rv.Id) + N':' + CONVERT(NVARCHAR(16), s.SessionDateTime, 120),
        N'到店提醒',
        N'即将开始：' + sc.Name,
        N'开场时间 ' + CONVERT(NVARCHAR(16), s.SessionDateTime, 120) + N'，房间 ' + r.Name + N'，核销码 ' + ISNULL(rv.CheckInCode, N'待生成'),
        N'CheckInPass.aspx?reservationId=' + CONVERT(NVARCHAR(20), rv.Id),
        DATEADD(MINUTE, -30, s.SessionDateTime)
    FROM dbo.Reservations rv
    INNER JOIN dbo.Sessions s ON s.Id = rv.SessionId
    INNER JOIN dbo.Scripts sc ON sc.Id = s.ScriptId
    INNER JOIN dbo.Rooms r ON r.Id = s.RoomId
    WHERE rv.UserId = @UserId
      AND s.SessionDateTime >= GETDATE()
      AND s.SessionDateTime < DATEADD(HOUR, 1, GETDATE())
      AND rv.Status IN (N'待确认', N'已确认', N'玩家已确认', N'申请改期')

    UNION ALL

    SELECT
        N'late:' + CONVERT(NVARCHAR(20), rv.Id) + N':' + CONVERT(NVARCHAR(16), s.SessionDateTime, 120),
        N'迟到提醒',
        N'你已接近迟到：' + sc.Name,
        N'当前已超过开场 15 分钟仍未核销，请尽快联系门店或通过订单会话说明情况。',
        N'OrderConversation.aspx?reservationId=' + CONVERT(NVARCHAR(20), rv.Id),
        DATEADD(MINUTE, 15, s.SessionDateTime)
    FROM dbo.Reservations rv
    INNER JOIN dbo.Sessions s ON s.Id = rv.SessionId
    INNER JOIN dbo.Scripts sc ON sc.Id = s.ScriptId
    WHERE rv.UserId = @UserId
      AND rv.CheckedInAt IS NULL
      AND s.SessionDateTime < DATEADD(MINUTE, -15, GETDATE())
      AND s.SessionDateTime >= DATEADD(HOUR, -3, GETDATE())
      AND rv.Status IN (N'待确认', N'已确认', N'玩家已确认', N'申请改期')

    UNION ALL

    SELECT
        N'waitlist-open:' + CONVERT(NVARCHAR(20), w.Id) + N':' + CONVERT(NVARCHAR(10), seatStat.RemainingSeats),
        N'补位通知',
        N'候补场次已腾出名额',
        N'你候补的《' + sc.Name + N'》当前腾出 ' + CONVERT(NVARCHAR(10), seatStat.RemainingSeats) + N' 个名额，可优先回到预约页抢位。',
        N'Booking.aspx?sessionId=' + CONVERT(NVARCHAR(20), w.SessionId),
        GETDATE()
    FROM dbo.ReservationWaitlists w
    INNER JOIN dbo.Sessions s ON s.Id = w.SessionId
    INNER JOIN dbo.Scripts sc ON sc.Id = s.ScriptId
    OUTER APPLY
    (
        SELECT s.MaxPlayers - ISNULL(SUM(CASE WHEN r.Status IN (N'待确认', N'已确认', N'申请改期', N'玩家已确认', N'已到店') THEN r.PlayerCount ELSE 0 END), 0) AS RemainingSeats
        FROM dbo.Reservations r
        WHERE r.SessionId = s.Id
    ) seatStat
    WHERE w.UserId = @UserId
      AND w.Status = N'Pending'
      AND s.Status = N'开放预约'
      AND s.SessionDateTime >= GETDATE()
      AND seatStat.RemainingSeats >= w.PlayerCount

    UNION ALL

    SELECT
        N'aftersale:' + CONVERT(NVARCHAR(20), a.Id) + N':' + a.Status,
        N'售后进度',
        N'售后申请状态更新',
        a.RequestType + N'：' + a.Status,
        N'PlayerHub.aspx?tab=orders',
        ISNULL(a.ProcessedAt, a.CreatedAt)
    FROM dbo.AfterSaleRequests a
    WHERE a.UserId = @UserId
) n
LEFT JOIN dbo.UserNotificationReads readLog
    ON readLog.UserId = @UserId
   AND readLog.NotificationKey = n.NotificationKey
ORDER BY CreatedAt DESC;";

            return ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@UserId", userId);
            }, reader => new UserNotificationInfo
            {
                NotificationKey = GetString(reader, "NotificationKey"),
                Category = GetString(reader, "Category"),
                Title = GetString(reader, "Title"),
                Content = GetString(reader, "Content"),
                TargetUrl = GetString(reader, "TargetUrl"),
                IsRead = GetBoolean(reader, "IsRead"),
                CreatedAt = GetDateTime(reader, "CreatedAt")
            });
        }

        public int GetUnreadNotificationCount(int userId, int top = 80)
        {
            var notifications = GetUserNotifications(userId, top);
            return notifications.Count(item => !item.IsRead);
        }

        public void MarkNotificationsAsRead(int userId, IList<string> notificationKeys)
        {
            if (userId <= 0 || notificationKeys == null || notificationKeys.Count == 0)
            {
                return;
            }

            using (var connection = DbHelper.CreateConnection())
            {
                connection.Open();
                foreach (var key in notificationKeys)
                {
                    if (string.IsNullOrWhiteSpace(key))
                    {
                        continue;
                    }

                    using (var command = new SqlCommand(@"
IF NOT EXISTS
(
    SELECT 1 FROM dbo.UserNotificationReads
    WHERE UserId = @UserId AND NotificationKey = @NotificationKey
)
BEGIN
    INSERT INTO dbo.UserNotificationReads(UserId, NotificationKey, ReadAt)
    VALUES(@UserId, @NotificationKey, GETDATE());
END;", connection))
                    {
                        command.Parameters.AddWithValue("@UserId", userId);
                        command.Parameters.AddWithValue("@NotificationKey", key.Trim());
                        command.ExecuteNonQuery();
                    }
                }
            }
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
                HostUserId = GetNullableInt32(reader, "HostUserId"),
                HostBriefing = GetString(reader, "HostBriefing"),
                HostAcceptedAt = GetNullableDateTime(reader, "HostAcceptedAt"),
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
                CouponId = GetNullableInt32(reader, "CouponId"),
                DiscountAmount = GetDecimal(reader, "DiscountAmount"),
                CouponTitle = GetString(reader, "CouponTitle"),
                PaymentStatus = GetString(reader, "PaymentStatus"),
                CheckInCode = GetString(reader, "CheckInCode"),
                CheckedInAt = GetNullableDateTime(reader, "CheckedInAt"),
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

        private static ReservationInfo MapUserReservationInfo(SqlDataReader reader)
        {
            var item = MapAdminReservationInfo(reader);
            item.ScriptId = GetInt32(reader, "ScriptId");
            item.LatestAfterSaleId = GetNullableInt32(reader, "LatestAfterSaleId");
            item.LatestAfterSaleType = GetString(reader, "LatestAfterSaleType");
            item.LatestAfterSaleStatus = GetString(reader, "LatestAfterSaleStatus");
            item.LatestAfterSaleCreatedAt = GetNullableDateTime(reader, "LatestAfterSaleCreatedAt");
            return item;
        }

        private static ReservationWaitlistInfo MapReservationWaitlistInfo(SqlDataReader reader)
        {
            var phone = GetString(reader, "Phone");
            var remainingSeats = GetInt32(reader, "RemainingSeats");
            var playerCount = GetInt32(reader, "PlayerCount");

            return new ReservationWaitlistInfo
            {
                Id = GetInt32(reader, "Id"),
                SessionId = GetInt32(reader, "SessionId"),
                UserId = GetInt32(reader, "UserId"),
                ContactName = GetString(reader, "ContactName"),
                PhoneMasked = MaskPhone(phone),
                ScriptName = GetString(reader, "ScriptName"),
                RoomName = GetString(reader, "RoomName"),
                HostName = GetString(reader, "HostName"),
                SessionDateTime = GetDateTime(reader, "SessionDateTime"),
                PlayerCount = playerCount,
                Note = GetString(reader, "Note"),
                Status = GetString(reader, "Status"),
                RemainingSeats = remainingSeats,
                CanBookNow = remainingSeats >= playerCount,
                CreatedAt = GetDateTime(reader, "CreatedAt")
            };
        }

        private static CouponInfo MapCoupon(SqlDataReader reader)
        {
            return new CouponInfo
            {
                Id = GetInt32(reader, "Id"),
                UserId = GetInt32(reader, "UserId"),
                UserDisplayName = GetString(reader, "UserDisplayName"),
                Username = GetString(reader, "Username"),
                Title = GetString(reader, "Title"),
                CouponType = GetString(reader, "CouponType"),
                DiscountAmount = GetDecimal(reader, "DiscountAmount"),
                MinSpend = GetDecimal(reader, "MinSpend"),
                Status = GetString(reader, "Status"),
                Source = GetString(reader, "Source"),
                IssuedAt = GetDateTime(reader, "IssuedAt"),
                ValidFrom = GetDateTime(reader, "ValidFrom"),
                ValidUntil = GetDateTime(reader, "ValidUntil"),
                UsedReservationId = GetNullableInt32(reader, "UsedReservationId"),
                UsedAt = GetNullableDateTime(reader, "UsedAt")
            };
        }

        private static ReviewInfo MapReview(SqlDataReader reader)
        {
            return new ReviewInfo
            {
                Id = GetInt32(reader, "Id"),
                ScriptId = GetInt32(reader, "ScriptId"),
                ScriptName = GetString(reader, "ScriptName"),
                ReviewerName = GetString(reader, "ReviewerName"),
                Rating = GetInt32(reader, "Rating"),
                Content = GetString(reader, "Content"),
                ReviewDate = GetDateTime(reader, "ReviewDate"),
                HighlightTag = GetString(reader, "HighlightTag"),
                UserId = GetNullableInt32(reader, "UserId"),
                ReservationId = GetNullableInt32(reader, "ReservationId"),
                RoomName = GetString(reader, "RoomName"),
                SessionDateTime = GetNullableDateTime(reader, "SessionDateTime"),
                ReservationAmount = GetDecimal(reader, "ReservationAmount"),
                ReservationStatus = GetString(reader, "ReservationStatus"),
                IsFeatured = GetBoolean(reader, "IsFeatured"),
                IsHidden = GetBoolean(reader, "IsHidden"),
                AdminReply = GetString(reader, "AdminReply")
            };
        }

        private static ServiceMessageInfo MapServiceMessage(SqlDataReader reader)
        {
            return new ServiceMessageInfo
            {
                Id = GetInt32(reader, "Id"),
                BusinessType = GetString(reader, "BusinessType"),
                BusinessId = GetInt32(reader, "BusinessId"),
                SenderUserId = GetInt32(reader, "SenderUserId"),
                SenderName = GetString(reader, "SenderName"),
                SenderRole = GetString(reader, "SenderRole"),
                Content = GetString(reader, "Content"),
                IsReadByAdmin = GetBoolean(reader, "IsReadByAdmin"),
                IsReadByUser = GetBoolean(reader, "IsReadByUser"),
                CreatedAt = GetDateTime(reader, "CreatedAt")
            };
        }

        private static AfterSaleRequestInfo MapAfterSaleRequest(SqlDataReader reader)
        {
            var phone = GetString(reader, "Phone");

            return new AfterSaleRequestInfo
            {
                Id = GetInt32(reader, "Id"),
                ReservationId = GetInt32(reader, "ReservationId"),
                UserId = GetInt32(reader, "UserId"),
                ContactName = GetString(reader, "ContactName"),
                PhoneMasked = MaskPhone(phone),
                ScriptName = GetString(reader, "ScriptName"),
                RoomName = GetString(reader, "RoomName"),
                HostName = GetString(reader, "HostName"),
                SessionDateTime = GetDateTime(reader, "SessionDateTime"),
                ReservationAmount = GetDecimal(reader, "ReservationAmount"),
                RequestType = GetString(reader, "RequestType"),
                Reason = GetString(reader, "Reason"),
                RequestedAmount = GetDecimal(reader, "RequestedAmount"),
                Status = GetString(reader, "Status"),
                AdminReply = GetString(reader, "AdminReply"),
                AdminRemark = GetString(reader, "AdminRemark"),
                EvidenceUrl = GetString(reader, "EvidenceUrl"),
                RejectReason = GetString(reader, "RejectReason"),
                AppealReason = GetString(reader, "AppealReason"),
                RefundTransactionId = GetNullableInt32(reader, "RefundTransactionId"),
                RefundedAmount = GetDecimal(reader, "RefundedAmount"),
                CreatedAt = GetDateTime(reader, "CreatedAt"),
                AcceptedAt = GetNullableDateTime(reader, "AcceptedAt"),
                RejectedAt = GetNullableDateTime(reader, "RejectedAt"),
                AppealedAt = GetNullableDateTime(reader, "AppealedAt"),
                ProcessedAt = GetNullableDateTime(reader, "ProcessedAt")
            };
        }

        private static string NormalizeAfterSaleType(string requestType)
        {
            switch ((requestType ?? string.Empty).Trim())
            {
                case "退款申请":
                case "改期协商":
                case "体验投诉":
                case "其他售后":
                    return requestType.Trim();
                default:
                    return "其他售后";
            }
        }

        private static string NormalizeServiceBusinessType(string businessType)
        {
            switch ((businessType ?? string.Empty).Trim())
            {
                case "Reservation":
                case "StoreVisit":
                case "AfterSale":
                    return businessType.Trim();
                default:
                    return "Reservation";
            }
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



