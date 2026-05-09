using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web.Data
{
    /// <summary>
    /// 游戏房间与 DM 场控的数据仓储。
    /// 负责初始化场次游戏状态、分配角色、推进阶段、发放线索、记录行动日志、投票和结算。
    /// </summary>
    public class GameRepository
    {
        /// <summary>
        /// 确保某个场次拥有完整的游戏运行数据。
        /// 包括 SessionGameStates、玩家角色分配、导入线索转 ScriptClues、初始公共线索和系统日志。
        /// </summary>
        public void EnsureSessionGameData(int sessionId)
        {
            const string sql = @"
IF COL_LENGTH(N'dbo.SessionCharacterAssignments', N'IsEliminated') IS NULL
BEGIN
    ALTER TABLE dbo.SessionCharacterAssignments ADD IsEliminated BIT NOT NULL CONSTRAINT DF_SessionCharacterAssignments_IsEliminated DEFAULT(0);
END

IF COL_LENGTH(N'dbo.SessionCharacterAssignments', N'EliminatedAt') IS NULL
BEGIN
    ALTER TABLE dbo.SessionCharacterAssignments ADD EliminatedAt DATETIME NULL;
END

DECLARE @ScriptId INT;
DECLARE @CurrentStageId INT;
DECLARE @InvestigationStageId INT;

SELECT @ScriptId = ScriptId
FROM dbo.Sessions WITH (UPDLOCK, HOLDLOCK)
WHERE Id = @SessionId;

IF @ScriptId IS NULL
BEGIN
    RETURN;
END

SELECT TOP 1 @InvestigationStageId = Id
FROM dbo.GameStages
WHERE StageKey = N'investigation'
ORDER BY SortOrder ASC, Id ASC;

IF NOT EXISTS (SELECT 1 FROM dbo.SessionGameStates WHERE SessionId = @SessionId)
BEGIN
    SELECT TOP 1 @CurrentStageId = Id
    FROM dbo.GameStages
    ORDER BY SortOrder ASC, Id ASC;

    INSERT INTO dbo.SessionGameStates(SessionId, CurrentStageId, StartedAt, UpdatedAt)
    VALUES(@SessionId, @CurrentStageId, GETDATE(), GETDATE());
END
ELSE
BEGIN
    SELECT @CurrentStageId = CurrentStageId
    FROM dbo.SessionGameStates
    WHERE SessionId = @SessionId;
END

DELETE a
FROM dbo.SessionCharacterAssignments a
INNER JOIN dbo.Reservations r ON r.Id = a.ReservationId
LEFT JOIN dbo.Users reservationUser ON reservationUser.Id = r.UserId
INNER JOIN dbo.ScriptCharacters sc ON sc.Id = a.CharacterId
WHERE a.SessionId = @SessionId
  AND
  (
      r.UserId IS NULL
      OR ISNULL(reservationUser.RoleCode, N'User') IN (N'Admin', N'DM', N'Host', N'Director')
      OR r.Status NOT IN (N'待确认', N'已确认', N'玩家已确认', N'已到店')
      OR sc.Name LIKE N'%手册%'
      OR sc.Name LIKE N'%指南%'
      OR sc.Name LIKE N'%勘误%'
      OR sc.Name LIKE N'%Q&A%'
      OR sc.Name LIKE N'%结局%'
      OR sc.Name LIKE N'%目录%'
      OR sc.Name LIKE N'%组织者%'
      OR sc.Name LIKE N'%BGM%'
  );

;WITH MissingReservations AS
(
    SELECT
        r.Id AS ReservationId,
        ROW_NUMBER() OVER (ORDER BY r.Id ASC) AS RowNumber
    FROM dbo.Reservations r
    INNER JOIN dbo.Users reservationUser ON reservationUser.Id = r.UserId
    WHERE r.SessionId = @SessionId
      AND r.UserId IS NOT NULL
      AND ISNULL(reservationUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')
      AND r.Status IN (N'待确认', N'已确认', N'玩家已确认', N'已到店')
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.SessionCharacterAssignments a
          WHERE a.SessionId = @SessionId
            AND a.ReservationId = r.Id
      )
),
AvailableCharacters AS
(
    SELECT
        sc.Id AS CharacterId,
        ROW_NUMBER() OVER (ORDER BY NEWID()) AS RowNumber
    FROM dbo.ScriptCharacters sc
    WHERE sc.ScriptId = @ScriptId
      AND sc.Name NOT LIKE N'%手册%'
      AND sc.Name NOT LIKE N'%指南%'
      AND sc.Name NOT LIKE N'%勘误%'
      AND sc.Name NOT LIKE N'%Q&A%'
      AND sc.Name NOT LIKE N'%结局%'
      AND sc.Name NOT LIKE N'%目录%'
      AND sc.Name NOT LIKE N'%组织者%'
      AND sc.Name NOT LIKE N'%BGM%'
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.SessionCharacterAssignments a
          WHERE a.SessionId = @SessionId
            AND a.CharacterId = sc.Id
      )
)
INSERT INTO dbo.SessionCharacterAssignments(SessionId, ReservationId, CharacterId, IsReady, CreatedAt)
SELECT @SessionId, mr.ReservationId, ac.CharacterId, 0, GETDATE()
FROM MissingReservations mr
INNER JOIN AvailableCharacters ac ON ac.RowNumber = mr.RowNumber;

IF NOT EXISTS (SELECT 1 FROM dbo.ScriptClues WHERE ScriptId = @ScriptId)
BEGIN
    INSERT INTO dbo.ScriptClues(ScriptId, StageId, Title, Summary, Detail, ClueType, IsPublic, SortOrder)
    SELECT
        @ScriptId,
        @InvestigationStageId,
        LEFT(ISNULL(a.Title, a.FileName), 100),
        LEFT(N'来自数据库导入的真实剧本线索资料：' + ISNULL(a.RelativePath, N''), 200),
        LEFT(N'原始线索文件已保留在剧本资料包中，文件名：' + ISNULL(a.FileName, N'') + N'。路径：' + ISNULL(a.RelativePath, N''), 500),
        CASE
            WHEN a.AssetType = N'image' THEN N'图片线索'
            WHEN a.AssetType = N'document' THEN N'文档线索'
            ELSE N'资料线索'
        END,
        1,
        ROW_NUMBER() OVER (ORDER BY a.SortOrder ASC, a.Id ASC)
    FROM dbo.ScriptAssets a
    WHERE a.ScriptId = @ScriptId
      AND a.RelativePath LIKE N'线索/%';
END

INSERT INTO dbo.SessionClueUnlocks(SessionId, ClueId, RevealedToReservationId, UnlockedByReservationId, RevealMethod, RevealedAt)
SELECT
    @SessionId,
    c.Id,
    NULL,
    NULL,
    N'系统初始发放',
    GETDATE()
FROM dbo.ScriptClues c
WHERE c.ScriptId = @ScriptId
  AND c.StageId = @CurrentStageId
  AND c.IsPublic = 1
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.SessionClueUnlocks u
      WHERE u.SessionId = @SessionId
        AND u.ClueId = c.Id
        AND u.RevealedToReservationId IS NULL
  );

IF NOT EXISTS (SELECT 1 FROM dbo.SessionActionLogs WHERE SessionId = @SessionId)
BEGIN
    INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
    VALUES(@SessionId, NULL, N'System', N'游戏已建立', N'房间已根据数据库中的真实玩家角色随机分配，且同一场次不会重复角色。', GETDATE());
END";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@SessionId", sessionId);
                connection.Open();
                // 角色分配和初始线索发放必须保持一致性，所以使用 Serializable 事务避免并发进入房间时重复分配。
                using (var transaction = connection.BeginTransaction(IsolationLevel.Serializable))
                {
                    command.Transaction = transaction;
                    try
                    {
                        command.ExecuteNonQuery();
                        transaction.Commit();
                    }
                    catch
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
            }
        }

        /// <summary>
        /// 获取游戏房间页面的完整状态快照。
        /// 页面渲染前会先确保初始化和结算，再一次性返回阶段、角色、线索、日志和投票信息。
        /// </summary>
        public GameRoomStateInfo GetGameRoomState(int sessionId, int reservationId)
        {
            EnsureSessionGameData(sessionId);
            EnsureGameSettlement(sessionId);
            ResolveCompletedVoteRound(sessionId, null);

            var currentStage = GetCurrentStage(sessionId);
            var assignments = GetAssignments(sessionId);
            var currentAssignment = default(GameAssignmentInfo);
            foreach (var item in assignments)
            {
                if (item.ReservationId == reservationId)
                {
                    currentAssignment = item;
                    break;
                }
            }

            var currentVote = GetCurrentVote(sessionId, reservationId);
            var lifecycle = GetLifecycle(sessionId, currentStage, currentAssignment, currentVote);

            return new GameRoomStateInfo
            {
                CurrentStage = currentStage,
                Lifecycle = lifecycle,
                Stages = GetStageTimeline(sessionId),
                CurrentAssignment = currentAssignment,
                Assignments = assignments,
                Clues = GetVisibleClues(sessionId, reservationId),
                ActionLogs = GetActionLogs(sessionId, 12),
                CurrentVote = currentVote,
                VoteSummary = GetVoteSummary(sessionId),
                CanVote = lifecycle.CanSubmitVote,
                CorrectCharacterName = GetCorrectCharacterName(sessionId),
                TruthSummary = GetTruthSummary(sessionId),
                PendingClues = lifecycle.IsGameEnded ? new List<GameHostClueOptionInfo>() : GetPendingClues(sessionId)
            };
        }

        /// <summary>
        /// 确保已结束但未结算的游戏完成奖励、积分或状态收尾。
        /// 重复调用是安全的，已结算场次不会再次处理。
        /// </summary>
        public void EnsureGameSettlement(int sessionId)
        {
            const string sql = @"
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.SessionGameStates
    WHERE SessionId = @SessionId
      AND GameEndedAt IS NOT NULL
      AND SettledAt IS NULL
)
BEGIN
    RETURN;
END

BEGIN TRY
    BEGIN TRANSACTION;

DECLARE @CorrectCharacterId INT;
DECLARE @CorrectCharacterName NVARCHAR(50);
DECLARE @CompletedAt DATETIME;

SELECT
    @CorrectCharacterId = killerCharacter.Id,
    @CorrectCharacterName = ISNULL(NULLIF(state.CaseKillerCharacterName, N''), ISNULL(script.KillerCharacterName, N'')),
    @CompletedAt = state.GameEndedAt
FROM dbo.SessionGameStates state
INNER JOIN dbo.Sessions sessionInfo ON sessionInfo.Id = state.SessionId
INNER JOIN dbo.Scripts script ON script.Id = sessionInfo.ScriptId
LEFT JOIN dbo.ScriptCharacters killerCharacter
    ON killerCharacter.ScriptId = script.Id
   AND killerCharacter.Name = ISNULL(NULLIF(state.CaseKillerCharacterName, N''), script.KillerCharacterName)
WHERE state.SessionId = @SessionId;

DECLARE @Results TABLE
(
    SessionId INT NOT NULL,
    ReservationId INT NOT NULL,
    UserId INT NOT NULL,
    ScriptId INT NOT NULL,
    ScriptName NVARCHAR(100) NOT NULL,
    RoomName NVARCHAR(80) NOT NULL,
    CharacterId INT NULL,
    CharacterName NVARCHAR(50) NOT NULL,
    WasCorrect BIT NOT NULL,
    ResultTag NVARCHAR(30) NOT NULL,
    VotedCharacterId INT NULL,
    VotedCharacterName NVARCHAR(50) NULL
);

INSERT INTO @Results
(
    SessionId,
    ReservationId,
    UserId,
    ScriptId,
    ScriptName,
    RoomName,
    CharacterId,
    CharacterName,
    WasCorrect,
    ResultTag,
    VotedCharacterId,
    VotedCharacterName
)
SELECT
    reservation.SessionId,
    reservation.Id,
    reservation.UserId,
    script.Id,
    script.Name,
    room.Name,
    assignment.CharacterId,
    ISNULL(characterInfo.Name, N'未分配角色'),
    CAST(CASE WHEN vote.SuspectCharacterId IS NOT NULL AND vote.SuspectCharacterId = @CorrectCharacterId THEN 1 ELSE 0 END AS BIT),
    CASE
        WHEN vote.SuspectCharacterId IS NULL THEN N'未投票结案'
        WHEN vote.SuspectCharacterId = @CorrectCharacterId THEN N'推理成功'
        ELSE N'推理偏离'
    END,
    vote.SuspectCharacterId,
    votedCharacter.Name
FROM dbo.Reservations reservation
INNER JOIN dbo.Sessions sessionInfo ON sessionInfo.Id = reservation.SessionId
INNER JOIN dbo.Scripts script ON script.Id = sessionInfo.ScriptId
INNER JOIN dbo.Rooms room ON room.Id = sessionInfo.RoomId
INNER JOIN dbo.Users reservationUser ON reservationUser.Id = reservation.UserId
LEFT JOIN dbo.SessionCharacterAssignments assignment
    ON assignment.SessionId = reservation.SessionId
   AND assignment.ReservationId = reservation.Id
