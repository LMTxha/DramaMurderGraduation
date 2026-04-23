using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web.Data
{
    public class GameRepository
    {
        public void EnsureSessionGameData(int sessionId)
        {
            const string sql = @"
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

        public GameRoomStateInfo GetGameRoomState(int sessionId, int reservationId)
        {
            EnsureSessionGameData(sessionId);
            EnsureGameSettlement(sessionId);

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

        public bool StartGame(int reservationId, int operatorUserId, out string message)
        {
            const string sql = @"
DECLARE @SessionId INT;
DECLARE @OperatorName NVARCHAR(50);
DECLARE @TotalAssignments INT;
DECLARE @ReadyCount INT;
DECLARE @CurrentStageName NVARCHAR(60);

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

        public bool SubmitVote(int reservationId, int suspectCharacterId, string voteComment, out string message)
        {
            const string sql = @"
DECLARE @SessionId INT;
DECLARE @CurrentStageKey NVARCHAR(30);
DECLARE @PlayerName NVARCHAR(50);
DECLARE @CharacterName NVARCHAR(50);

SELECT
    @SessionId = r.SessionId,
    @PlayerName = ISNULL(u.DisplayName, r.ContactName)
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

SELECT @CharacterName = sc.Name
FROM dbo.SessionCharacterAssignments a
INNER JOIN dbo.ScriptCharacters sc ON sc.Id = a.CharacterId
WHERE a.SessionId = @SessionId
  AND a.CharacterId = @SuspectCharacterId;

IF @CharacterName IS NULL
BEGIN
    RAISERROR(N'投票目标无效，请从当前房间角色中重新选择。', 16, 1);
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
VALUES
(
    @SessionId,
    @ReservationId,
    N'Vote',
    N'提交终局投票',
    ISNULL(@PlayerName, N'玩家') + N' 将终局票投给了《' + @CharacterName + N'》。',
    GETDATE()
);";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@ReservationId", reservationId);
                command.Parameters.AddWithValue("@SuspectCharacterId", suspectCharacterId);
                command.Parameters.AddWithValue("@VoteComment", voteComment ?? string.Empty);
                connection.Open();

                try
                {
                    command.ExecuteNonQuery();
                    message = "终局投票已提交，房间会同步显示最新票型。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

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
        RAISERROR(N'这条公共线索已经发放过了。', 16, 1);
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
    RAISERROR(N'这条私密线索已经发放给该玩家。', 16, 1);
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
                    message = "线索已发放到房间。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

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
    a.IsReady
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
                IsReady = GetBoolean(reader, "IsReady")
            });
        }

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
    c.IsPublic,
    c.SortOrder,
    u.RevealMethod,
    u.RevealedAt,
    ISNULL(unlockUser.DisplayName, unlockReservation.ContactName) AS UnlockedByName
FROM dbo.SessionClueUnlocks u
INNER JOIN dbo.ScriptClues c ON c.Id = u.ClueId
LEFT JOIN dbo.GameStages gs ON gs.Id = c.StageId
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
                IsPublic = GetBoolean(reader, "IsPublic"),
                SortOrder = GetInt32(reader, "SortOrder"),
                RevealMethod = GetString(reader, "RevealMethod"),
                RevealedAt = GetDateTime(reader, "RevealedAt"),
                UnlockedByName = GetString(reader, "UnlockedByName")
            });
        }

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
WHERE a.SessionId = @SessionId
  AND r.UserId IS NOT NULL
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

        private IList<GameHostClueOptionInfo> GetPendingClues(int sessionId)
        {
            const string sql = @"
SELECT
    c.Id,
    c.Title,
    ISNULL(gs.StageName, N'鑷敱闃舵') AS StageName,
    c.ClueType,
    c.IsPublic
FROM dbo.ScriptClues c
INNER JOIN dbo.Sessions s ON s.ScriptId = c.ScriptId
LEFT JOIN dbo.GameStages gs ON gs.Id = c.StageId
WHERE s.Id = @SessionId
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.SessionClueUnlocks u
      WHERE u.SessionId = @SessionId
        AND u.ClueId = c.Id
        AND (c.IsPublic = 1 OR u.RevealedToReservationId IS NOT NULL)
  )
