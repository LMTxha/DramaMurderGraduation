using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web.Data
{
    /// <summary>
    /// 扩展功能页的数据仓储。
    /// 主要服务今日推荐、挑战、直播、会员、玩家档案、分析看板和观战相关页面。
    /// </summary>
    public class FeatureRepository
    {
        /// <summary>
        /// 获取“今日推荐”卡片数据。
        /// </summary>
        public IList<RecommendationInfo> GetTodayRecommendations(int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    Id,
    Title,
    Summary,
    CoverImage,
    PlayerCount,
    Difficulty,
    Rating,
    HighlightTag,
    DestinationUrl
FROM dbo.TodayRecommendations
ORDER BY SortOrder ASC, Id ASC;";

            return ExecuteList(sql, command => command.Parameters.AddWithValue("@Top", top), reader => new RecommendationInfo
            {
                Id = GetInt32(reader, "Id"),
                Title = GetString(reader, "Title"),
                Summary = GetString(reader, "Summary"),
                CoverImage = GetString(reader, "CoverImage"),
                PlayerCount = GetInt32(reader, "PlayerCount"),
                Difficulty = GetString(reader, "Difficulty"),
                Rating = GetDecimal(reader, "Rating"),
                HighlightTag = GetString(reader, "HighlightTag"),
                DestinationUrl = GetString(reader, "DestinationUrl")
            });
        }

        /// <summary>
        /// 获取限时挑战列表。
        /// </summary>
        public IList<ChallengeInfo> GetChallenges(int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    Id,
    Title,
    Description,
    CoverImage,
    EndTime,
    RewardSummary,
    StatusTag,
    RouteUrl
FROM dbo.Challenges
ORDER BY SortOrder ASC, Id ASC;";

            return ExecuteList(sql, command => command.Parameters.AddWithValue("@Top", top), reader => new ChallengeInfo
            {
                Id = GetInt32(reader, "Id"),
                Title = GetString(reader, "Title"),
                Description = GetString(reader, "Description"),
                CoverImage = GetString(reader, "CoverImage"),
                EndTime = GetDateTime(reader, "EndTime"),
                RewardSummary = GetString(reader, "RewardSummary"),
                StatusTag = GetString(reader, "StatusTag"),
                RouteUrl = GetString(reader, "RouteUrl")
            });
        }

        /// <summary>
        /// 获取正在直播或高热度的游戏场次。
        /// </summary>
        public IList<LiveSessionInfo> GetLiveSessions(int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    Id,
    Title,
    Summary,
    HostName,
    ViewerCount,
    CoverImage,
    RouteUrl,
    StatusText,
    HeatScore
FROM dbo.LiveSessions
ORDER BY HeatScore DESC, Id ASC;";

            return ExecuteList(sql, command => command.Parameters.AddWithValue("@Top", top), reader => new LiveSessionInfo
            {
                Id = GetInt32(reader, "Id"),
                Title = GetString(reader, "Title"),
                Summary = GetString(reader, "Summary"),
                HostName = GetString(reader, "HostName"),
                ViewerCount = GetInt32(reader, "ViewerCount"),
                CoverImage = GetString(reader, "CoverImage"),
                RouteUrl = GetString(reader, "RouteUrl"),
                StatusText = GetString(reader, "StatusText"),
                HeatScore = GetInt32(reader, "HeatScore")
            });
        }

        /// <summary>
        /// 获取会员订阅方案。
        /// </summary>
        public IList<MembershipPlanInfo> GetMembershipPlans()
        {
            const string sql = @"
SELECT
    Id,
    Name,
    Price,
    BillingCycle,
    Description,
    BenefitSummary,
    HighlightText
FROM dbo.MembershipPlans
ORDER BY SortOrder ASC, Id ASC;";

            return ExecuteList(sql, null, reader => new MembershipPlanInfo
            {
                Id = GetInt32(reader, "Id"),
                Name = GetString(reader, "Name"),
                Price = GetDecimal(reader, "Price"),
                BillingCycle = GetString(reader, "BillingCycle"),
                Description = GetString(reader, "Description"),
                BenefitSummary = GetString(reader, "BenefitSummary"),
                HighlightText = GetString(reader, "HighlightText")
            });
        }

        /// <summary>
        /// 获取玩家身份选择项。
        /// </summary>
        public IList<IdentityOptionInfo> GetIdentityOptions()
        {
            const string sql = @"
SELECT
    Id,
    Name,
    Description,
    AbilityFocus,
    RecommendedFor
FROM dbo.IdentityOptions
ORDER BY SortOrder ASC, Id ASC;";

            return ExecuteList(sql, null, reader => new IdentityOptionInfo
            {
                Id = GetInt32(reader, "Id"),
                Name = GetString(reader, "Name"),
                Description = GetString(reader, "Description"),
                AbilityFocus = GetString(reader, "AbilityFocus"),
                RecommendedFor = GetString(reader, "RecommendedFor")
            });
        }

        /// <summary>
        /// 获取玩家档案。
        /// </summary>
        public PlayerProfileInfo GetPlayerProfile(int userId)
        {
            const string sql = @"
SELECT TOP 1
    UserId,
    DisplayName,
    DisplayTitle,
    Motto,
    AvatarUrl,
    FavoriteGenre,
    JoinDays,
    CompletedScripts,
    WinRate,
    ReputationLevel
FROM dbo.PlayerProfiles
WHERE UserId = @UserId;";

            var list = ExecuteList(sql, command => command.Parameters.AddWithValue("@UserId", userId), reader => new PlayerProfileInfo
            {
                UserId = GetInt32(reader, "UserId"),
                DisplayName = GetString(reader, "DisplayName"),
                DisplayTitle = GetString(reader, "DisplayTitle"),
                Motto = GetString(reader, "Motto"),
                AvatarUrl = GetString(reader, "AvatarUrl"),
                FavoriteGenre = GetString(reader, "FavoriteGenre"),
                JoinDays = GetInt32(reader, "JoinDays"),
                CompletedScripts = GetInt32(reader, "CompletedScripts"),
                WinRate = GetDecimal(reader, "WinRate"),
                ReputationLevel = GetString(reader, "ReputationLevel")
            });

            return list.Count > 0 ? list[0] : null;
        }

        /// <summary>
        /// 新增或更新玩家档案。
        /// </summary>
        public bool UpsertPlayerProfile(PlayerProfileInfo profile, out string message)
        {
            const string sql = @"
IF EXISTS (SELECT 1 FROM dbo.PlayerProfiles WHERE UserId = @UserId)
BEGIN
    UPDATE dbo.PlayerProfiles
    SET DisplayName = @DisplayName,
        DisplayTitle = @DisplayTitle,
        Motto = @Motto,
        AvatarUrl = @AvatarUrl,
        FavoriteGenre = @FavoriteGenre
    WHERE UserId = @UserId;
END
ELSE
BEGIN
    INSERT INTO dbo.PlayerProfiles
    (
        UserId,
        DisplayName,
        DisplayTitle,
        Motto,
        AvatarUrl,
        FavoriteGenre,
        JoinDays,
        CompletedScripts,
        WinRate,
        ReputationLevel
    )
    VALUES
    (
        @UserId,
        @DisplayName,
        @DisplayTitle,
        @Motto,
        @AvatarUrl,
        @FavoriteGenre,
        30,
        0,
        0,
        N'新秀玩家'
    );
END;

UPDATE dbo.Users
SET DisplayName = @DisplayName
WHERE Id = @UserId;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", profile.UserId);
                command.Parameters.AddWithValue("@DisplayName", profile.DisplayName);
                command.Parameters.AddWithValue("@DisplayTitle", profile.DisplayTitle);
                command.Parameters.AddWithValue("@Motto", profile.Motto);
                command.Parameters.AddWithValue("@AvatarUrl", profile.AvatarUrl);
                command.Parameters.AddWithValue("@FavoriteGenre", profile.FavoriteGenre);

                connection.Open();
                command.ExecuteNonQuery();
            }

                message = "玩家档案已保存，新的资料会立即同步到页面展示。";
            return true;
        }

        /// <summary>
        /// 获取玩家能力值。
        /// </summary>
        public PlayerAbilityInfo GetPlayerAbilities(int userId)
        {
            const string sql = @"
SELECT TOP 1
    UserId,
    DeductionPower,
    ObservationPower,
    CreativityPower,
    CollaborationPower,
    ExecutionPower
FROM dbo.PlayerAbilities
WHERE UserId = @UserId;";

            var list = ExecuteList(sql, command => command.Parameters.AddWithValue("@UserId", userId), reader => new PlayerAbilityInfo
            {
                UserId = GetInt32(reader, "UserId"),
                DeductionPower = GetInt32(reader, "DeductionPower"),
                ObservationPower = GetInt32(reader, "ObservationPower"),
                CreativityPower = GetInt32(reader, "CreativityPower"),
                CollaborationPower = GetInt32(reader, "CollaborationPower"),
                ExecutionPower = GetInt32(reader, "ExecutionPower")
            });

            return list.Count > 0 ? list[0] : null;
        }

        /// <summary>
        /// 获取玩家成就墙数据。
        /// </summary>
        public IList<AchievementInfo> GetAchievements(int userId)
        {
            const string sql = @"
SELECT
    Id,
    Title,
    Description,
    RarityTag,
    ProgressValue,
    ProgressTotal,
    EarnedAt
FROM dbo.Achievements
WHERE UserId = @UserId
ORDER BY SortOrder ASC, Id ASC;";

            return ExecuteList(sql, command => command.Parameters.AddWithValue("@UserId", userId), reader => new AchievementInfo
            {
                Id = GetInt32(reader, "Id"),
                Title = GetString(reader, "Title"),
                Description = GetString(reader, "Description"),
                RarityTag = GetString(reader, "RarityTag"),
                ProgressValue = GetInt32(reader, "ProgressValue"),
                ProgressTotal = GetInt32(reader, "ProgressTotal"),
                EarnedAt = GetNullableDateTime(reader, "EarnedAt")
            });
        }

        /// <summary>
        /// 获取玩家最近战绩。
        /// </summary>
        public IList<PlayerBattleRecordInfo> GetPlayerBattleRecords(int userId, int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    Id,
    SessionId,
    ReservationId,
    ScriptName,
    RoomName,
    CharacterName,
    WasCorrect,
    ResultTag,
    VotedCharacterName,
    CorrectCharacterName,
    CompletedAt
FROM dbo.PlayerBattleRecords
WHERE UserId = @UserId
ORDER BY CompletedAt DESC, Id DESC;";

            return ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@UserId", userId);
            }, reader => new PlayerBattleRecordInfo
            {
                Id = GetInt32(reader, "Id"),
                SessionId = GetInt32(reader, "SessionId"),
                ReservationId = GetInt32(reader, "ReservationId"),
                ScriptName = GetString(reader, "ScriptName"),
                RoomName = GetString(reader, "RoomName"),
                CharacterName = GetString(reader, "CharacterName"),
                WasCorrect = GetBoolean(reader, "WasCorrect"),
                ResultTag = GetString(reader, "ResultTag"),
                VotedCharacterName = GetString(reader, "VotedCharacterName"),
                CorrectCharacterName = GetString(reader, "CorrectCharacterName"),
                CompletedAt = GetDateTime(reader, "CompletedAt")
            });
        }

        /// <summary>
        /// 获取演示分析指标。
        /// </summary>
        public AnalyticsMetricInfo GetAnalyticsMetric()
        {
            const string sql = @"
SELECT TOP 1
    SnapshotDate,
    ActiveUsers,
    AverageSessionMinutes,
    TotalBookings,
    RevenueAmount,
    ConversionRate
FROM dbo.AnalyticsSnapshots
ORDER BY SnapshotDate DESC, Id DESC;";

            var list = ExecuteList(sql, null, reader => new AnalyticsMetricInfo
            {
                SnapshotDate = GetDateTime(reader, "SnapshotDate"),
                ActiveUsers = GetInt32(reader, "ActiveUsers"),
                AverageSessionMinutes = GetDecimal(reader, "AverageSessionMinutes"),
                TotalBookings = GetInt32(reader, "TotalBookings"),
                RevenueAmount = GetDecimal(reader, "RevenueAmount"),
                ConversionRate = GetDecimal(reader, "ConversionRate")
            });

            return list.Count > 0 ? list[0] : null;
        }

        /// <summary>
        /// 按时间范围统计真实运营分析指标。
        /// </summary>
        public AnalyticsMetricInfo GetOperationalAnalyticsMetric(DateTime startDate, DateTime endDate)
        {
            const string sql = @"
DECLARE @EndExclusive DATETIME = DATEADD(day, 1, @EndDate);

WITH RangeReservations AS
(
    SELECT
        r.Id,
        r.UserId,
        ISNULL(r.TotalAmount, ISNULL(r.UnitPrice, se.BasePrice) * r.PlayerCount) AS TotalAmount,
        r.Status,
        r.CreatedAt
    FROM dbo.Reservations r
    INNER JOIN dbo.Sessions se ON se.Id = r.SessionId
    WHERE r.CreatedAt >= @StartDate
      AND r.CreatedAt < @EndExclusive
),
RangeSessions AS
(
    SELECT
        s.Id,
        s.HostUserId,
        s.HostName,
        s.SessionDateTime,
        sc.DurationMinutes
    FROM dbo.Sessions s
    INNER JOIN dbo.Scripts sc ON sc.Id = s.ScriptId
    WHERE s.SessionDateTime >= @StartDate
      AND s.SessionDateTime < @EndExclusive
),
OrderUsers AS
(
    SELECT DISTINCT UserId
    FROM RangeReservations
    WHERE UserId IS NOT NULL
),
ReturningUsers AS
(
    SELECT DISTINCT ou.UserId
    FROM OrderUsers ou
    WHERE EXISTS
    (
        SELECT 1
        FROM dbo.Reservations r
        WHERE r.UserId = ou.UserId
          AND r.CreatedAt < @StartDate
          AND r.Status IN (N'已确认', N'玩家已确认', N'已到店', N'已完成')
    )
)
SELECT
    GETDATE() AS SnapshotDate,
    @StartDate AS StartDate,
    @EndDate AS EndDate,
    (SELECT COUNT(1) FROM OrderUsers) AS ActiveUsers,
    CAST(ISNULL((SELECT AVG(CAST(DurationMinutes AS DECIMAL(10,2))) FROM RangeSessions), 0) AS DECIMAL(10,2)) AS AverageSessionMinutes,
    booking.TotalBookings,
    booking.RevenueAmount,
    CAST(CASE WHEN booking.TotalBookings = 0 THEN 0 ELSE booking.ConfirmedBookings * 100.0 / booking.TotalBookings END AS DECIMAL(10,2)) AS ConversionRate,
    booking.ConfirmedBookings,
    booking.CompletedBookings,
    CAST(CASE WHEN booking.ConfirmedBookings = 0 THEN 0 ELSE booking.RevenueAmount / booking.ConfirmedBookings END AS DECIMAL(10,2)) AS AverageOrderValue,
    CAST(CASE WHEN users.OrderingUsers = 0 THEN 0 ELSE users.ReturningUsers * 100.0 / users.OrderingUsers END AS DECIMAL(10,2)) AS RepurchaseRate,
    CAST(CASE WHEN booking.TotalBookings = 0 THEN 0 ELSE refund.RefundCount * 100.0 / booking.TotalBookings END AS DECIMAL(10,2)) AS RefundRate,
    sessionStat.DmSessionCount,
    refund.RefundCount,
    refund.RefundAmount,
    users.OrderingUsers,
    users.ReturningUsers
FROM
(
    SELECT
        COUNT(1) AS TotalBookings,
        SUM(CASE WHEN Status IN (N'已确认', N'玩家已确认', N'已到店', N'已完成') THEN 1 ELSE 0 END) AS ConfirmedBookings,
        SUM(CASE WHEN Status = N'已完成' THEN 1 ELSE 0 END) AS CompletedBookings,
        CAST(ISNULL(SUM(CASE WHEN Status <> N'已取消' THEN TotalAmount ELSE 0 END), 0) AS DECIMAL(10,2)) AS RevenueAmount
    FROM RangeReservations
) booking
CROSS JOIN
(
    SELECT
        (SELECT COUNT(1) FROM OrderUsers) AS OrderingUsers,
        (SELECT COUNT(1) FROM ReturningUsers) AS ReturningUsers
) users
CROSS JOIN
(
    SELECT
        COUNT(1) AS DmSessionCount
    FROM RangeSessions
    WHERE HostUserId IS NOT NULL OR ISNULL(HostName, N'') <> N''
) sessionStat
CROSS JOIN
(
    SELECT
        COUNT(1) AS RefundCount,
        CAST(ISNULL(SUM(CASE WHEN ISNULL(RefundedAmount, 0) > 0 THEN RefundedAmount ELSE RequestedAmount END), 0) AS DECIMAL(10,2)) AS RefundAmount
    FROM dbo.AfterSaleRequests
    WHERE RequestType = N'退款'
      AND Status = N'已完成'
      AND ISNULL(ProcessedAt, CreatedAt) >= @StartDate
      AND ISNULL(ProcessedAt, CreatedAt) < @EndExclusive
) refund;";

            var list = ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@StartDate", startDate.Date);
                command.Parameters.AddWithValue("@EndDate", endDate.Date);
            }, reader => new AnalyticsMetricInfo
            {
                SnapshotDate = GetDateTime(reader, "SnapshotDate"),
                StartDate = GetDateTime(reader, "StartDate"),
                EndDate = GetDateTime(reader, "EndDate"),
                ActiveUsers = GetInt32(reader, "ActiveUsers"),
                AverageSessionMinutes = GetDecimal(reader, "AverageSessionMinutes"),
                TotalBookings = GetInt32(reader, "TotalBookings"),
                RevenueAmount = GetDecimal(reader, "RevenueAmount"),
                ConversionRate = GetDecimal(reader, "ConversionRate"),
                ConfirmedBookings = GetInt32(reader, "ConfirmedBookings"),
                CompletedBookings = GetInt32(reader, "CompletedBookings"),
                AverageOrderValue = GetDecimal(reader, "AverageOrderValue"),
                RepurchaseRate = GetDecimal(reader, "RepurchaseRate"),
                RefundRate = GetDecimal(reader, "RefundRate"),
                DmSessionCount = GetInt32(reader, "DmSessionCount"),
                RefundCount = GetInt32(reader, "RefundCount"),
                RefundAmount = GetDecimal(reader, "RefundAmount"),
                OrderingUsers = GetInt32(reader, "OrderingUsers"),
                ReturningUsers = GetInt32(reader, "ReturningUsers")
            });

            return list.Count > 0 ? list[0] : null;
        }

        /// <summary>
        /// 获取玩家行为热力图区域数据。
        /// </summary>
        public IList<HeatmapZoneInfo> GetHeatmapZones()
        {
            const string sql = @"
SELECT
    Id,
    ZoneName,
    HeatLevel,
    PeakPeriod,
    Summary
FROM dbo.HeatmapZones
ORDER BY SortOrder ASC, Id ASC;";

            return ExecuteList(sql, null, reader => new HeatmapZoneInfo
            {
                Id = GetInt32(reader, "Id"),
                ZoneName = GetString(reader, "ZoneName"),
                HeatLevel = GetInt32(reader, "HeatLevel"),
                PeakPeriod = GetString(reader, "PeakPeriod"),
                Summary = GetString(reader, "Summary")
            });
        }

        /// <summary>
        /// 获取剧本完成率洞察。
        /// </summary>
        public IList<CompletionInsightInfo> GetCompletionInsights()
        {
            const string sql = @"
SELECT
    Id,
    MetricType,
    Name,
    ValueDecimal,
    Summary
FROM dbo.CompletionInsights
ORDER BY SortOrder ASC, Id ASC;";

            return ExecuteList(sql, null, reader => new CompletionInsightInfo
            {
                Id = GetInt32(reader, "Id"),
                MetricType = GetString(reader, "MetricType"),
                Name = GetString(reader, "Name"),
                ValueDecimal = GetDecimal(reader, "ValueDecimal"),
                Summary = GetString(reader, "Summary")
            });
        }

        /// <summary>
        /// 获取虚拟经济洞察。
        /// </summary>
        public IList<EconomyInsightInfo> GetEconomyInsights()
        {
            const string sql = @"
SELECT
    Id,
    CategoryName,
    MetricName,
    MetricValue,
    TrendText
FROM dbo.EconomyInsights
ORDER BY SortOrder ASC, Id ASC;";

            return ExecuteList(sql, null, reader => new EconomyInsightInfo
            {
                Id = GetInt32(reader, "Id"),
                CategoryName = GetString(reader, "CategoryName"),
                MetricName = GetString(reader, "MetricName"),
                MetricValue = GetDecimal(reader, "MetricValue"),
                TrendText = GetString(reader, "TrendText")
            });
        }

        /// <summary>
        /// 获取观战模式选项。
        /// </summary>
        public IList<SpectatorModeInfo> GetSpectatorModes()
        {
            const string sql = @"
SELECT
    Id,
    Name,
    Description,
    SceneText
FROM dbo.SpectatorModes
ORDER BY SortOrder ASC, Id ASC;";

            return ExecuteList(sql, null, reader => new SpectatorModeInfo
            {
                Id = GetInt32(reader, "Id"),
                Name = GetString(reader, "Name"),
                Description = GetString(reader, "Description"),
                SceneText = GetString(reader, "SceneText")
            });
        }

        /// <summary>
        /// 获取可观战房间列表。
        /// </summary>
        public IList<SpectatorRoomInfo> GetSpectatorRooms()
        {
            const string sql = @"
SELECT
    Id,
    Title,
    ScriptName,
    HostName,
    ViewerCount,
    HeatScore,
    CoverImage,
    RoomStatus,
    RouteCode
FROM dbo.SpectatorRooms
ORDER BY HeatScore DESC, Id ASC;";

            return ExecuteList(sql, null, reader => new SpectatorRoomInfo
            {
                Id = GetInt32(reader, "Id"),
                Title = GetString(reader, "Title"),
                ScriptName = GetString(reader, "ScriptName"),
                HostName = GetString(reader, "HostName"),
                ViewerCount = GetInt32(reader, "ViewerCount"),
                HeatScore = GetInt32(reader, "HeatScore"),
                CoverImage = GetString(reader, "CoverImage"),
                RoomStatus = GetString(reader, "RoomStatus"),
                RouteCode = GetString(reader, "RouteCode")
            });
        }

        /// <summary>
        /// 获取观战聊天室消息。
        /// </summary>
        public IList<SpectatorMessageInfo> GetSpectatorMessages(int spectatorRoomId, int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    Id,
    SpectatorRoomId,
    SenderName,
    Content,
    BadgeText,
    SentAt
FROM dbo.SpectatorMessages
WHERE SpectatorRoomId = @SpectatorRoomId
ORDER BY Id DESC;";

            var items = ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@SpectatorRoomId", spectatorRoomId);
            }, reader => new SpectatorMessageInfo
            {
                Id = GetInt32(reader, "Id"),
                SpectatorRoomId = GetInt32(reader, "SpectatorRoomId"),
                SenderName = GetString(reader, "SenderName"),
                Content = GetString(reader, "Content"),
                BadgeText = GetString(reader, "BadgeText"),
                SentAt = GetDateTime(reader, "SentAt")
            });

            var ordered = new List<SpectatorMessageInfo>(items);
            ordered.Reverse();
            return ordered;
        }

        /// <summary>
        /// 为演示页面解析用户 Id。
        /// 如果调用方没有指定用户，则返回一个可用的示例用户。
        /// </summary>
        public int ResolveDemoUserId(int? preferredUserId)
        {
            if (preferredUserId.HasValue)
            {
                return preferredUserId.Value;
            }

            const string sql = @"
SELECT TOP 1 Id
FROM dbo.Users
WHERE ReviewStatus = N'Approved'
ORDER BY CASE WHEN Username = N'admin' THEN 0 ELSE 1 END, Id ASC;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                connection.Open();
                var result = command.ExecuteScalar();
                return result == null || result == DBNull.Value ? 0 : Convert.ToInt32(result);
            }
        }

        /// <summary>
        /// 通用列表查询模板。
        /// </summary>
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

        /// <summary>读取字符串字段，NULL 转空字符串。</summary>
        private static string GetString(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? string.Empty : Convert.ToString(reader[columnName]);
        }

        /// <summary>读取整数字段。</summary>
        private static int GetInt32(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? 0 : Convert.ToInt32(reader[columnName]);
        }

        /// <summary>读取金额或评分字段。</summary>
        private static decimal GetDecimal(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? 0M : Convert.ToDecimal(reader[columnName]);
        }

        /// <summary>读取必填时间字段。</summary>
        private static DateTime GetDateTime(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? DateTime.MinValue : Convert.ToDateTime(reader[columnName]);
        }

        /// <summary>读取可空时间字段。</summary>
        private static DateTime? GetNullableDateTime(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader[columnName]);
        }

        /// <summary>读取布尔字段。</summary>
        private static bool GetBoolean(SqlDataReader reader, string columnName)
        {
            return reader[columnName] != DBNull.Value && Convert.ToBoolean(reader[columnName]);
        }
    }
}