LEFT JOIN dbo.ScriptCharacters characterInfo ON characterInfo.Id = assignment.CharacterId
LEFT JOIN dbo.SessionVotes vote
    ON vote.SessionId = reservation.SessionId
   AND vote.ReservationId = reservation.Id
LEFT JOIN dbo.ScriptCharacters votedCharacter ON votedCharacter.Id = vote.SuspectCharacterId
WHERE reservation.SessionId = @SessionId
  AND reservation.UserId IS NOT NULL
  AND ISNULL(reservationUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director');

INSERT INTO dbo.PlayerBattleRecords
(
    SessionId,
    ReservationId,
    UserId,
    ScriptId,
    ScriptName,
    RoomName,
    CharacterId,
    CharacterName,
    WasCorrect,
    ResultTag,
    VotedCharacterId,
    VotedCharacterName,
    CorrectCharacterName,
    CompletedAt
)
SELECT
    result.SessionId,
    result.ReservationId,
    result.UserId,
    result.ScriptId,
    result.ScriptName,
    result.RoomName,
    result.CharacterId,
    result.CharacterName,
    result.WasCorrect,
    result.ResultTag,
    result.VotedCharacterId,
    result.VotedCharacterName,
    @CorrectCharacterName,
    ISNULL(@CompletedAt, GETDATE())
FROM @Results result
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.PlayerBattleRecords record
    WHERE record.SessionId = result.SessionId
      AND record.ReservationId = result.ReservationId
);

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
SELECT
    result.UserId,
    ISNULL([user].DisplayName, N'玩家'),
    N'沉浸式推理玩家',
    N'每次正式结算后的剧本战绩都会沉淀到我的玩家档案里。',
    ISNULL(NULLIF(profile.AvatarUrl, N''), N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80'),
    N'本格推理',
    30,
    0,
    0,
    N'新锐玩家'
FROM @Results result
INNER JOIN dbo.Users [user] ON [user].Id = result.UserId
LEFT JOIN dbo.PlayerProfiles profile ON profile.UserId = result.UserId
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.PlayerProfiles existingProfile
    WHERE existingProfile.UserId = result.UserId
)
GROUP BY result.UserId, [user].DisplayName, profile.AvatarUrl;

;WITH SessionSummary AS
(
    SELECT
        UserId,
        COUNT(1) AS CompletedCount,
        SUM(CASE WHEN WasCorrect = 1 THEN 1 ELSE 0 END) AS CorrectCount
    FROM @Results
    GROUP BY UserId
)
UPDATE profile
SET CompletedScripts = profile.CompletedScripts + summary.CompletedCount,
    WinRate = CAST
    (
        CASE
            WHEN profile.CompletedScripts + summary.CompletedCount <= 0 THEN 0
            ELSE (((profile.WinRate / 100.0) * profile.CompletedScripts) + summary.CorrectCount) * 100.0 / (profile.CompletedScripts + summary.CompletedCount)
        END AS DECIMAL(5, 2)
    ),
    ReputationLevel =
        CASE
            WHEN profile.CompletedScripts + summary.CompletedCount >= 30 THEN N'SS 级推理玩家'
            WHEN profile.CompletedScripts + summary.CompletedCount >= 18 THEN N'S 级推理玩家'
            WHEN profile.CompletedScripts + summary.CompletedCount >= 10 THEN N'A 级推理玩家'
            WHEN profile.CompletedScripts + summary.CompletedCount >= 5 THEN N'进阶推理玩家'
            ELSE N'新锐玩家'
        END
FROM dbo.PlayerProfiles profile
INNER JOIN SessionSummary summary ON summary.UserId = profile.UserId;

;WITH UsersToRefresh AS
(
    SELECT DISTINCT UserId
    FROM @Results
),
AchievementSource AS
(
    SELECT
        currentUser.UserId,
        N'入局新星' AS Title,
        N'完成首场正式结算的剧本局。' AS Description,
        N'成长' AS RarityTag,
        CASE WHEN battle.TotalCompleted >= 1 THEN 1 ELSE 0 END AS ProgressValue,
        1 AS ProgressTotal,
        1 AS SortOrder
    FROM UsersToRefresh currentUser
    CROSS APPLY
    (
        SELECT COUNT(1) AS TotalCompleted
        FROM dbo.PlayerBattleRecords record
        WHERE record.UserId = currentUser.UserId
    ) battle

    UNION ALL

    SELECT
        currentUser.UserId,
        N'真相追猎者',
        N'累计 5 场终局投票命中真凶。',
        N'稀有',
        CASE WHEN battle.CorrectCount > 5 THEN 5 ELSE battle.CorrectCount END,
        5,
        2
    FROM UsersToRefresh currentUser
    CROSS APPLY
    (
        SELECT COUNT(1) AS CorrectCount
        FROM dbo.PlayerBattleRecords record
        WHERE record.UserId = currentUser.UserId
          AND record.WasCorrect = 1
    ) battle

    UNION ALL

    SELECT
        currentUser.UserId,
        N'线索搜证家',
        N'累计解锁 20 条个人调查线索。',
        N'史诗',
        CASE WHEN clueStats.ClueCount > 20 THEN 20 ELSE clueStats.ClueCount END,
        20,
        3
    FROM UsersToRefresh currentUser
    CROSS APPLY
    (
        SELECT COUNT(1) AS ClueCount
        FROM dbo.SessionClueUnlocks unlockInfo
        INNER JOIN dbo.Reservations reservation ON reservation.Id = unlockInfo.UnlockedByReservationId
        WHERE reservation.UserId = currentUser.UserId
          AND unlockInfo.RevealedToReservationId IS NOT NULL
    ) clueStats
)
MERGE dbo.Achievements AS target
USING AchievementSource AS source
ON target.UserId = source.UserId
AND target.Title = source.Title
WHEN MATCHED THEN
    UPDATE SET
        Description = source.Description,
        RarityTag = source.RarityTag,
        ProgressValue = source.ProgressValue,
        ProgressTotal = source.ProgressTotal,
        EarnedAt =
            CASE
                WHEN source.ProgressValue >= source.ProgressTotal AND target.EarnedAt IS NULL THEN ISNULL(@CompletedAt, GETDATE())
                ELSE target.EarnedAt
            END,
        SortOrder = source.SortOrder
WHEN NOT MATCHED THEN
    INSERT(UserId, Title, Description, RarityTag, ProgressValue, ProgressTotal, EarnedAt, SortOrder)
    VALUES
    (
        source.UserId,
        source.Title,
        source.Description,
        source.RarityTag,
        source.ProgressValue,
        source.ProgressTotal,
        CASE WHEN source.ProgressValue >= source.ProgressTotal THEN ISNULL(@CompletedAt, GETDATE()) ELSE NULL END,
        source.SortOrder
    );

INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
SELECT
    @SessionId,
    NULL,
    N'Settle',
    N'本局结算完成',
    N'本场剧本已写入玩家战绩、完成数和成就进度。',
    GETDATE()
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.SessionActionLogs
    WHERE SessionId = @SessionId
      AND ActionType = N'Settle'
);

UPDATE dbo.SessionGameStates
SET SettledAt = ISNULL(SettledAt, GETDATE()),
    UpdatedAt = GETDATE()
WHERE SessionId = @SessionId;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END

    ;THROW;