ORDER BY ISNULL(gs.SortOrder, 999), c.SortOrder, c.Id;";

            return ExecuteList(sql, command => command.Parameters.AddWithValue("@SessionId", sessionId), reader => new GameHostClueOptionInfo
            {
                Id = GetInt32(reader, "Id"),
                Title = GetString(reader, "Title"),
                StageName = GetString(reader, "StageName"),
                ClueType = GetString(reader, "ClueType"),
                IsPublic = GetBoolean(reader, "IsPublic")
            });
        }

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
        SELECT COUNT(1)
        FROM dbo.SessionCharacterAssignments a
        INNER JOIN dbo.Reservations r ON r.Id = a.ReservationId
        INNER JOIN dbo.Users reservationUser ON reservationUser.Id = r.UserId
        WHERE a.SessionId = @SessionId
          AND r.UserId IS NOT NULL
          AND ISNULL(reservationUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')
          AND r.Status IN (N'待确认', N'已确认', N'玩家已确认', N'已到店')
    ) AS TotalAssignments,
    (
        SELECT COUNT(1)
        FROM dbo.SessionCharacterAssignments a
        INNER JOIN dbo.Reservations r ON r.Id = a.ReservationId
        INNER JOIN dbo.Users reservationUser ON reservationUser.Id = r.UserId
        WHERE a.SessionId = @SessionId
          AND a.IsReady = 1
          AND r.UserId IS NOT NULL
          AND ISNULL(reservationUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')
          AND r.Status IN (N'待确认', N'已确认', N'玩家已确认', N'已到店')
    ) AS ReadyCount,
    (
        SELECT COUNT(1)
        FROM dbo.SessionVotes v
        INNER JOIN dbo.Reservations r ON r.Id = v.ReservationId
        INNER JOIN dbo.Users reservationUser ON reservationUser.Id = r.UserId
        WHERE v.SessionId = @SessionId
          AND r.UserId IS NOT NULL
          AND ISNULL(reservationUser.RoleCode, N'User') NOT IN (N'Admin', N'DM', N'Host', N'Director')
          AND r.Status IN (N'待确认', N'已确认', N'玩家已确认', N'已到店')
    ) AS VoteCount
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
                VoteCount = GetInt32(reader, "VoteCount")
            });

            var lifecycle = items.Count > 0 ? items[0] : new GameSessionLifecycleInfo();
            lifecycle.EveryoneReady = lifecycle.TotalAssignments > 0 && lifecycle.ReadyCount >= lifecycle.TotalAssignments;
            lifecycle.EveryoneVoted = lifecycle.TotalAssignments > 0 && lifecycle.VoteCount >= lifecycle.TotalAssignments;

            var isEndingStage = currentStage != null &&
                                string.Equals(currentStage.StageKey, "ending", StringComparison.OrdinalIgnoreCase);

            lifecycle.CanStartGame = !lifecycle.IsGameStarted && !lifecycle.IsGameEnded && lifecycle.TotalAssignments > 0 && lifecycle.EveryoneReady;
            lifecycle.CanFinishGame = lifecycle.IsGameStarted && !lifecycle.IsGameEnded && isEndingStage && lifecycle.EveryoneVoted;
            lifecycle.CanSubmitAction = lifecycle.IsGameStarted && !lifecycle.IsGameEnded && !isEndingStage;
            lifecycle.CanSubmitVote = lifecycle.IsGameStarted && !lifecycle.IsGameEnded && isEndingStage;

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

            lifecycle.StatusText = isEndingStage ? "终局投票中" : "游戏进行中";
            lifecycle.ResumeSummary = "你已恢复到《" + (currentStage == null ? "当前房间" : currentStage.StageName) + "》阶段。"
                + (currentAssignment == null ? string.Empty : " 当前角色是《" + currentAssignment.CharacterName + "》。")
                + (currentVote == null ? " 当前还没有提交终局投票。" : " 你已经提交了本局终局投票。");
            return lifecycle;
        }

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

        private static string GetString(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? string.Empty : Convert.ToString(reader[columnName]);
        }

        private static string GetString(SqlDataReader reader, int columnIndex)
        {
            return reader[columnIndex] == DBNull.Value ? string.Empty : Convert.ToString(reader[columnIndex]);
        }

        private static int GetInt32(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? 0 : Convert.ToInt32(reader[columnName]);
        }

        private static int GetInt32(SqlDataReader reader, int columnIndex)
        {
            return reader[columnIndex] == DBNull.Value ? 0 : Convert.ToInt32(reader[columnIndex]);
        }

        private static int? GetNullableInt32(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? (int?)null : Convert.ToInt32(reader[columnName]);
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
    }
}