END CATCH;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@SessionId", sessionId);
                connection.Open();
                command.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// DM/主持人开始游戏。
        /// 会把场次状态推进到游戏中，并写入开始日志。
        /// </summary>
        public bool StartGame(int reservationId, int operatorUserId, out string message)
        {
            const string sql = @"
DECLARE @SessionId INT;
DECLARE @OperatorName NVARCHAR(50);
DECLARE @TotalAssignments INT;
DECLARE @ReadyCount INT;
DECLARE @CurrentStageName NVARCHAR(60);

SELECT
    @SessionId = reservation.SessionId
FROM dbo.Reservations reservation
WHERE reservation.Id = @ReservationId;

SELECT @OperatorName = ISNULL(NULLIF(DisplayName, N''), Username)
FROM dbo.Users
WHERE Id = @OperatorUserId;

IF @SessionId IS NULL
BEGIN
    RAISERROR(N'未找到对应的游戏房间。', 16, 1);
    RETURN;
END

SELECT
    @TotalAssignments = COUNT(1),
    @ReadyCount = SUM(CASE WHEN IsReady = 1 THEN 1 ELSE 0 END)
FROM dbo.SessionCharacterAssignments
WHERE SessionId = @SessionId;

IF ISNULL(@TotalAssignments, 0) = 0
BEGIN
    RAISERROR(N'当前房间还没有完成角色分配，暂时不能正式开局。', 16, 1);
    RETURN;
END

IF EXISTS (SELECT 1 FROM dbo.SessionGameStates WHERE SessionId = @SessionId AND GameStartedAt IS NOT NULL)
BEGIN
    RAISERROR(N'当前房间已经正式开局，请直接推进阶段。', 16, 1);
    RETURN;
END

IF EXISTS (SELECT 1 FROM dbo.SessionGameStates WHERE SessionId = @SessionId AND GameEndedAt IS NOT NULL)
BEGIN
    RAISERROR(N'当前房间已经结算完成，不能再次开局。', 16, 1);
    RETURN;
END

IF ISNULL(@ReadyCount, 0) < @TotalAssignments
BEGIN
    RAISERROR(N'还有玩家未就位，请所有玩家准备完成后再开局。', 16, 1);
    RETURN;
END

UPDATE dbo.SessionGameStates
SET GameStartedAt = GETDATE(),
    StartedByUserId = @OperatorUserId,
    UpdatedAt = GETDATE()
WHERE SessionId = @SessionId;

SELECT @CurrentStageName = stageInfo.StageName
FROM dbo.SessionGameStates state
INNER JOIN dbo.GameStages stageInfo ON stageInfo.Id = state.CurrentStageId
WHERE state.SessionId = @SessionId;

INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
VALUES
(
    @SessionId,
    @ReservationId,
    N'Start',
    N'正式开局',
    ISNULL(@OperatorName, N'DM') + N' 已正式开启本局，当前阶段为《' + ISNULL(@CurrentStageName, N'开场导入') + N'》。',
    GETDATE()
);";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@OperatorUserId", operatorUserId);
                connection.Open();

                try
                {
                    command.ExecuteNonQuery();
                    message = "房间已正式开局，所有玩家会看到统一的阶段与线索状态。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        /// <summary>
        /// DM/主持人结束游戏。
        /// 结束后会触发结算逻辑，并让玩家看到最终真相和投票结果。
        /// </summary>
        public bool FinishGame(int reservationId, int operatorUserId, out string message)
        {
            const string sql = @"
DECLARE @SessionId INT;
DECLARE @OperatorName NVARCHAR(50);
DECLARE @CurrentStageKey NVARCHAR(30);
DECLARE @CurrentStageName NVARCHAR(60);
DECLARE @TotalAssignments INT;
DECLARE @VoteCount INT;

SELECT
    @SessionId = reservation.SessionId,
    @OperatorName = ISNULL([user].DisplayName, reservation.ContactName)
FROM dbo.Reservations reservation
LEFT JOIN dbo.Users [user] ON [user].Id = reservation.UserId
WHERE reservation.Id = @ReservationId;

IF @SessionId IS NULL
BEGIN
    RAISERROR(N'未找到对应的游戏房间。', 16, 1);
    RETURN;
END

SELECT
    @CurrentStageKey = stageInfo.StageKey,
    @CurrentStageName = stageInfo.StageName
FROM dbo.SessionGameStates state
INNER JOIN dbo.GameStages stageInfo ON stageInfo.Id = state.CurrentStageId
WHERE state.SessionId = @SessionId;

SELECT @TotalAssignments = COUNT(1)
FROM dbo.SessionCharacterAssignments
WHERE SessionId = @SessionId;

SELECT @VoteCount = COUNT(1)
FROM dbo.SessionVotes
WHERE SessionId = @SessionId;

IF EXISTS (SELECT 1 FROM dbo.SessionGameStates WHERE SessionId = @SessionId AND GameStartedAt IS NULL)
BEGIN
    RAISERROR(N'房间还没有正式开局，不能直接结算。', 16, 1);
    RETURN;
END

IF EXISTS (SELECT 1 FROM dbo.SessionGameStates WHERE SessionId = @SessionId AND GameEndedAt IS NOT NULL)
BEGIN
    RAISERROR(N'当前房间已经完成结算。', 16, 1);
    RETURN;
END

IF ISNULL(@CurrentStageKey, N'') <> N'ending'
BEGIN
    RAISERROR(N'请先把房间推进到终局复盘阶段，再执行正式结算。', 16, 1);
    RETURN;
END

IF ISNULL(@TotalAssignments, 0) = 0
BEGIN
    RAISERROR(N'当前房间没有可结算的玩家数据。', 16, 1);
    RETURN;
END

IF ISNULL(@VoteCount, 0) < @TotalAssignments
BEGIN
    RAISERROR(N'还有玩家没有提交终局投票，暂时不能完成结算。', 16, 1);
    RETURN;
END

UPDATE dbo.SessionGameStates
SET GameEndedAt = GETDATE(),
    EndedByUserId = @OperatorUserId,
    UpdatedAt = GETDATE()
WHERE SessionId = @SessionId;

UPDATE dbo.Reservations
SET Status = N'已完成',
    ProcessedAt = GETDATE()
WHERE SessionId = @SessionId
  AND Status IN (N'待确认', N'已确认', N'申请改期', N'玩家已确认', N'已到店');

INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
VALUES
(
    @SessionId,
    @ReservationId,
    N'Finish',
    N'本局结算',
    ISNULL(@OperatorName, N'DM') + N' 已在《' + ISNULL(@CurrentStageName, N'终局复盘') + N'》阶段完成本局结算。',
    GETDATE()
);";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@OperatorUserId", operatorUserId);
                connection.Open();

                try
                {
                    command.ExecuteNonQuery();
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }

            var sessionId = GetSessionIdByReservation(reservationId);
            if (sessionId.HasValue)
            {
                EnsureGameSettlement(sessionId.Value);
            }

            message = "本局已经正式结算，玩家中心里的完成数、胜率和最近战绩已同步更新。";
            return true;
        }

        /// <summary>
        /// 玩家设置准备状态。
        /// 所有玩家准备后，DM 可以更直观看到开场条件是否满足。
        /// </summary>
        public bool SetReadyState(int sessionId, int reservationId, bool isReady, out string message)
        {
            EnsureSessionGameData(sessionId);

            const string sql = @"
DECLARE @PlayerName NVARCHAR(50);

SELECT @PlayerName = ISNULL(u.DisplayName, r.ContactName)
FROM dbo.Reservations r
LEFT JOIN dbo.Users u ON u.Id = r.UserId
WHERE r.Id = @ReservationId
  AND r.SessionId = @SessionId;

IF EXISTS (SELECT 1 FROM dbo.SessionGameStates WHERE SessionId = @SessionId AND GameEndedAt IS NOT NULL)
BEGIN
    RAISERROR(N'当前房间已经完成结算，不能再修改就位状态。', 16, 1);
    RETURN;
END

IF EXISTS
(
    SELECT 1
    FROM dbo.SessionCharacterAssignments
    WHERE SessionId = @SessionId
      AND ReservationId = @ReservationId
      AND ISNULL(IsEliminated, 0) = 1
)
BEGIN
    RAISERROR(N'你已被投票出局，本局结束前只能观战，不能再修改就位状态。', 16, 1);
    RETURN;
END

UPDATE dbo.SessionCharacterAssignments
SET IsReady = @IsReady
WHERE SessionId = @SessionId
  AND ReservationId = @ReservationId;

IF @@ROWCOUNT = 0
BEGIN
    RAISERROR(N'当前玩家尚未分配角色，请先检查房间数据。', 16, 1);
    RETURN;
END

INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
VALUES
(
    @SessionId,
    @ReservationId,
    N'Ready',
    N'准备状态更新',
    ISNULL(@PlayerName, N'玩家') + CASE WHEN @IsReady = 1 THEN N' 已标记为就位。' ELSE N' 取消了就位状态。' END,
    GETDATE()
);";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@SessionId", sessionId);
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@IsReady", isReady);
                connection.Open();

                try
                {
                    command.ExecuteNonQuery();
                    message = isReady ? "已将你的角色状态标记为就位。" : "已取消就位状态。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        /// <summary>
        /// 玩家提交搜证/调查行动。
        /// 成功后可能解锁一条新线索，并返回 unlockedClueTitle 供页面提示。
        /// </summary>
        public bool SubmitInvestigation(int reservationId, string title, string content, out string unlockedClueTitle, out string message)
        {
            unlockedClueTitle = string.Empty;

            const string sql = @"
DECLARE @SessionId INT;
DECLARE @ScriptId INT;
DECLARE @CurrentStageId INT;
DECLARE @UnlockedClueId INT;
DECLARE @UnlockedClueTitle NVARCHAR(100);

SELECT @SessionId = SessionId
FROM dbo.Reservations
WHERE Id = @ReservationId;

IF @SessionId IS NULL
BEGIN
    RAISERROR(N'未找到对应的房间预约记录。', 16, 1);
    RETURN;
END

SELECT @ScriptId = ScriptId
FROM dbo.Sessions
WHERE Id = @SessionId;

SELECT @CurrentStageId = CurrentStageId
FROM dbo.SessionGameStates
WHERE SessionId = @SessionId;

IF NOT EXISTS (SELECT 1 FROM dbo.SessionGameStates WHERE SessionId = @SessionId AND GameStartedAt IS NOT NULL)
BEGIN
    RAISERROR(N'房间还没有正式开局，请等待 DM 开始本局后再提交行动。', 16, 1);
    RETURN;
END

IF EXISTS (SELECT 1 FROM dbo.SessionGameStates WHERE SessionId = @SessionId AND GameEndedAt IS NOT NULL)
BEGIN
    RAISERROR(N'当前房间已经完成结算，不能继续提交行动。', 16, 1);
    RETURN;
END

IF EXISTS
(
    SELECT 1
    FROM dbo.SessionCharacterAssignments
    WHERE SessionId = @SessionId
      AND ReservationId = @ReservationId
      AND ISNULL(IsEliminated, 0) = 1
)
BEGIN
    RAISERROR(N'你已被投票出局，本局结束前只能观战，不能继续提交行动。', 16, 1);
    RETURN;
END

IF EXISTS
(
    SELECT 1
    FROM dbo.SessionGameStates state
    INNER JOIN dbo.GameStages stageInfo ON stageInfo.Id = state.CurrentStageId
    WHERE state.SessionId = @SessionId
      AND stageInfo.StageKey = N'ending'
)
BEGIN
    RAISERROR(N'当前已经进入终局复盘阶段，请直接进行投票或查看结案信息。', 16, 1);
    RETURN;
END

INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
VALUES(@SessionId, @ReservationId, N'Investigate', @ActionTitle, @ActionContent, GETDATE());

SELECT TOP 1
    @UnlockedClueId = c.Id,
    @UnlockedClueTitle = c.Title
FROM dbo.ScriptClues c
WHERE c.ScriptId = @ScriptId
  AND (c.StageId = @CurrentStageId OR c.StageId IS NULL)
  AND c.IsPublic = 0
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.SessionClueUnlocks u
      WHERE u.SessionId = @SessionId
        AND u.ClueId = c.Id
        AND (u.RevealedToReservationId IS NULL OR u.RevealedToReservationId = @ReservationId)
  )
ORDER BY c.SortOrder ASC, c.Id ASC;

IF @UnlockedClueId IS NOT NULL
BEGIN
    INSERT INTO dbo.SessionClueUnlocks(SessionId, ClueId, RevealedToReservationId, UnlockedByReservationId, RevealMethod, RevealedAt)
    VALUES(@SessionId, @UnlockedClueId, @ReservationId, @ReservationId, N'玩家调查', GETDATE());

    INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
    VALUES
    (
        @SessionId,
        @ReservationId,
        N'Clue',
        N'获得新线索',
        N'系统根据本次调查解锁了线索《' + @UnlockedClueTitle + N'》。',
        GETDATE()
    );
END

SELECT @UnlockedClueTitle;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@ActionTitle", title);
                command.Parameters.AddWithValue("@ActionContent", content);
                connection.Open();

                try
                {
                    var result = command.ExecuteScalar();
                    unlockedClueTitle = result == null || result == DBNull.Value ? string.Empty : Convert.ToString(result);
                    message = string.IsNullOrWhiteSpace(unlockedClueTitle)
                        ? "行动记录已写入，本阶段暂时没有新的私有线索可解锁。"
                        : "行动提交成功，并解锁了新线索《" + unlockedClueTitle + "》。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        /// <summary>
        /// 将游戏推进到下一个阶段。
        /// 适合 DM 按流程顺序推进，不需要指定目标阶段。
        /// </summary>
        public bool AdvanceStage(int reservationId, out string stageName, out string message)
        {
            stageName = string.Empty;

            const string sql = @"
DECLARE @SessionId INT;
DECLARE @ScriptId INT;
DECLARE @CurrentStageId INT;
DECLARE @CurrentSortOrder INT;
DECLARE @NextStageId INT;
DECLARE @NextStageName NVARCHAR(60);
DECLARE @PlayerName NVARCHAR(50);

SELECT
    @SessionId = r.SessionId,
    @PlayerName = ISNULL(u.DisplayName, r.ContactName)
FROM dbo.Reservations r
LEFT JOIN dbo.Users u ON u.Id = r.UserId
WHERE r.Id = @ReservationId;

IF @SessionId IS NULL
BEGIN
    RAISERROR(N'未找到对应的预约房间。', 16, 1);
    RETURN;
END

SELECT @ScriptId = ScriptId
FROM dbo.Sessions
WHERE Id = @SessionId;

SELECT @CurrentStageId = CurrentStageId
FROM dbo.SessionGameStates
WHERE SessionId = @SessionId;

IF NOT EXISTS (SELECT 1 FROM dbo.SessionGameStates WHERE SessionId = @SessionId AND GameStartedAt IS NOT NULL)
BEGIN
    RAISERROR(N'房间还没有正式开局，请先让所有玩家就位并开始本局。', 16, 1);
    RETURN;
END

IF EXISTS (SELECT 1 FROM dbo.SessionGameStates WHERE SessionId = @SessionId AND GameEndedAt IS NOT NULL)
BEGIN
    RAISERROR(N'当前房间已经完成结算，不能再推进阶段。', 16, 1);
    RETURN;
END

SELECT @CurrentSortOrder = SortOrder
FROM dbo.GameStages
WHERE Id = @CurrentStageId;

SELECT TOP 1
    @NextStageId = Id,
    @NextStageName = StageName
FROM dbo.GameStages
WHERE SortOrder > @CurrentSortOrder
ORDER BY SortOrder ASC, Id ASC;

IF @NextStageId IS NULL
BEGIN
    RAISERROR(N'当前已经是最终阶段，无法继续推进。', 16, 1);
    RETURN;
END

UPDATE dbo.SessionGameStates
SET CurrentStageId = @NextStageId,
    UpdatedAt = GETDATE()
WHERE SessionId = @SessionId;

INSERT INTO dbo.SessionClueUnlocks(SessionId, ClueId, RevealedToReservationId, UnlockedByReservationId, RevealMethod, RevealedAt)
SELECT
    @SessionId,
    c.Id,
    NULL,
    @ReservationId,
    N'阶段推进',
    GETDATE()
FROM dbo.ScriptClues c
WHERE c.ScriptId = @ScriptId
  AND c.StageId = @NextStageId
  AND c.IsPublic = 1
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.SessionClueUnlocks u
      WHERE u.SessionId = @SessionId
        AND u.ClueId = c.Id
        AND u.RevealedToReservationId IS NULL
  );

INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
VALUES
(
    @SessionId,
    @ReservationId,
    N'Stage',
    N'阶段推进',
    ISNULL(@PlayerName, N'玩家') + N' 已将剧情推进到《' + @NextStageName + N'》。',
    GETDATE()
);

SELECT @NextStageName;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                connection.Open();

                try
                {
                    var result = command.ExecuteScalar();
                    stageName = result == null || result == DBNull.Value ? string.Empty : Convert.ToString(result);
                    message = string.IsNullOrWhiteSpace(stageName)
                        ? "阶段已推进。"
                        : "剧情已推进到《" + stageName + "》。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        /// <summary>
        /// 将游戏直接切换到指定阶段。
        /// 适合 DM 手动纠正流程或跳过阶段。
        /// </summary>
        public bool SetStage(int reservationId, int targetStageId, out string stageName, out string message)
        {
            stageName = string.Empty;

            const string sql = @"
DECLARE @SessionId INT;
DECLARE @ScriptId INT;
DECLARE @CurrentStageId INT;
DECLARE @TargetStageName NVARCHAR(60);
DECLARE @PlayerName NVARCHAR(50);

SELECT
    @SessionId = r.SessionId,
    @PlayerName = ISNULL(u.DisplayName, r.ContactName)
FROM dbo.Reservations r
LEFT JOIN dbo.Users u ON u.Id = r.UserId
WHERE r.Id = @ReservationId;

IF @SessionId IS NULL
BEGIN
    RAISERROR(N'未找到对应的预约房间。', 16, 1);
    RETURN;
END

SELECT @ScriptId = ScriptId
FROM dbo.Sessions
WHERE Id = @SessionId;

SELECT @CurrentStageId = CurrentStageId
FROM dbo.SessionGameStates
WHERE SessionId = @SessionId;

IF NOT EXISTS (SELECT 1 FROM dbo.SessionGameStates WHERE SessionId = @SessionId AND GameStartedAt IS NOT NULL)
BEGIN
    RAISERROR(N'房间还没有正式开局，不能直接切换阶段。', 16, 1);
    RETURN;
END

IF EXISTS (SELECT 1 FROM dbo.SessionGameStates WHERE SessionId = @SessionId AND GameEndedAt IS NOT NULL)
BEGIN
    RAISERROR(N'当前房间已经完成结算，不能再切换阶段。', 16, 1);
    RETURN;
END

SELECT @TargetStageName = StageName
FROM dbo.GameStages
WHERE Id = @TargetStageId;

IF @TargetStageName IS NULL
BEGIN
    RAISERROR(N'目标阶段不存在，请重新选择。', 16, 1);
    RETURN;
END

IF @CurrentStageId = @TargetStageId
BEGIN
    RAISERROR(N'当前已经处于这个阶段。', 16, 1);
    RETURN;
END

UPDATE dbo.SessionGameStates
SET CurrentStageId = @TargetStageId,
    UpdatedAt = GETDATE()
WHERE SessionId = @SessionId;

INSERT INTO dbo.SessionClueUnlocks(SessionId, ClueId, RevealedToReservationId, UnlockedByReservationId, RevealMethod, RevealedAt)
SELECT
    @SessionId,
    c.Id,
    NULL,
    @ReservationId,
    N'DM切换阶段',
    GETDATE()
FROM dbo.ScriptClues c
WHERE c.ScriptId = @ScriptId
  AND c.StageId = @TargetStageId
  AND c.IsPublic = 1
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.SessionClueUnlocks u
      WHERE u.SessionId = @SessionId
        AND u.ClueId = c.Id
        AND u.RevealedToReservationId IS NULL
  );

INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
VALUES
(
    @SessionId,
    @ReservationId,
    N'Stage',
    N'DM指定阶段',
    ISNULL(@PlayerName, N'主持人') + N' 已将房间切换到《' + @TargetStageName + N'》。',
    GETDATE()
);

SELECT @TargetStageName;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@TargetStageId", targetStageId);
                connection.Open();

                try
                {
                    var result = command.ExecuteScalar();
                    stageName = result == null || result == DBNull.Value ? string.Empty : Convert.ToString(result);
                    message = string.IsNullOrWhiteSpace(stageName)
                        ? "阶段已切换。"
                        : "房间已切换到《" + stageName + "》。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        /// <summary>
        /// 玩家提交指认投票。
        /// 同一玩家同一场次只保留当前投票结果。
        /// </summary>
        public bool SubmitVote(int reservationId, int suspectCharacterId, string voteComment, out string message)
        {
            var sessionId = GetSessionIdByReservation(reservationId);
            if (sessionId.HasValue)
            {
                EnsureSessionGameData(sessionId.Value);
            }

            const string sql = @"
DECLARE @SessionId INT;
DECLARE @CurrentStageKey NVARCHAR(30);
DECLARE @PlayerName NVARCHAR(50);
DECLARE @PlayerUserId INT;
DECLARE @CharacterName NVARCHAR(50);
DECLARE @CurrentPlayerEliminated BIT = 0;
DECLARE @TotalActiveVotesNeeded INT;
DECLARE @CurrentVoteCount INT;
DECLARE @TopVoteCount INT;
DECLARE @TopCharacterId INT;
DECLARE @TopCharacterName NVARCHAR(50);
DECLARE @TopReservationId INT;
DECLARE @TopPlayerName NVARCHAR(50);
DECLARE @TieCount INT;
DECLARE @CorrectCharacterId INT;

SELECT
    @SessionId = r.SessionId,
    @PlayerName = ISNULL(u.DisplayName, r.ContactName),
    @PlayerUserId = r.UserId
FROM dbo.Reservations r
LEFT JOIN dbo.Users u ON u.Id = r.UserId
WHERE r.Id = @ReservationId;

IF @SessionId IS NULL
BEGIN
    RAISERROR(N'未找到对应的房间预约。', 16, 1);
    RETURN;
END

SELECT @CurrentStageKey = gs.StageKey
FROM dbo.SessionGameStates sgs
INNER JOIN dbo.GameStages gs ON gs.Id = sgs.CurrentStageId
WHERE sgs.SessionId = @SessionId;

IF EXISTS (SELECT 1 FROM dbo.SessionGameStates WHERE SessionId = @SessionId AND GameStartedAt IS NULL)
BEGIN
    RAISERROR(N'房间还没有正式开局，请等待 DM 开始本局后再投票。', 16, 1);
    RETURN;
END

IF EXISTS (SELECT 1 FROM dbo.SessionGameStates WHERE SessionId = @SessionId AND GameEndedAt IS NOT NULL)
BEGIN
    RAISERROR(N'当前房间已经完成结算，不能重复提交终局投票。', 16, 1);
    RETURN;
END

IF ISNULL(@CurrentStageKey, N'') <> N'ending'
BEGIN
    RAISERROR(N'当前还未进入终局投票阶段，请先推进到结案复盘。', 16, 1);
    RETURN;
END

SELECT @CurrentPlayerEliminated = ISNULL(a.IsEliminated, 0)
FROM dbo.SessionCharacterAssignments a
WHERE a.SessionId = @SessionId
  AND a.ReservationId = @ReservationId;

IF ISNULL(@CurrentPlayerEliminated, 0) = 1
BEGIN
    RAISERROR(N'你已被投票出局，本局结束前只能观战，不能继续投票。', 16, 1);
    RETURN;
END

SELECT @CharacterName = sc.Name
FROM dbo.SessionCharacterAssignments a
INNER JOIN dbo.ScriptCharacters sc ON sc.Id = a.CharacterId
WHERE a.SessionId = @SessionId
  AND a.CharacterId = @SuspectCharacterId
  AND ISNULL(a.IsEliminated, 0) = 0;

IF @CharacterName IS NULL
BEGIN
    RAISERROR(N'投票目标无效或已经出局，请从当前仍在局内的角色中重新选择。', 16, 1);
    RETURN;
END

IF EXISTS (SELECT 1 FROM dbo.SessionVotes WHERE SessionId = @SessionId AND ReservationId = @ReservationId)
BEGIN
    UPDATE dbo.SessionVotes
    SET SuspectCharacterId = @SuspectCharacterId,
        VoteComment = NULLIF(@VoteComment, N''),
        CreatedAt = GETDATE()
    WHERE SessionId = @SessionId
      AND ReservationId = @ReservationId;
END
ELSE
BEGIN
    INSERT INTO dbo.SessionVotes(SessionId, ReservationId, SuspectCharacterId, VoteComment, CreatedAt)
    VALUES(@SessionId, @ReservationId, @SuspectCharacterId, NULLIF(@VoteComment, N''), GETDATE());
END

INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
VALUES(@SessionId, @ReservationId, N'Vote', N'提交终局投票', ISNULL(@PlayerName, N'玩家') + N' 将终局票投给了《' + @CharacterName + N'》。', GETDATE());

SELECT @TotalActiveVotesNeeded = ISNULL(SUM(r.PlayerCount), 0)
FROM dbo.SessionCharacterAssignments a
INNER JOIN dbo.Reservations r ON r.Id = a.ReservationId
INNER JOIN dbo.Users reservationUser ON reservationUser.Id = r.UserId
WHERE a.SessionId = @SessionId
  AND ISNULL(a.IsEliminated, 0) = 0
  AND r.UserId IS NOT NULL
  AND ISNULL(reservationUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')
  AND r.Status IN (N'待确认', N'已确认', N'玩家已确认', N'已到店');

SELECT @CurrentVoteCount = ISNULL(SUM(r.PlayerCount), 0)
FROM dbo.SessionVotes v
INNER JOIN dbo.SessionCharacterAssignments a ON a.SessionId = v.SessionId AND a.ReservationId = v.ReservationId
INNER JOIN dbo.Reservations r ON r.Id = v.ReservationId
INNER JOIN dbo.Users reservationUser ON reservationUser.Id = r.UserId
WHERE v.SessionId = @SessionId
  AND ISNULL(a.IsEliminated, 0) = 0
  AND r.UserId IS NOT NULL
  AND ISNULL(reservationUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')
  AND r.Status IN (N'待确认', N'已确认', N'玩家已确认', N'已到店');

IF @TotalActiveVotesNeeded > 0 AND @CurrentVoteCount >= @TotalActiveVotesNeeded
BEGIN
    DECLARE @VoteScores TABLE(CharacterId INT NOT NULL, VoteWeight INT NOT NULL);

    INSERT INTO @VoteScores(CharacterId, VoteWeight)
    SELECT v.SuspectCharacterId, ISNULL(SUM(r.PlayerCount), 0)
    FROM dbo.SessionVotes v
    INNER JOIN dbo.SessionCharacterAssignments a ON a.SessionId = v.SessionId AND a.ReservationId = v.ReservationId
    INNER JOIN dbo.Reservations r ON r.Id = v.ReservationId
    INNER JOIN dbo.Users reservationUser ON reservationUser.Id = r.UserId
    WHERE v.SessionId = @SessionId
      AND ISNULL(a.IsEliminated, 0) = 0
      AND r.UserId IS NOT NULL
      AND ISNULL(reservationUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')
      AND r.Status IN (N'待确认', N'已确认', N'玩家已确认', N'已到店')
    GROUP BY v.SuspectCharacterId;

    SELECT @TopVoteCount = MAX(VoteWeight) FROM @VoteScores;
    SELECT @TieCount = COUNT(1) FROM @VoteScores WHERE VoteWeight = @TopVoteCount;

    IF @TieCount > 1
    BEGIN
        SET @ResultMessage = N'终局投票已收齐，但最高票出现平票，暂不出局。玩家可以继续改票后重新结算。';
        INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
        VALUES(@SessionId, NULL, N'VoteTie', N'投票平票', N'本轮最高票出现平票，暂不产生出局玩家。', GETDATE());
    END
    ELSE
    BEGIN
        SELECT TOP 1 @TopCharacterId = CharacterId FROM @VoteScores ORDER BY VoteWeight DESC, CharacterId ASC;

        SELECT @TopCharacterName = sc.Name, @TopReservationId = a.ReservationId, @TopPlayerName = ISNULL(u.DisplayName, r.ContactName)
        FROM dbo.SessionCharacterAssignments a
        INNER JOIN dbo.ScriptCharacters sc ON sc.Id = a.CharacterId
        INNER JOIN dbo.Reservations r ON r.Id = a.ReservationId
        LEFT JOIN dbo.Users u ON u.Id = r.UserId
        WHERE a.SessionId = @SessionId AND a.CharacterId = @TopCharacterId;

        SELECT @CorrectCharacterId = killerCharacter.Id
        FROM dbo.SessionGameStates state
        INNER JOIN dbo.Sessions sessionInfo ON sessionInfo.Id = state.SessionId
        INNER JOIN dbo.Scripts script ON script.Id = sessionInfo.ScriptId
        LEFT JOIN dbo.ScriptCharacters killerCharacter
            ON killerCharacter.ScriptId = script.Id
           AND killerCharacter.Name = ISNULL(NULLIF(state.CaseKillerCharacterName, N''), ISNULL(script.KillerCharacterName, N''))
        WHERE state.SessionId = @SessionId;

        IF @CorrectCharacterId IS NOT NULL AND @TopCharacterId = @CorrectCharacterId
        BEGIN
            UPDATE dbo.SessionCharacterAssignments
            SET IsEliminated = 1, EliminatedAt = GETDATE()
            WHERE SessionId = @SessionId AND CharacterId = @TopCharacterId AND ISNULL(IsEliminated, 0) = 0;

            UPDATE dbo.SessionGameStates
            SET GameEndedAt = ISNULL(GameEndedAt, GETDATE()),
                EndedByUserId = @PlayerUserId,
                UpdatedAt = GETDATE()
            WHERE SessionId = @SessionId;

            INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
            VALUES(@SessionId, @TopReservationId, N'VoteResult', N'真凶出局', N'全员投票完成，《' + ISNULL(@TopCharacterName, N'未知角色') + N'》被投出局，命中真凶，游戏自动结束并开放复盘讨论。', GETDATE());

            SET @ResultMessage = N'全员投票完成，真凶《' + ISNULL(@TopCharacterName, N'未知角色') + N'》已出局，游戏自动结束，复盘讨论已开放。';
        END
        ELSE
        BEGIN
            UPDATE dbo.SessionCharacterAssignments
            SET IsEliminated = 1, EliminatedAt = GETDATE()
            WHERE SessionId = @SessionId AND CharacterId = @TopCharacterId AND ISNULL(IsEliminated, 0) = 0;

            DELETE FROM dbo.SessionVotes WHERE SessionId = @SessionId;

            INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
            VALUES(@SessionId, @TopReservationId, N'VoteResult', N'玩家出局', N'全员投票完成，《' + ISNULL(@TopCharacterName, N'未知角色') + N'》被投出局；该玩家进入观战，本局结束前不能继续发言、行动或投票。', GETDATE());

            SET @ResultMessage = N'全员投票完成，《' + ISNULL(@TopCharacterName, N'未知角色') + N'》被投出局。若你是该玩家，将进入观战状态；下一轮投票已重置。';
        END
    END
END
ELSE
BEGIN
    SET @ResultMessage = N'终局投票已提交，房间会同步显示最新票型。';
END";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@SuspectCharacterId", suspectCharacterId);
                command.Parameters.AddWithValue("@VoteComment", voteComment ?? string.Empty);
                var resultMessage = command.Parameters.Add("@ResultMessage", SqlDbType.NVarChar, 300);
                resultMessage.Direction = ParameterDirection.Output;
                connection.Open();

                try
                {
                    command.ExecuteNonQuery();
                    message = Convert.ToString(resultMessage.Value);
                    if (string.IsNullOrWhiteSpace(message))
                    {
                        message = "终局投票已提交，房间会同步显示最新票型。";
                    }
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        /// <summary>
        /// DM 向全房间广播公告。
        /// </summary>
        public bool BroadcastNotice(int reservationId, string content, out string message)
        {
            const string sql = @"
DECLARE @SessionId INT;
DECLARE @OperatorName NVARCHAR(50);

SELECT
    @SessionId = r.SessionId,
    @OperatorName = ISNULL(u.DisplayName, r.ContactName)
FROM dbo.Reservations r
LEFT JOIN dbo.Users u ON u.Id = r.UserId
WHERE r.Id = @ReservationId;

IF @SessionId IS NULL
BEGIN
    RAISERROR(N'未找到对应的房间预约。', 16, 1);
    RETURN;
END

INSERT INTO dbo.RoomMessages(SessionId, ReservationId, UserId, SenderName, MessageType, Content, MediaData, DurationSeconds, SentAt)
SELECT
    @SessionId,
    @ReservationId,
    r.UserId,
    N'DM主持人',
    N'Text',
    @Content,
    NULL,
    NULL,
    GETDATE()
FROM dbo.Reservations r
WHERE r.Id = @ReservationId;

INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
VALUES
(
    @SessionId,
    @ReservationId,
    N'Broadcast',
    N'主持人公告',
    ISNULL(@OperatorName, N'DM主持人') + N' 发布了房间公告：' + @Content,
    GETDATE()
);";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@Content", content);
                connection.Open();

                try
                {
                    command.ExecuteNonQuery();
                    message = "主持人公告已同步到房间。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        /// <summary>
        /// DM 设置案件真相。
        /// 包括正确角色和结算时展示的真相说明。
        /// </summary>
        public bool SetCaseTruth(int reservationId, int characterId, string truthSummary, int operatorUserId, out string message)
        {
            const string sql = @"
DECLARE @SessionId INT;
DECLARE @ScriptId INT;
DECLARE @CharacterName NVARCHAR(50);
DECLARE @OperatorName NVARCHAR(50);

SELECT
    @SessionId = r.SessionId,
    @ScriptId = s.ScriptId
FROM dbo.Reservations r
INNER JOIN dbo.Sessions s ON s.Id = r.SessionId
WHERE r.Id = @ReservationId;

IF @SessionId IS NULL
BEGIN
    RAISERROR(N'未找到对应的房间预约。', 16, 1);
    RETURN;
END

SELECT @CharacterName = Name
FROM dbo.ScriptCharacters
WHERE Id = @CharacterId
  AND ScriptId = @ScriptId;

IF @CharacterName IS NULL
BEGIN
    RAISERROR(N'真凶角色不属于当前剧本，请重新选择。', 16, 1);
    RETURN;
END

SELECT @OperatorName = ISNULL(DisplayName, Username)
FROM dbo.Users
WHERE Id = @OperatorUserId;

UPDATE dbo.SessionGameStates
SET CaseKillerCharacterId = @CharacterId,
    CaseKillerCharacterName = @CharacterName,
    CaseTruthSummary = @TruthSummary,
    UpdatedAt = GETDATE()
WHERE SessionId = @SessionId;

INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
VALUES
(
    @SessionId,
    @ReservationId,
    N'Truth',
    N'结案真相已设置',
    ISNULL(@OperatorName, N'DM主持人') + N' 将本局真凶设置为《' + @CharacterName + N'》。',
    GETDATE()
);";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@CharacterId", characterId);
                command.Parameters.AddWithValue("@TruthSummary", truthSummary ?? string.Empty);
                command.Parameters.AddWithValue("@OperatorUserId", operatorUserId);
                connection.Open();

                try
                {
                    command.ExecuteNonQuery();
                    message = "结案真相已保存，终局后会展示在结案页。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        /// <summary>
        /// 保存 DM 内部场控笔记。
        /// </summary>
        public bool SaveDmNotes(int reservationId, string notes, int operatorUserId, out string message)
        {
            const string sql = @"
DECLARE @SessionId INT;

SELECT @SessionId = SessionId
FROM dbo.Reservations
WHERE Id = @ReservationId;

IF @SessionId IS NULL
BEGIN
    RAISERROR(N'未找到对应的房间预约。', 16, 1);
    RETURN;
END

UPDATE dbo.SessionGameStates
SET DmNotes = NULLIF(@Notes, N''),
    UpdatedAt = GETDATE()
WHERE SessionId = @SessionId;

INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
VALUES(@SessionId, @ReservationId, N'DmNote', N'DM备注已更新', N'DM 更新了本局私有控场备注。', GETDATE());";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@Notes", notes ?? string.Empty);
                command.Parameters.AddWithValue("@OperatorUserId", operatorUserId);
                connection.Open();

                try
                {
                    command.ExecuteNonQuery();
                    message = "DM 备注已保存。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        /// <summary>
        /// 启动当前阶段倒计时。
        /// 页面可以据此展示剩余时间和阶段结束提示。
        /// </summary>
        public bool StartStageTimer(int reservationId, int durationMinutes, int operatorUserId, out string message)
        {
            const string sql = @"
DECLARE @SessionId INT;

SELECT @SessionId = SessionId
FROM dbo.Reservations
WHERE Id = @ReservationId;

IF @SessionId IS NULL
BEGIN
    RAISERROR(N'未找到对应的房间预约。', 16, 1);
    RETURN;
END

IF @DurationMinutes < 1 OR @DurationMinutes > 240
BEGIN
    RAISERROR(N'阶段计时请设置为 1 到 240 分钟。', 16, 1);
    RETURN;
END

UPDATE dbo.SessionGameStates
SET StageTimerStartedAt = GETDATE(),
    StageTimerDurationMinutes = @DurationMinutes,
    UpdatedAt = GETDATE()
WHERE SessionId = @SessionId;

INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
VALUES(@SessionId, @ReservationId, N'Timer', N'DM开启阶段计时', N'DM 开启了 ' + CAST(@DurationMinutes AS NVARCHAR(10)) + N' 分钟阶段计时。', GETDATE());";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@DurationMinutes", durationMinutes);
                command.Parameters.AddWithValue("@OperatorUserId", operatorUserId);
                connection.Open();

                try
                {
                    command.ExecuteNonQuery();
                    message = "阶段计时已开始。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        /// <summary>
        /// DM 手动发放一条线索。
        /// targetReservationId 为空时代表全员可见，否则只发给指定玩家。
        /// </summary>
        public bool RevealClueByDm(int reservationId, int clueId, int? targetReservationId, out string message)
        {
            const string sql = @"
DECLARE @SessionId INT;
DECLARE @ScriptId INT;
DECLARE @ClueTitle NVARCHAR(100);
DECLARE @RevealMethod NVARCHAR(30) = N'DM发放线索';
DECLARE @TargetName NVARCHAR(50);
DECLARE @IsPublic BIT;
DECLARE @OperatorName NVARCHAR(50);
DECLARE @AssetId INT;
DECLARE @AssetTitle NVARCHAR(100);
DECLARE @AssetSummary NVARCHAR(200);
DECLARE @AssetDetail NVARCHAR(500);
DECLARE @AssetClueType NVARCHAR(30);

SELECT
    @SessionId = r.SessionId,
    @OperatorName = ISNULL(u.DisplayName, r.ContactName)
FROM dbo.Reservations r
LEFT JOIN dbo.Users u ON u.Id = r.UserId
WHERE r.Id = @ReservationId;

IF @SessionId IS NULL
BEGIN
    RAISERROR(N'未找到对应的房间预约。', 16, 1);
    RETURN;
END

SELECT @ScriptId = ScriptId
FROM dbo.Sessions
WHERE Id = @SessionId;

IF NOT EXISTS (SELECT 1 FROM dbo.SessionGameStates WHERE SessionId = @SessionId AND GameStartedAt IS NOT NULL)
BEGIN
    RAISERROR(N'房间还没有正式开局，暂时不能发放线索。', 16, 1);
    RETURN;
END

IF EXISTS (SELECT 1 FROM dbo.SessionGameStates WHERE SessionId = @SessionId AND GameEndedAt IS NOT NULL)
BEGIN
    RAISERROR(N'当前房间已经完成结算，不能继续发放线索。', 16, 1);
    RETURN;
END

IF @ClueId < 0
BEGIN
    RAISERROR(N'请选择当前剧本线索库中的线索。', 16, 1);
    RETURN;
END

SELECT
    @ClueTitle = c.Title,
    @IsPublic = c.IsPublic
FROM dbo.ScriptClues c
WHERE c.Id = @ClueId
  AND c.ScriptId = @ScriptId;

IF @ClueTitle IS NULL
BEGIN
    RAISERROR(N'未找到对应线索，或线索不属于当前剧本。', 16, 1);
    RETURN;
END

IF @IsPublic = 1
BEGIN
    IF EXISTS
    (
        SELECT 1
        FROM dbo.SessionClueUnlocks
        WHERE SessionId = @SessionId
          AND ClueId = @ClueId
          AND RevealedToReservationId IS NULL
    )
    BEGIN
        INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
        VALUES(@SessionId, @ReservationId, N'Clue', N'DM再次推送公共线索', ISNULL(@OperatorName, N'DM主持人') + N' 再次向全房推送了线索《' + @ClueTitle + N'》。', GETDATE());
        RETURN;
    END

    INSERT INTO dbo.SessionClueUnlocks(SessionId, ClueId, RevealedToReservationId, UnlockedByReservationId, RevealMethod, RevealedAt)
    VALUES(@SessionId, @ClueId, NULL, @ReservationId, @RevealMethod, GETDATE());

    INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
    VALUES(@SessionId, @ReservationId, N'Clue', N'DM发放公共线索', ISNULL(@OperatorName, N'DM主持人') + N' 向全房发放了线索《' + @ClueTitle + N'》。', GETDATE());

    RETURN;
END

IF @TargetReservationId IS NULL
BEGIN
    RAISERROR(N'这条线索属于私密线索，请选择目标玩家。', 16, 1);
    RETURN;
END

SELECT @TargetName = ISNULL(u.DisplayName, r.ContactName)
FROM dbo.Reservations r
LEFT JOIN dbo.Users u ON u.Id = r.UserId
WHERE r.Id = @TargetReservationId
  AND r.SessionId = @SessionId;

IF @TargetName IS NULL
BEGIN
    RAISERROR(N'目标玩家不在当前房间中。', 16, 1);
    RETURN;
END

IF EXISTS
(
    SELECT 1
    FROM dbo.SessionClueUnlocks
    WHERE SessionId = @SessionId
      AND ClueId = @ClueId
      AND RevealedToReservationId = @TargetReservationId
)
BEGIN
    INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
    VALUES(@SessionId, @ReservationId, N'Clue', N'DM再次推送私密线索', ISNULL(@OperatorName, N'DM主持人') + N' 再次向' + @TargetName + N' 推送了线索《' + @ClueTitle + N'》。', GETDATE());
    RETURN;
END

INSERT INTO dbo.SessionClueUnlocks(SessionId, ClueId, RevealedToReservationId, UnlockedByReservationId, RevealMethod, RevealedAt)
VALUES(@SessionId, @ClueId, @TargetReservationId, @ReservationId, @RevealMethod, GETDATE());

INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
VALUES(@SessionId, @ReservationId, N'Clue', N'DM发放私密线索', ISNULL(@OperatorName, N'DM主持人') + N' 向' + @TargetName + N' 发放了线索《' + @ClueTitle + N'》。', GETDATE());";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@ClueId", clueId);
                command.Parameters.AddWithValue("@TargetReservationId", (object)targetReservationId ?? DBNull.Value);
                connection.Open();

                try
                {
                    command.ExecuteNonQuery();
                    message = "线索已发放并同步到房间；公共线索所有玩家可见，私密线索仅指定玩家可见。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        /// <summary>
        /// 获取当前阶段；不存在时使用阶段排序中的第一条。
        /// </summary>
        private GameStageInfo GetCurrentStage(int sessionId)
        {
            const string sql = @"
SELECT TOP 1
    gs.Id,
    gs.StageKey,
    gs.StageName,
    gs.StageDescription,
    gs.SortOrder,
    gs.DurationMinutes,
    sgs.UpdatedAt
FROM dbo.SessionGameStates sgs
INNER JOIN dbo.GameStages gs ON gs.Id = sgs.CurrentStageId
WHERE sgs.SessionId = @SessionId;";

            var stages = ExecuteList(sql, command => command.Parameters.AddWithValue("@SessionId", sessionId), reader => new GameStageInfo
            {
                Id = GetInt32(reader, "Id"),
                StageKey = GetString(reader, "StageKey"),
                StageName = GetString(reader, "StageName"),
                StageDescription = GetString(reader, "StageDescription"),
                SortOrder = GetInt32(reader, "SortOrder"),
                DurationMinutes = GetInt32(reader, "DurationMinutes"),
                StatusText = "进行中",
                IsCurrent = true,
                UpdatedAt = GetNullableDateTime(reader, "UpdatedAt")
            });

            return stages.Count > 0 ? stages[0] : null;
        }

        /// <summary>
        /// 获取完整阶段时间线。
        /// </summary>
        private IList<GameStageInfo> GetStageTimeline(int sessionId)
        {
            const string sql = @"
SELECT
    gs.Id,
    gs.StageKey,
    gs.StageName,
    gs.StageDescription,
    gs.SortOrder,
    gs.DurationMinutes,
    CASE
        WHEN gs.Id = currentStage.Id THEN N'进行中'
        WHEN gs.SortOrder < currentStage.SortOrder THEN N'已完成'
        ELSE N'待开始'
    END AS StatusText,
    CAST(CASE WHEN gs.Id = currentStage.Id THEN 1 ELSE 0 END AS BIT) AS IsCurrent,
    sgs.UpdatedAt
FROM dbo.GameStages gs
INNER JOIN dbo.SessionGameStates sgs ON sgs.SessionId = @SessionId
INNER JOIN dbo.GameStages currentStage ON currentStage.Id = sgs.CurrentStageId
ORDER BY gs.SortOrder ASC, gs.Id ASC;";

            return ExecuteList(sql, command => command.Parameters.AddWithValue("@SessionId", sessionId), reader => new GameStageInfo
            {
                Id = GetInt32(reader, "Id"),
                StageKey = GetString(reader, "StageKey"),
                StageName = GetString(reader, "StageName"),
                StageDescription = GetString(reader, "StageDescription"),
                SortOrder = GetInt32(reader, "SortOrder"),
                DurationMinutes = GetInt32(reader, "DurationMinutes"),
                StatusText = GetString(reader, "StatusText"),
                IsCurrent = GetBoolean(reader, "IsCurrent"),
                UpdatedAt = GetNullableDateTime(reader, "UpdatedAt")
            });
        }

        /// <summary>
        /// 获取本场所有角色分配。
        /// </summary>
        private IList<GameAssignmentInfo> GetAssignments(int sessionId)
        {
            const string sql = @"
SELECT
    a.ReservationId,
    r.UserId,
    ISNULL(u.DisplayName, r.ContactName) AS PlayerName,
    r.ContactName,
    r.PlayerCount,
    sc.Id AS CharacterId,
    sc.Name AS CharacterName,
    sc.Gender,
    sc.AgeRange,
    sc.Profession,
    sc.Personality,
    sc.Description,
    sc.SecretLine,
    a.IsReady,
    ISNULL(a.IsEliminated, 0) AS IsEliminated,
    a.EliminatedAt
FROM dbo.SessionCharacterAssignments a
INNER JOIN dbo.Reservations r ON r.Id = a.ReservationId
LEFT JOIN dbo.Users u ON u.Id = r.UserId
INNER JOIN dbo.ScriptCharacters sc ON sc.Id = a.CharacterId
WHERE a.SessionId = @SessionId
  AND r.UserId IS NOT NULL
  AND ISNULL(u.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')
  AND r.Status IN (N'待确认', N'已确认', N'玩家已确认', N'已到店')
ORDER BY a.ReservationId ASC;";

            return ExecuteList(sql, command => command.Parameters.AddWithValue("@SessionId", sessionId), reader => new GameAssignmentInfo
            {
                ReservationId = GetInt32(reader, "ReservationId"),
                UserId = GetNullableInt32(reader, "UserId"),
                PlayerName = GetString(reader, "PlayerName"),
                ContactName = GetString(reader, "ContactName"),
                PlayerCount = GetInt32(reader, "PlayerCount"),
                CharacterId = GetInt32(reader, "CharacterId"),
                CharacterName = GetString(reader, "CharacterName"),
                Gender = GetString(reader, "Gender"),
                AgeRange = GetString(reader, "AgeRange"),
                Profession = GetString(reader, "Profession"),
                Personality = GetString(reader, "Personality"),
                CharacterDescription = GetString(reader, "Description"),
                SecretLine = GetString(reader, "SecretLine"),
                IsReady = GetBoolean(reader, "IsReady"),
                IsEliminated = GetBoolean(reader, "IsEliminated"),
                EliminatedAt = GetNullableDateTime(reader, "EliminatedAt")
            });
        }

        /// <summary>
        /// 获取当前玩家可见线索，包括公共线索和定向发放给该玩家的线索。
        /// </summary>
        private IList<GameClueInfo> GetVisibleClues(int sessionId, int reservationId)
        {
            const string sql = @"
SELECT
    c.Id,
    ISNULL(gs.StageName, N'鑷敱闃舵') AS StageName,
    c.Title,
    c.Summary,
    c.Detail,
    c.ClueType,
    ISNULL(asset.AssetType, N'clue') AS AssetType,
    ISNULL(asset.PublicUrl, N'') AS AssetUrl,
    ISNULL(asset.FileName, N'') AS FileName,
    ISNULL(asset.FileExtension, N'') AS FileExtension,
    c.IsPublic,
    c.SortOrder,
    u.RevealMethod,
    u.RevealedAt,
    ISNULL(unlockUser.DisplayName, unlockReservation.ContactName) AS UnlockedByName
FROM dbo.SessionClueUnlocks u
INNER JOIN dbo.ScriptClues c ON c.Id = u.ClueId
LEFT JOIN dbo.GameStages gs ON gs.Id = c.StageId
OUTER APPLY
(
    SELECT TOP 1 a.AssetType, a.PublicUrl, a.FileName, a.FileExtension
    FROM dbo.ScriptAssets a
    WHERE a.ScriptId = c.ScriptId
      AND
      (
          c.Detail LIKE N'%' + a.RelativePath + N'%'
          OR c.Detail LIKE N'%' + a.FileName + N'%'
          OR c.Title = a.Title
      )
    ORDER BY a.IsPrimary DESC, a.SortOrder ASC, a.Id ASC
) asset
LEFT JOIN dbo.Reservations unlockReservation ON unlockReservation.Id = u.UnlockedByReservationId
LEFT JOIN dbo.Users unlockUser ON unlockUser.Id = unlockReservation.UserId
WHERE u.SessionId = @SessionId
  AND (u.RevealedToReservationId IS NULL OR u.RevealedToReservationId = @ReservationId)
ORDER BY ISNULL(gs.SortOrder, 999), c.SortOrder, u.Id;";

            return ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@SessionId", sessionId);
                command.Parameters.AddWithValue("@ReservationId", reservationId);
            }, reader => new GameClueInfo
            {
                Id = GetInt32(reader, "Id"),
                StageName = GetString(reader, "StageName"),
                Title = GetString(reader, "Title"),
                Summary = GetString(reader, "Summary"),
                Detail = GetString(reader, "Detail"),
                ClueType = GetString(reader, "ClueType"),
                AssetType = GetString(reader, "AssetType"),
                AssetUrl = GetString(reader, "AssetUrl"),
                FileName = GetString(reader, "FileName"),
                FileExtension = GetString(reader, "FileExtension"),
                IsPublic = GetBoolean(reader, "IsPublic"),
                SortOrder = GetInt32(reader, "SortOrder"),
                RevealMethod = GetString(reader, "RevealMethod"),
                RevealedAt = GetDateTime(reader, "RevealedAt"),
                UnlockedByName = GetString(reader, "UnlockedByName")
            });
        }

        /// <summary>
        /// 获取最近行动日志。
        /// </summary>
        private IList<GameActionLogInfo> GetActionLogs(int sessionId, int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    l.Id,
    l.ReservationId,
    ISNULL(u.DisplayName, r.ContactName) AS PlayerName,
    l.ActionType,
    l.ActionTitle,
    l.ActionContent,
    l.CreatedAt
FROM dbo.SessionActionLogs l
LEFT JOIN dbo.Reservations r ON r.Id = l.ReservationId
LEFT JOIN dbo.Users u ON u.Id = r.UserId
WHERE l.SessionId = @SessionId
ORDER BY l.Id DESC;";

            var logs = ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@SessionId", sessionId);
            }, reader => new GameActionLogInfo
            {
                Id = GetInt32(reader, "Id"),
                ReservationId = GetNullableInt32(reader, "ReservationId"),
                PlayerName = GetString(reader, "PlayerName"),
                ActionType = GetString(reader, "ActionType"),
                ActionTitle = GetString(reader, "ActionTitle"),
                ActionContent = GetString(reader, "ActionContent"),
                CreatedAt = GetDateTime(reader, "CreatedAt")
            });

            var orderedLogs = new List<GameActionLogInfo>(logs);
            orderedLogs.Reverse();
            return orderedLogs;
        }

        /// <summary>
        /// 获取当前玩家在本场游戏中的投票。
        /// </summary>
        private GamePlayerVoteInfo GetCurrentVote(int sessionId, int reservationId)
        {
            const string sql = @"
SELECT TOP 1
    v.SuspectCharacterId,
    sc.Name AS SuspectCharacterName,
    v.VoteComment,
    v.CreatedAt
FROM dbo.SessionVotes v
INNER JOIN dbo.ScriptCharacters sc ON sc.Id = v.SuspectCharacterId
WHERE v.SessionId = @SessionId
  AND v.ReservationId = @ReservationId;";

            var items = ExecuteList(sql, command =>
            {
                command.Parameters.AddWithValue("@SessionId", sessionId);
                command.Parameters.AddWithValue("@ReservationId", reservationId);
            }, reader => new GamePlayerVoteInfo
            {
                SuspectCharacterId = GetInt32(reader, "SuspectCharacterId"),
                SuspectCharacterName = GetString(reader, "SuspectCharacterName"),
                VoteComment = GetString(reader, "VoteComment"),
                VotedAt = GetNullableDateTime(reader, "CreatedAt")
            });

            return items.Count > 0 ? items[0] : null;
        }

        /// <summary>
        /// 获取本场投票汇总，用于结果页和 DM 控制台。
        /// </summary>
        private IList<GameVoteSummaryInfo> GetVoteSummary(int sessionId)
        {
            const string sql = @"
SELECT
    sc.Id AS SuspectCharacterId,
    sc.Name AS SuspectCharacterName,
    COUNT(v.Id) AS VoteCount,
    CAST(CASE WHEN sc.Name = ISNULL(NULLIF(st.CaseKillerCharacterName, N''), ISNULL(s.KillerCharacterName, N'')) THEN 1 ELSE 0 END AS BIT) AS IsCorrect
FROM dbo.SessionCharacterAssignments a
INNER JOIN dbo.Reservations r ON r.Id = a.ReservationId
INNER JOIN dbo.Users reservationUser ON reservationUser.Id = r.UserId
INNER JOIN dbo.Sessions se ON se.Id = a.SessionId
INNER JOIN dbo.Scripts s ON s.Id = se.ScriptId
LEFT JOIN dbo.SessionGameStates st ON st.SessionId = a.SessionId
INNER JOIN dbo.ScriptCharacters sc ON sc.Id = a.CharacterId
LEFT JOIN dbo.SessionVotes v
    ON v.SessionId = a.SessionId
   AND v.SuspectCharacterId = a.CharacterId
   AND EXISTS
   (
       SELECT 1
       FROM dbo.SessionCharacterAssignments voter
       WHERE voter.SessionId = v.SessionId
         AND voter.ReservationId = v.ReservationId
         AND ISNULL(voter.IsEliminated, 0) = 0
   )
WHERE a.SessionId = @SessionId
  AND r.UserId IS NOT NULL
  AND ISNULL(a.IsEliminated, 0) = 0
  AND ISNULL(reservationUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')
  AND r.Status IN (N'待确认', N'已确认', N'玩家已确认', N'已到店')
GROUP BY sc.Id, sc.Name, st.CaseKillerCharacterName, s.KillerCharacterName
ORDER BY VoteCount DESC, sc.Id ASC;";

            return ExecuteList(sql, command => command.Parameters.AddWithValue("@SessionId", sessionId), reader => new GameVoteSummaryInfo
            {
                SuspectCharacterId = GetInt32(reader, "SuspectCharacterId"),
                SuspectCharacterName = GetString(reader, "SuspectCharacterName"),
                VoteCount = GetInt32(reader, "VoteCount"),
                IsCorrect = GetBoolean(reader, "IsCorrect")
            });
        }

        /// <summary>
        /// 获取本场每个玩家席位的投票提交状态。
        /// </summary>
        public IList<GameVoteDetailInfo> GetVoteDetails(int sessionId)
        {
            const string sql = @"
SELECT
    a.ReservationId,
    ISNULL(u.DisplayName, r.ContactName) AS PlayerName,
    r.ContactName,
    r.PlayerCount,
    sc.Id AS CharacterId,
    sc.Name AS CharacterName,
    ISNULL(a.IsEliminated, 0) AS IsEliminated,
    a.EliminatedAt,
    v.SuspectCharacterId,
    votedCharacter.Name AS SuspectCharacterName,
    v.VoteComment,
    v.CreatedAt AS VotedAt
FROM dbo.SessionCharacterAssignments a
INNER JOIN dbo.Reservations r ON r.Id = a.ReservationId
INNER JOIN dbo.Users u ON u.Id = r.UserId
INNER JOIN dbo.ScriptCharacters sc ON sc.Id = a.CharacterId
LEFT JOIN dbo.SessionVotes v
    ON v.SessionId = a.SessionId
   AND v.ReservationId = a.ReservationId
LEFT JOIN dbo.ScriptCharacters votedCharacter ON votedCharacter.Id = v.SuspectCharacterId
WHERE a.SessionId = @SessionId
  AND r.UserId IS NOT NULL
  AND ISNULL(u.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')
  AND r.Status IN (N'待确认', N'已确认', N'玩家已确认', N'已到店')
ORDER BY CASE WHEN v.Id IS NULL THEN 0 ELSE 1 END ASC, a.ReservationId ASC;";

            return ExecuteList(sql, command => command.Parameters.AddWithValue("@SessionId", sessionId), reader => new GameVoteDetailInfo
            {
                ReservationId = GetInt32(reader, "ReservationId"),
                PlayerName = GetString(reader, "PlayerName"),
                ContactName = GetString(reader, "ContactName"),
                PlayerCount = GetInt32(reader, "PlayerCount"),
                CharacterId = GetInt32(reader, "CharacterId"),
                CharacterName = GetString(reader, "CharacterName"),
                IsEliminated = GetBoolean(reader, "IsEliminated"),
                EliminatedAt = GetNullableDateTime(reader, "EliminatedAt"),
                SuspectCharacterId = GetNullableInt32(reader, "SuspectCharacterId"),
                SuspectCharacterName = GetString(reader, "SuspectCharacterName"),
                VoteComment = GetString(reader, "VoteComment"),
                VotedAt = GetNullableDateTime(reader, "VotedAt")
            });
        }

        /// <summary>
        /// 获取正确角色名，通常在结算后展示。
        /// </summary>
        private string GetCorrectCharacterName(int sessionId)
        {
            const string sql = @"
SELECT TOP 1 ISNULL(NULLIF(st.CaseKillerCharacterName, N''), ISNULL(s.KillerCharacterName, N''))
FROM dbo.Sessions se
INNER JOIN dbo.Scripts s ON s.Id = se.ScriptId
LEFT JOIN dbo.SessionGameStates st ON st.SessionId = se.Id
WHERE se.Id = @SessionId;";

            var items = ExecuteList(sql, command => command.Parameters.AddWithValue("@SessionId", sessionId), reader => GetString(reader, 0));
            return items.Count > 0 ? items[0] : string.Empty;
        }

        /// <summary>
        /// 获取案件真相说明。
        /// </summary>
        private string GetTruthSummary(int sessionId)
        {
            const string sql = @"
SELECT TOP 1 ISNULL(NULLIF(st.CaseTruthSummary, N''), ISNULL(s.TruthSummary, N''))
FROM dbo.Sessions se
INNER JOIN dbo.Scripts s ON s.Id = se.ScriptId
LEFT JOIN dbo.SessionGameStates st ON st.SessionId = se.Id
WHERE se.Id = @SessionId;";

            var items = ExecuteList(sql, command => command.Parameters.AddWithValue("@SessionId", sessionId), reader => GetString(reader, 0));
            return items.Count > 0 ? items[0] : string.Empty;
        }

        /// <summary>
        /// 获取尚未由 DM 发放的线索。
        /// </summary>
        private IList<GameHostClueOptionInfo> GetPendingClues(int sessionId)
        {
            const string sql = @"
SELECT
    c.Id,
    c.Title,
    ISNULL(gs.StageName, N'鑷敱闃舵') AS StageName,
    c.Summary,
    c.Detail,
    c.ClueType,
    c.IsPublic,
    ISNULL(asset.AssetType, N'clue') AS AssetType,
    ISNULL(asset.PublicUrl, N'') AS AssetUrl,
    ISNULL(asset.FileName, N'') AS FileName,
    ISNULL(asset.FileExtension, N'') AS FileExtension,
    N'剧本线索' AS SourceLabel,
    CAST(0 AS BIT) AS IsAssetSource,
    CAST(CASE WHEN revealed.ClueId IS NULL THEN 0 ELSE 1 END AS BIT) AS IsRevealed,
    CASE WHEN revealed.ClueId IS NULL THEN N'可发放' ELSE N'已发放，可再次推送' END AS ReleaseStatus,
    ISNULL(gs.SortOrder, 999) AS StageSort,
    c.SortOrder AS ItemSort
FROM dbo.ScriptClues c
INNER JOIN dbo.Sessions s ON s.ScriptId = c.ScriptId
LEFT JOIN dbo.GameStages gs ON gs.Id = c.StageId
OUTER APPLY
(
    SELECT TOP 1 a.AssetType, a.PublicUrl, a.FileName, a.FileExtension
    FROM dbo.ScriptAssets a
    WHERE a.ScriptId = c.ScriptId
      AND
      (
          c.Detail LIKE N'%' + a.RelativePath + N'%'
          OR c.Detail LIKE N'%' + a.FileName + N'%'
          OR c.Title = a.Title
      )
    ORDER BY a.IsPrimary DESC, a.SortOrder ASC, a.Id ASC
) asset
OUTER APPLY
(
    SELECT TOP 1 u.ClueId
    FROM dbo.SessionClueUnlocks u
    WHERE u.SessionId = @SessionId
      AND u.ClueId = c.Id
) revealed
WHERE s.Id = @SessionId
ORDER BY StageSort, ItemSort, Id;";

            return ExecuteList(sql, command => command.Parameters.AddWithValue("@SessionId", sessionId), reader => new GameHostClueOptionInfo
            {
                Id = GetInt32(reader, "Id"),
                Title = GetString(reader, "Title"),
                StageName = GetString(reader, "StageName"),
                Summary = GetString(reader, "Summary"),
                Detail = GetString(reader, "Detail"),
                ClueType = GetString(reader, "ClueType"),
                AssetType = GetString(reader, "AssetType"),
                AssetUrl = GetString(reader, "AssetUrl"),
                FileName = GetString(reader, "FileName"),
                FileExtension = GetString(reader, "FileExtension"),
                SourceLabel = GetString(reader, "SourceLabel"),
                IsAssetSource = GetBoolean(reader, "IsAssetSource"),
                IsRevealed = GetBoolean(reader, "IsRevealed"),
                ReleaseStatus = GetString(reader, "ReleaseStatus"),
                IsPublic = GetBoolean(reader, "IsPublic")
            });
        }

        /// <summary>
        /// 根据当前阶段、角色分配和投票状态计算页面操作开关。
        /// 这能让 .aspx 页面少写业务判断，只负责展示按钮。
        /// </summary>
        private GameSessionLifecycleInfo GetLifecycle(int sessionId, GameStageInfo currentStage, GameAssignmentInfo currentAssignment, GamePlayerVoteInfo currentVote)
        {
            const string sql = @"
SELECT TOP 1
    CAST(CASE WHEN GameStartedAt IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS IsGameStarted,
    CAST(CASE WHEN GameEndedAt IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS IsGameEnded,
    CAST(CASE WHEN SettledAt IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS IsSettled,
    GameStartedAt,
    GameEndedAt,
    SettledAt,
    ISNULL(DmNotes, N'') AS DmNotes,
    StageTimerStartedAt,
    ISNULL(StageTimerDurationMinutes, 0) AS StageTimerDurationMinutes,
    (
        SELECT ISNULL(SUM(r.PlayerCount), 0)
        FROM dbo.SessionCharacterAssignments a
        INNER JOIN dbo.Reservations r ON r.Id = a.ReservationId
        INNER JOIN dbo.Users reservationUser ON reservationUser.Id = r.UserId
        WHERE a.SessionId = @SessionId
          AND r.UserId IS NOT NULL
          AND ISNULL(a.IsEliminated, 0) = 0
          AND ISNULL(reservationUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')
          AND r.Status IN (N'待确认', N'已确认', N'玩家已确认', N'已到店')
    ) AS TotalAssignments,
    (
        SELECT ISNULL(SUM(r.PlayerCount), 0)
        FROM dbo.SessionCharacterAssignments a
        INNER JOIN dbo.Reservations r ON r.Id = a.ReservationId
        INNER JOIN dbo.Users reservationUser ON reservationUser.Id = r.UserId
        WHERE a.SessionId = @SessionId
          AND a.IsReady = 1
          AND ISNULL(a.IsEliminated, 0) = 0
          AND r.UserId IS NOT NULL
          AND ISNULL(reservationUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')
          AND r.Status IN (N'待确认', N'已确认', N'玩家已确认', N'已到店')
    ) AS ReadyCount,
    (
        SELECT ISNULL(SUM(r.PlayerCount), 0)
        FROM dbo.SessionVotes v
        INNER JOIN dbo.Reservations r ON r.Id = v.ReservationId
        INNER JOIN dbo.SessionCharacterAssignments a
            ON a.SessionId = v.SessionId
           AND a.ReservationId = v.ReservationId
        INNER JOIN dbo.Users reservationUser ON reservationUser.Id = r.UserId
        WHERE v.SessionId = @SessionId
          AND ISNULL(a.IsEliminated, 0) = 0
          AND r.UserId IS NOT NULL
          AND ISNULL(reservationUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')
          AND r.Status IN (N'待确认', N'已确认', N'玩家已确认', N'已到店')
    ) AS VoteCount,
    (
        SELECT COUNT(1)
        FROM dbo.SessionCharacterAssignments a
        INNER JOIN dbo.Reservations r ON r.Id = a.ReservationId
        INNER JOIN dbo.Users reservationUser ON reservationUser.Id = r.UserId
        WHERE a.SessionId = @SessionId
          AND ISNULL(a.IsEliminated, 0) = 1
          AND r.UserId IS NOT NULL
          AND ISNULL(reservationUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')
    ) AS EliminatedCount,
    (
        SELECT TOP 1 sc.Name
        FROM dbo.SessionCharacterAssignments a
        INNER JOIN dbo.ScriptCharacters sc ON sc.Id = a.CharacterId
        INNER JOIN dbo.Reservations r ON r.Id = a.ReservationId
        INNER JOIN dbo.Users reservationUser ON reservationUser.Id = r.UserId
        WHERE a.SessionId = @SessionId
          AND ISNULL(a.IsEliminated, 0) = 1
          AND r.UserId IS NOT NULL
          AND ISNULL(reservationUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')
        ORDER BY a.EliminatedAt DESC, a.Id DESC
    ) AS EliminatedCharacterName,
    (
        SELECT TOP 1 ISNULL(u.DisplayName, r.ContactName)
        FROM dbo.SessionCharacterAssignments a
        INNER JOIN dbo.Reservations r ON r.Id = a.ReservationId
        INNER JOIN dbo.Users reservationUser ON reservationUser.Id = r.UserId
        LEFT JOIN dbo.Users u ON u.Id = r.UserId
        WHERE a.SessionId = @SessionId
          AND ISNULL(a.IsEliminated, 0) = 1
          AND r.UserId IS NOT NULL
          AND ISNULL(reservationUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')
        ORDER BY a.EliminatedAt DESC, a.Id DESC
    ) AS EliminatedPlayerName
FROM dbo.SessionGameStates
WHERE SessionId = @SessionId;";

            var items = ExecuteList(sql, command => command.Parameters.AddWithValue("@SessionId", sessionId), reader => new GameSessionLifecycleInfo
            {
                IsGameStarted = GetBoolean(reader, "IsGameStarted"),
                IsGameEnded = GetBoolean(reader, "IsGameEnded"),
                IsSettled = GetBoolean(reader, "IsSettled"),
                GameStartedAt = GetNullableDateTime(reader, "GameStartedAt"),
                GameEndedAt = GetNullableDateTime(reader, "GameEndedAt"),
                SettledAt = GetNullableDateTime(reader, "SettledAt"),
                DmNotes = GetString(reader, "DmNotes"),
                StageTimerStartedAt = GetNullableDateTime(reader, "StageTimerStartedAt"),
                StageTimerDurationMinutes = GetInt32(reader, "StageTimerDurationMinutes"),
                TotalAssignments = GetInt32(reader, "TotalAssignments"),
                ReadyCount = GetInt32(reader, "ReadyCount"),
                VoteCount = GetInt32(reader, "VoteCount"),
                EliminatedCount = GetInt32(reader, "EliminatedCount"),
                EliminatedCharacterName = GetString(reader, "EliminatedCharacterName"),
                EliminatedPlayerName = GetString(reader, "EliminatedPlayerName")
            });

            var lifecycle = items.Count > 0 ? items[0] : new GameSessionLifecycleInfo();
            lifecycle.EveryoneReady = lifecycle.TotalAssignments > 0 && lifecycle.ReadyCount >= lifecycle.TotalAssignments;
            lifecycle.EveryoneVoted = lifecycle.TotalAssignments > 0 && lifecycle.VoteCount >= lifecycle.TotalAssignments;

            var isEndingStage = currentStage != null &&
                                string.Equals(currentStage.StageKey, "ending", StringComparison.OrdinalIgnoreCase);

            lifecycle.CanStartGame = !lifecycle.IsGameStarted && !lifecycle.IsGameEnded && lifecycle.TotalAssignments > 0 && lifecycle.EveryoneReady;
            lifecycle.CanFinishGame = lifecycle.IsGameStarted && !lifecycle.IsGameEnded && isEndingStage && lifecycle.EveryoneVoted;
            var currentPlayerEliminated = currentAssignment != null && currentAssignment.IsEliminated;
            lifecycle.CanSubmitAction = lifecycle.IsGameStarted && !lifecycle.IsGameEnded && !isEndingStage && !currentPlayerEliminated;
            lifecycle.CanSubmitVote = lifecycle.IsGameStarted && !lifecycle.IsGameEnded && isEndingStage && !currentPlayerEliminated;

            if (lifecycle.IsGameEnded)
            {
                lifecycle.StatusText = lifecycle.IsSettled ? "已结算归档" : "已结束待归档";
                lifecycle.ResumeSummary = "本局已经完成结算，你可以直接查看结案复盘和玩家中心里的最新战绩。";
                return lifecycle;
            }

            if (!lifecycle.IsGameStarted)
            {
                lifecycle.StatusText = lifecycle.EveryoneReady ? "待 DM 正式开局" : "等待玩家就位";
                lifecycle.ResumeSummary = lifecycle.EveryoneReady
                    ? "所有角色都已经就位，等待 DM 点击正式开局。"
                    : "当前房间还没有正式开局，你可以先确认角色资料并完成就位。";
                return lifecycle;
            }

            if (currentPlayerEliminated)
            {
                lifecycle.StatusText = "你已出局观战中";
                lifecycle.ResumeSummary = "你已被投票出局，可以继续观战；在本局结束前不能继续发言、行动或投票，结案后可以参与复盘讨论。";
                return lifecycle;
            }

            lifecycle.StatusText = isEndingStage ? "终局投票中" : "游戏进行中";
            lifecycle.ResumeSummary = "你已恢复到《" + (currentStage == null ? "当前房间" : currentStage.StageName) + "》阶段。"
                + (currentAssignment == null ? string.Empty : " 当前角色是《" + currentAssignment.CharacterName + "》。")
                + (currentVote == null ? " 当前还没有提交终局投票。" : " 你已经提交了本局终局投票。");
            return lifecycle;
        }

        public bool IsReservationEliminatedBeforeGameEnd(int reservationId)
        {
            const string sql = @"
SELECT TOP 1 CAST(CASE WHEN ISNULL(a.IsEliminated, 0) = 1 AND state.GameEndedAt IS NULL THEN 1 ELSE 0 END AS BIT) AS IsLockedOut
FROM dbo.Reservations r
INNER JOIN dbo.SessionGameStates state ON state.SessionId = r.SessionId
LEFT JOIN dbo.SessionCharacterAssignments a
    ON a.SessionId = r.SessionId
   AND a.ReservationId = r.Id
WHERE r.Id = @ReservationId;";

            var items = ExecuteList(sql, command => command.Parameters.AddWithValue("@ReservationId", reservationId), reader => GetBoolean(reader, "IsLockedOut"));
            return items.Count > 0 && items[0];
        }

        private void ResolveCompletedVoteRound(int sessionId, int? operatorUserId)
        {
            const string sql = @"
DECLARE @CurrentStageKey NVARCHAR(30);
DECLARE @TotalActiveVotesNeeded INT;
DECLARE @CurrentVoteCount INT;
DECLARE @TopVoteCount INT;
DECLARE @TopCharacterId INT;
DECLARE @TopCharacterName NVARCHAR(50);
DECLARE @TopReservationId INT;
DECLARE @TieCount INT;
DECLARE @CorrectCharacterId INT;

IF EXISTS (SELECT 1 FROM dbo.SessionGameStates WHERE SessionId = @SessionId AND (GameStartedAt IS NULL OR GameEndedAt IS NOT NULL))
BEGIN
    RETURN;
END

SELECT @CurrentStageKey = gs.StageKey
FROM dbo.SessionGameStates state
INNER JOIN dbo.GameStages gs ON gs.Id = state.CurrentStageId
WHERE state.SessionId = @SessionId;

IF ISNULL(@CurrentStageKey, N'') <> N'ending'
BEGIN
    RETURN;
END

SELECT @TotalActiveVotesNeeded = ISNULL(SUM(r.PlayerCount), 0)
FROM dbo.SessionCharacterAssignments a
INNER JOIN dbo.Reservations r ON r.Id = a.ReservationId
INNER JOIN dbo.Users reservationUser ON reservationUser.Id = r.UserId
WHERE a.SessionId = @SessionId
  AND ISNULL(a.IsEliminated, 0) = 0
  AND r.UserId IS NOT NULL
  AND ISNULL(reservationUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')
  AND r.Status IN (N'待确认', N'已确认', N'玩家已确认', N'已到店');

SELECT @CurrentVoteCount = ISNULL(SUM(r.PlayerCount), 0)
FROM dbo.SessionVotes v
INNER JOIN dbo.SessionCharacterAssignments a ON a.SessionId = v.SessionId AND a.ReservationId = v.ReservationId
INNER JOIN dbo.Reservations r ON r.Id = v.ReservationId
INNER JOIN dbo.Users reservationUser ON reservationUser.Id = r.UserId
WHERE v.SessionId = @SessionId
  AND ISNULL(a.IsEliminated, 0) = 0
  AND r.UserId IS NOT NULL
  AND ISNULL(reservationUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')
  AND r.Status IN (N'待确认', N'已确认', N'玩家已确认', N'已到店');

IF ISNULL(@TotalActiveVotesNeeded, 0) <= 0 OR ISNULL(@CurrentVoteCount, 0) < @TotalActiveVotesNeeded
BEGIN
    RETURN;
END

DECLARE @VoteScores TABLE(CharacterId INT NOT NULL, VoteWeight INT NOT NULL);

INSERT INTO @VoteScores(CharacterId, VoteWeight)
SELECT v.SuspectCharacterId, ISNULL(SUM(r.PlayerCount), 0)
FROM dbo.SessionVotes v
INNER JOIN dbo.SessionCharacterAssignments a ON a.SessionId = v.SessionId AND a.ReservationId = v.ReservationId
INNER JOIN dbo.Reservations r ON r.Id = v.ReservationId
INNER JOIN dbo.Users reservationUser ON reservationUser.Id = r.UserId
WHERE v.SessionId = @SessionId
  AND ISNULL(a.IsEliminated, 0) = 0
  AND r.UserId IS NOT NULL
  AND ISNULL(reservationUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')
  AND r.Status IN (N'待确认', N'已确认', N'玩家已确认', N'已到店')
GROUP BY v.SuspectCharacterId;

SELECT @TopVoteCount = MAX(VoteWeight) FROM @VoteScores;
SELECT @TieCount = COUNT(1) FROM @VoteScores WHERE VoteWeight = @TopVoteCount;

IF @TieCount <> 1
BEGIN
    RETURN;
END

SELECT TOP 1 @TopCharacterId = CharacterId
FROM @VoteScores
ORDER BY VoteWeight DESC, CharacterId ASC;

SELECT
    @TopCharacterName = sc.Name,
    @TopReservationId = a.ReservationId
FROM dbo.SessionCharacterAssignments a
INNER JOIN dbo.ScriptCharacters sc ON sc.Id = a.CharacterId
WHERE a.SessionId = @SessionId
  AND a.CharacterId = @TopCharacterId;

SELECT @CorrectCharacterId = killerCharacter.Id
FROM dbo.SessionGameStates state
INNER JOIN dbo.Sessions sessionInfo ON sessionInfo.Id = state.SessionId
INNER JOIN dbo.Scripts script ON script.Id = sessionInfo.ScriptId
LEFT JOIN dbo.ScriptCharacters killerCharacter
    ON killerCharacter.ScriptId = script.Id
   AND killerCharacter.Name = ISNULL(NULLIF(state.CaseKillerCharacterName, N''), ISNULL(script.KillerCharacterName, N''))
WHERE state.SessionId = @SessionId;

IF @CorrectCharacterId IS NOT NULL AND @TopCharacterId = @CorrectCharacterId
BEGIN
    UPDATE dbo.SessionCharacterAssignments
    SET IsEliminated = 1,
        EliminatedAt = GETDATE()
    WHERE SessionId = @SessionId
      AND CharacterId = @TopCharacterId
      AND ISNULL(IsEliminated, 0) = 0;

    UPDATE dbo.SessionGameStates
    SET GameEndedAt = ISNULL(GameEndedAt, GETDATE()),
        EndedByUserId = COALESCE(@OperatorUserId, EndedByUserId),
        UpdatedAt = GETDATE()
    WHERE SessionId = @SessionId
      AND GameEndedAt IS NULL;

    IF @@ROWCOUNT > 0
    BEGIN
        INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
        VALUES(@SessionId, @TopReservationId, N'VoteResult', N'真凶出局', N'全员投票完成，《' + ISNULL(@TopCharacterName, N'未知角色') + N'》被投出局，命中真凶，游戏自动结束并开放复盘讨论。', GETDATE());
    END
END
ELSE
BEGIN
    UPDATE dbo.SessionCharacterAssignments
    SET IsEliminated = 1,
        EliminatedAt = GETDATE()
    WHERE SessionId = @SessionId
      AND CharacterId = @TopCharacterId
      AND ISNULL(IsEliminated, 0) = 0;

    IF @@ROWCOUNT > 0
    BEGIN
        DELETE FROM dbo.SessionVotes WHERE SessionId = @SessionId;

        INSERT INTO dbo.SessionActionLogs(SessionId, ReservationId, ActionType, ActionTitle, ActionContent, CreatedAt)
        VALUES(@SessionId, @TopReservationId, N'VoteResult', N'玩家出局', N'全员投票完成，《' + ISNULL(@TopCharacterName, N'未知角色') + N'》被投出局；该玩家进入观战，本局结束前不能继续发言、行动或投票。', GETDATE());
    END
END";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@SessionId", sessionId);
                command.Parameters.AddWithValue("@OperatorUserId", operatorUserId.HasValue ? (object)operatorUserId.Value : DBNull.Value);
                connection.Open();
                command.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// 通过预约 Id 反查场次 Id。
        /// </summary>
        private int? GetSessionIdByReservation(int reservationId)
        {
            const string sql = @"
SELECT TOP 1 SessionId
FROM dbo.Reservations
WHERE Id = @ReservationId;";

            var items = ExecuteList(sql, command => command.Parameters.AddWithValue("@ReservationId", reservationId), reader => GetInt32(reader, 0));
            if (items.Count == 0)
            {
                return null;
            }

            return items[0];
        }

        /// <summary>
        /// 通用列表查询模板，供私有查询复用。
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

        /// <summary>
        /// 按列名读取字符串，数据库 NULL 转为空字符串。
        /// </summary>
        private static string GetString(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? string.Empty : Convert.ToString(reader[columnName]);
        }

        /// <summary>
        /// 按列序号读取字符串，数据库 NULL 转为空字符串。
        /// </summary>
        private static string GetString(SqlDataReader reader, int columnIndex)
        {
            return reader[columnIndex] == DBNull.Value ? string.Empty : Convert.ToString(reader[columnIndex]);
        }

        /// <summary>
        /// 按列名读取整数字段。
        /// </summary>
        private static int GetInt32(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? 0 : Convert.ToInt32(reader[columnName]);
        }

        /// <summary>
        /// 按列序号读取整数字段。
        /// </summary>
        private static int GetInt32(SqlDataReader reader, int columnIndex)
        {
            return reader[columnIndex] == DBNull.Value ? 0 : Convert.ToInt32(reader[columnIndex]);
        }

        /// <summary>
        /// 读取可空整数字段。
        /// </summary>
        private static int? GetNullableInt32(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? (int?)null : Convert.ToInt32(reader[columnName]);
        }

        /// <summary>
        /// 读取必填时间字段。
        /// </summary>
        private static DateTime GetDateTime(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? DateTime.MinValue : Convert.ToDateTime(reader[columnName]);
        }

        /// <summary>
        /// 读取可空时间字段。
        /// </summary>
        private static DateTime? GetNullableDateTime(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader[columnName]);
        }

        /// <summary>
        /// 读取布尔字段。
        /// </summary>
        private static bool GetBoolean(SqlDataReader reader, string columnName)
        {
            return reader[columnName] != DBNull.Value && Convert.ToBoolean(reader[columnName]);
        }
    }
}




