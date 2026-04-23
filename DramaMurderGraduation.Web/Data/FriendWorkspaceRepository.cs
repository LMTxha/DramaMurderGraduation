using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web.Data
{
    public class FriendWorkspaceRepository
    {
        public IList<ChatGroupInfo> GetChatGroups(int userId)
        {
            const string sql = @"
SELECT
    g.Id AS GroupId,
    g.Name,
    ISNULL(g.AvatarUrl, N'') AS AvatarUrl,
    ISNULL(g.Announcement, N'') AS Announcement,
    g.OwnerUserId,
    ISNULL(memberStats.MemberCount, 0) AS MemberCount,
    latest.LastMessagePreview,
    latest.LastMessageAt,
    ISNULL(unread.UnreadCount, 0) AS UnreadCount,
    ISNULL(pref.IsPinned, 0) AS IsPinned,
    ISNULL(pref.IsHidden, 0) AS IsHidden,
    ISNULL(pref.IsMuted, 0) AS IsMuted
FROM dbo.ChatGroups g
INNER JOIN dbo.ChatGroupMembers gm ON gm.GroupId = g.Id AND gm.UserId = @UserId
OUTER APPLY
(
    SELECT COUNT(1) AS MemberCount
    FROM dbo.ChatGroupMembers members
    WHERE members.GroupId = g.Id
) memberStats
OUTER APPLY
(
    SELECT TOP 1
        CASE
            WHEN ISNULL(msg.IsRevoked, 0) = 1 THEN N'[已撤回消息]'
            WHEN msg.MessageType = N'Photo' THEN N'[图片] ' + ISNULL(NULLIF(msg.Content, N''), N'分享了一张图片')
            WHEN msg.MessageType = N'Location' THEN N'[位置] ' + ISNULL(NULLIF(msg.LocationText, N''), ISNULL(NULLIF(msg.Content, N''), N'分享了位置'))
            WHEN msg.MessageType = N'Voice' THEN N'[语音] ' + ISNULL(NULLIF(msg.Content, N''), N'发来了一条语音留言')
            WHEN msg.MessageType = N'VideoCall' THEN N'[语音通话] ' + ISNULL(NULLIF(msg.Content, N''), N'发起了通话邀请')
            ELSE ISNULL(NULLIF(msg.Content, N''), N'开始群聊吧')
        END AS LastMessagePreview,
        msg.CreatedAt AS LastMessageAt
    FROM dbo.GroupMessages msg
    WHERE msg.GroupId = g.Id
    ORDER BY msg.CreatedAt DESC, msg.Id DESC
) latest
LEFT JOIN dbo.GroupConversationPreferences pref ON pref.UserId = @UserId AND pref.GroupId = g.Id
OUTER APPLY
(
    SELECT COUNT(1) AS UnreadCount
    FROM dbo.GroupMessages msg
    WHERE msg.GroupId = g.Id
      AND msg.SenderUserId <> @UserId
      AND (pref.LastReadGroupMessageId IS NULL OR msg.Id > pref.LastReadGroupMessageId)
) unread
ORDER BY ISNULL(pref.IsPinned, 0) DESC, latest.LastMessageAt DESC, g.Id DESC;";

            var results = new List<ChatGroupInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(new ChatGroupInfo
                        {
                            GroupId = Convert.ToInt32(reader["GroupId"]),
                            Name = Convert.ToString(reader["Name"]),
                            AvatarUrl = Convert.ToString(reader["AvatarUrl"]),
                            Announcement = Convert.ToString(reader["Announcement"]),
                            OwnerUserId = Convert.ToInt32(reader["OwnerUserId"]),
                            MemberCount = Convert.ToInt32(reader["MemberCount"]),
                            LastMessagePreview = reader["LastMessagePreview"] == DBNull.Value ? string.Empty : Convert.ToString(reader["LastMessagePreview"]),
                            LastMessageAt = reader["LastMessageAt"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["LastMessageAt"]),
                            UnreadCount = Convert.ToInt32(reader["UnreadCount"]),
                            IsPinned = Convert.ToBoolean(reader["IsPinned"]),
                            IsHidden = Convert.ToBoolean(reader["IsHidden"]),
                            IsMuted = Convert.ToBoolean(reader["IsMuted"])
                        });
                    }
                }
            }

            return results;
        }

        public ChatGroupInfo GetChatGroupById(int userId, int groupId)
        {
            foreach (var item in GetChatGroups(userId))
            {
                if (item.GroupId == groupId)
                {
                    return item;
                }
            }

            return null;
        }

        public IList<ChatGroupMemberInfo> GetChatGroupMembers(int userId, int groupId)
        {
            const string sql = @"
SELECT
    gm.GroupId,
    gm.UserId,
    u.DisplayName,
    ISNULL(pp.AvatarUrl, N'') AS AvatarUrl,
    ISNULL(u.PublicUserCode, N'') AS PublicUserCode,
    CASE WHEN g.OwnerUserId = gm.UserId THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsOwner,
    gm.JoinedAt
FROM dbo.ChatGroupMembers gm
INNER JOIN dbo.ChatGroups g ON g.Id = gm.GroupId
INNER JOIN dbo.Users u ON u.Id = gm.UserId
LEFT JOIN dbo.PlayerProfiles pp ON pp.UserId = gm.UserId
WHERE gm.GroupId = @GroupId
  AND EXISTS (SELECT 1 FROM dbo.ChatGroupMembers self WHERE self.GroupId = gm.GroupId AND self.UserId = @UserId)
ORDER BY CASE WHEN g.OwnerUserId = gm.UserId THEN 0 ELSE 1 END, gm.JoinedAt ASC, gm.Id ASC;";

            var results = new List<ChatGroupMemberInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@GroupId", groupId);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(new ChatGroupMemberInfo
                        {
                            GroupId = Convert.ToInt32(reader["GroupId"]),
                            UserId = Convert.ToInt32(reader["UserId"]),
                            DisplayName = Convert.ToString(reader["DisplayName"]),
                            AvatarUrl = Convert.ToString(reader["AvatarUrl"]),
                            PublicUserCode = Convert.ToString(reader["PublicUserCode"]),
                            IsOwner = Convert.ToBoolean(reader["IsOwner"]),
                            JoinedAt = Convert.ToDateTime(reader["JoinedAt"])
                        });
                    }
                }
            }

            return results;
        }

        public IList<ChatWorkspaceMessageInfo> GetChatGroupMessages(int userId, int groupId, int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    msg.Id,
    msg.GroupId,
    msg.SenderUserId,
    u.DisplayName AS SenderDisplayName,
    ISNULL(pp.AvatarUrl, N'') AS SenderAvatarUrl,
    msg.MessageType,
    ISNULL(msg.Content, N'') AS Content,
    ISNULL(msg.AttachmentUrl, N'') AS AttachmentUrl,
    ISNULL(msg.LocationText, N'') AS LocationText,
    ISNULL(msg.IsRevoked, 0) AS IsRevoked,
    msg.CreatedAt
FROM dbo.GroupMessages msg
INNER JOIN dbo.Users u ON u.Id = msg.SenderUserId
LEFT JOIN dbo.PlayerProfiles pp ON pp.UserId = msg.SenderUserId
WHERE msg.GroupId = @GroupId
  AND EXISTS (SELECT 1 FROM dbo.ChatGroupMembers self WHERE self.GroupId = msg.GroupId AND self.UserId = @UserId)
ORDER BY msg.CreatedAt ASC, msg.Id ASC;";

            var results = new List<ChatWorkspaceMessageInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@GroupId", groupId);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(new ChatWorkspaceMessageInfo
                        {
                            Id = Convert.ToInt32(reader["Id"]),
                            ConversationKind = "Group",
                            ConversationId = Convert.ToInt32(reader["GroupId"]),
                            SenderUserId = Convert.ToInt32(reader["SenderUserId"]),
                            SenderDisplayName = Convert.ToString(reader["SenderDisplayName"]),
                            SenderAvatarUrl = Convert.ToString(reader["SenderAvatarUrl"]),
                            IsCurrentUser = Convert.ToInt32(reader["SenderUserId"]) == userId,
                            MessageType = Convert.ToString(reader["MessageType"]),
                            Content = Convert.ToString(reader["Content"]),
                            AttachmentUrl = Convert.ToString(reader["AttachmentUrl"]),
                            LocationText = Convert.ToString(reader["LocationText"]),
                            IsRevoked = Convert.ToBoolean(reader["IsRevoked"]),
                            CreatedAt = Convert.ToDateTime(reader["CreatedAt"])
                        });
                    }
                }
            }

            return results;
        }

        public bool CreateChatGroup(int ownerUserId, string groupName, string announcement, IList<int> memberUserIds, out string message)
        {
            if (string.IsNullOrWhiteSpace(groupName))
            {
                message = "请输入群聊名称。";
                return false;
            }

            var distinctMembers = new List<int>();
            if (memberUserIds != null)
            {
                foreach (var item in memberUserIds)
                {
                    if (item > 0 && item != ownerUserId && !distinctMembers.Contains(item))
                    {
                        distinctMembers.Add(item);
                    }
                }
            }

            if (distinctMembers.Count == 0)
            {
                message = "请至少选择一位好友加入群聊。";
                return false;
            }

            const string sql = @"
DECLARE @GroupId INT;

INSERT INTO dbo.ChatGroups(Name, OwnerUserId, AvatarUrl, Announcement, CreatedAt)
VALUES(@Name, @OwnerUserId, @AvatarUrl, NULLIF(@Announcement, N''), GETDATE());

SET @GroupId = SCOPE_IDENTITY();

INSERT INTO dbo.ChatGroupMembers(GroupId, UserId, DisplayOrder, JoinedAt)
VALUES(@GroupId, @OwnerUserId, 0, GETDATE());

SELECT @GroupId;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@Name", groupName.Trim());
                command.Parameters.AddWithValue("@OwnerUserId", ownerUserId);
                command.Parameters.AddWithValue("@AvatarUrl", BuildGroupAvatar(groupName));
                command.Parameters.AddWithValue("@Announcement", string.IsNullOrWhiteSpace(announcement) ? string.Empty : announcement.Trim());
                connection.Open();

                using (var transaction = connection.BeginTransaction())
                {
                    command.Transaction = transaction;
                    try
                    {
                        var groupId = Convert.ToInt32(command.ExecuteScalar());

                        for (var index = 0; index < distinctMembers.Count; index++)
                        {
                            using (var addMember = new SqlCommand(
                                "INSERT INTO dbo.ChatGroupMembers(GroupId, UserId, DisplayOrder, JoinedAt) VALUES(@GroupId, @UserId, @DisplayOrder, GETDATE());",
                                connection,
                                transaction))
                            {
                                addMember.Parameters.AddWithValue("@GroupId", groupId);
                                addMember.Parameters.AddWithValue("@UserId", distinctMembers[index]);
                                addMember.Parameters.AddWithValue("@DisplayOrder", index + 1);
                                addMember.ExecuteNonQuery();
                            }
                        }

                        using (var addMessage = new SqlCommand(
                            "INSERT INTO dbo.GroupMessages(GroupId, SenderUserId, MessageType, Content, AttachmentUrl, LocationText, CreatedAt) VALUES(@GroupId, @SenderUserId, N'Text', @Content, NULL, NULL, GETDATE());",
                            connection,
                            transaction))
                        {
                            addMessage.Parameters.AddWithValue("@GroupId", groupId);
                            addMessage.Parameters.AddWithValue("@SenderUserId", ownerUserId);
                            addMessage.Parameters.AddWithValue("@Content", "创建了群聊「" + groupName.Trim() + "」，可以开始讨论剧本、组局和开本安排了。");
                            addMessage.ExecuteNonQuery();
                        }

                        transaction.Commit();
                        message = "群聊已创建。";
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

        public bool SendGroupMessage(int senderUserId, int groupId, string messageType, string content, string attachmentUrl, string locationText, out string message)
        {
            const string sql = @"
IF NOT EXISTS (SELECT 1 FROM dbo.ChatGroupMembers WHERE GroupId = @GroupId AND UserId = @SenderUserId)
BEGIN
    RAISERROR(N'当前用户不在这个群聊中。', 16, 1);
    RETURN;
END;

IF NULLIF(LTRIM(RTRIM(ISNULL(@Content, N''))), N'') IS NULL
   AND NULLIF(LTRIM(RTRIM(ISNULL(@AttachmentUrl, N''))), N'') IS NULL
   AND NULLIF(LTRIM(RTRIM(ISNULL(@LocationText, N''))), N'') IS NULL
BEGIN
    RAISERROR(N'请至少填写消息内容、附件或位置中的一项。', 16, 1);
    RETURN;
END;

INSERT INTO dbo.GroupMessages(GroupId, SenderUserId, MessageType, Content, AttachmentUrl, LocationText, CreatedAt)
VALUES(@GroupId, @SenderUserId, @MessageType, NULLIF(@Content, N''), NULLIF(@AttachmentUrl, N''), NULLIF(@LocationText, N''), GETDATE());";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@GroupId", groupId);
                command.Parameters.AddWithValue("@SenderUserId", senderUserId);
                command.Parameters.AddWithValue("@MessageType", NormalizeMessageType(messageType));
                command.Parameters.AddWithValue("@Content", string.IsNullOrWhiteSpace(content) ? string.Empty : content.Trim());
                command.Parameters.AddWithValue("@AttachmentUrl", string.IsNullOrWhiteSpace(attachmentUrl) ? string.Empty : attachmentUrl.Trim());
                command.Parameters.AddWithValue("@LocationText", string.IsNullOrWhiteSpace(locationText) ? string.Empty : locationText.Trim());
                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "群聊消息已发送。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public void MarkGroupConversationAsRead(int userId, int groupId)
        {
            const string sql = @"
DECLARE @LatestMessageId INT;

SELECT @LatestMessageId = MAX(Id)
FROM dbo.GroupMessages
WHERE GroupId = @GroupId;

IF @LatestMessageId IS NULL
BEGIN
    RETURN;
END;

IF EXISTS (SELECT 1 FROM dbo.GroupConversationPreferences WHERE UserId = @UserId AND GroupId = @GroupId)
BEGIN
    UPDATE dbo.GroupConversationPreferences
    SET LastReadGroupMessageId = @LatestMessageId,
        UpdatedAt = GETDATE()
    WHERE UserId = @UserId
      AND GroupId = @GroupId;
END
ELSE
BEGIN
    INSERT INTO dbo.GroupConversationPreferences(UserId, GroupId, IsPinned, IsHidden, IsMuted, LastReadGroupMessageId, CreatedAt, UpdatedAt)
    VALUES(@UserId, @GroupId, 0, 0, 0, @LatestMessageId, GETDATE(), GETDATE());
END;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@GroupId", groupId);
                connection.Open();
                command.ExecuteNonQuery();
            }
        }

        public bool SetGroupConversationPreference(int userId, int groupId, bool? isPinned, bool? isHidden, bool? isMuted, out string message)
        {
            const string sql = @"
IF NOT EXISTS (SELECT 1 FROM dbo.ChatGroupMembers WHERE GroupId = @GroupId AND UserId = @UserId)
BEGIN
    RAISERROR(N'当前用户不在这个群聊中。', 16, 1);
    RETURN;
END;

IF EXISTS (SELECT 1 FROM dbo.GroupConversationPreferences WHERE UserId = @UserId AND GroupId = @GroupId)
BEGIN
    UPDATE dbo.GroupConversationPreferences
    SET IsPinned = COALESCE(@IsPinned, IsPinned),
        IsHidden = COALESCE(@IsHidden, IsHidden),
        IsMuted = COALESCE(@IsMuted, IsMuted),
        UpdatedAt = GETDATE()
    WHERE UserId = @UserId
      AND GroupId = @GroupId;
END
ELSE
BEGIN
    INSERT INTO dbo.GroupConversationPreferences(UserId, GroupId, IsPinned, IsHidden, IsMuted, CreatedAt, UpdatedAt)
    VALUES(@UserId, @GroupId, COALESCE(@IsPinned, 0), COALESCE(@IsHidden, 0), COALESCE(@IsMuted, 0), GETDATE(), GETDATE());
END;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@GroupId", groupId);
                command.Parameters.AddWithValue("@IsPinned", isPinned.HasValue ? (object)isPinned.Value : DBNull.Value);
                command.Parameters.AddWithValue("@IsHidden", isHidden.HasValue ? (object)isHidden.Value : DBNull.Value);
                command.Parameters.AddWithValue("@IsMuted", isMuted.HasValue ? (object)isMuted.Value : DBNull.Value);
                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "群聊显示设置已更新。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public IList<QuickNoteInfo> GetQuickNotes(int userId, int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    Id,
    UserId,
    Title,
    Content,
    CreatedAt,
    UpdatedAt
FROM dbo.UserQuickNotes
WHERE UserId = @UserId
ORDER BY UpdatedAt DESC, Id DESC;";

            var results = new List<QuickNoteInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(new QuickNoteInfo
                        {
                            Id = Convert.ToInt32(reader["Id"]),
                            UserId = Convert.ToInt32(reader["UserId"]),
                            Title = Convert.ToString(reader["Title"]),
                            Content = Convert.ToString(reader["Content"]),
                            CreatedAt = Convert.ToDateTime(reader["CreatedAt"]),
                            UpdatedAt = Convert.ToDateTime(reader["UpdatedAt"])
                        });
                    }
                }
            }

            return results;
        }

        public bool CreateQuickNote(int userId, string title, string content, out string message)
        {
            if (string.IsNullOrWhiteSpace(title))
            {
                message = "请填写便签标题。";
                return false;
            }

            if (string.IsNullOrWhiteSpace(content))
            {
                message = "请填写便签内容。";
                return false;
            }

            const string sql = @"
INSERT INTO dbo.UserQuickNotes(UserId, Title, Content, CreatedAt, UpdatedAt)
VALUES(@UserId, @Title, @Content, GETDATE(), GETDATE());";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@Title", title.Trim());
                command.Parameters.AddWithValue("@Content", content.Trim());
                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "便签已创建。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public bool DeleteQuickNote(int userId, int noteId, out string message)
        {
            const string sql = @"
DELETE FROM dbo.UserQuickNotes
WHERE Id = @NoteId
  AND UserId = @UserId;

IF @@ROWCOUNT = 0
BEGIN
    RAISERROR(N'没有找到对应便签。', 16, 1);
END;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@NoteId", noteId);
                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "便签已删除。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public UserDesktopSettingsInfo GetDesktopSettings(int userId)
        {
            const string sql = @"
IF NOT EXISTS (SELECT 1 FROM dbo.UserDesktopSettings WHERE UserId = @UserId)
BEGIN
    INSERT INTO dbo.UserDesktopSettings
    (
        UserId, LoginConfirmMode, KeepChatHistory, StoragePath, AutoDownloadMaxMb, NotificationEnabled,
        ShortcutScheme, PluginEnabled, FriendRequestEnabled, PhoneSearchEnabled, ShowMomentsToStrangers, UseEnterToSend, CreatedAt, UpdatedAt
    )
    VALUES
    (
        @UserId, N'MobileConfirm', 1, N'C:\Users\Aurora\xwechat_files', 20, 1,
        N'Default', 1, 1, 0, 0, 0, GETDATE(), GETDATE()
    );
END;

SELECT TOP 1
    UserId,
    LoginConfirmMode,
    KeepChatHistory,
    StoragePath,
    AutoDownloadMaxMb,
    NotificationEnabled,
    ShortcutScheme,
    PluginEnabled,
    FriendRequestEnabled,
    PhoneSearchEnabled,
    ShowMomentsToStrangers,
    UseEnterToSend
FROM dbo.UserDesktopSettings
WHERE UserId = @UserId;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        return null;
                    }

                    return new UserDesktopSettingsInfo
                    {
                        UserId = Convert.ToInt32(reader["UserId"]),
                        LoginConfirmMode = Convert.ToString(reader["LoginConfirmMode"]),
                        KeepChatHistory = Convert.ToBoolean(reader["KeepChatHistory"]),
                        StoragePath = Convert.ToString(reader["StoragePath"]),
                        AutoDownloadMaxMb = Convert.ToInt32(reader["AutoDownloadMaxMb"]),
                        NotificationEnabled = Convert.ToBoolean(reader["NotificationEnabled"]),
                        ShortcutScheme = Convert.ToString(reader["ShortcutScheme"]),
                        PluginEnabled = Convert.ToBoolean(reader["PluginEnabled"]),
                        FriendRequestEnabled = Convert.ToBoolean(reader["FriendRequestEnabled"]),
                        PhoneSearchEnabled = Convert.ToBoolean(reader["PhoneSearchEnabled"]),
                        ShowMomentsToStrangers = Convert.ToBoolean(reader["ShowMomentsToStrangers"]),
                        UseEnterToSend = Convert.ToBoolean(reader["UseEnterToSend"])
                    };
                }
            }
        }

        public bool SaveDesktopSettings(int userId, UserDesktopSettingsInfo settings, out string message)
        {
            const string sql = @"
IF EXISTS (SELECT 1 FROM dbo.UserDesktopSettings WHERE UserId = @UserId)
BEGIN
    UPDATE dbo.UserDesktopSettings
    SET LoginConfirmMode = @LoginConfirmMode,
        KeepChatHistory = @KeepChatHistory,
        StoragePath = @StoragePath,
        AutoDownloadMaxMb = @AutoDownloadMaxMb,
        NotificationEnabled = @NotificationEnabled,
        ShortcutScheme = @ShortcutScheme,
        PluginEnabled = @PluginEnabled,
        FriendRequestEnabled = @FriendRequestEnabled,
        PhoneSearchEnabled = @PhoneSearchEnabled,
        ShowMomentsToStrangers = @ShowMomentsToStrangers,
        UseEnterToSend = @UseEnterToSend,
        UpdatedAt = GETDATE()
    WHERE UserId = @UserId;
END
ELSE
BEGIN
    INSERT INTO dbo.UserDesktopSettings
    (
        UserId, LoginConfirmMode, KeepChatHistory, StoragePath, AutoDownloadMaxMb, NotificationEnabled,
        ShortcutScheme, PluginEnabled, FriendRequestEnabled, PhoneSearchEnabled, ShowMomentsToStrangers, UseEnterToSend, CreatedAt, UpdatedAt
    )
    VALUES
    (
        @UserId, @LoginConfirmMode, @KeepChatHistory, @StoragePath, @AutoDownloadMaxMb, @NotificationEnabled,
        @ShortcutScheme, @PluginEnabled, @FriendRequestEnabled, @PhoneSearchEnabled, @ShowMomentsToStrangers, @UseEnterToSend, GETDATE(), GETDATE()
    );
END;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@LoginConfirmMode", NullToEmpty(settings.LoginConfirmMode));
                command.Parameters.AddWithValue("@KeepChatHistory", settings.KeepChatHistory);
                command.Parameters.AddWithValue("@StoragePath", NullToEmpty(settings.StoragePath));
                command.Parameters.AddWithValue("@AutoDownloadMaxMb", settings.AutoDownloadMaxMb);
                command.Parameters.AddWithValue("@NotificationEnabled", settings.NotificationEnabled);
                command.Parameters.AddWithValue("@ShortcutScheme", NullToEmpty(settings.ShortcutScheme));
                command.Parameters.AddWithValue("@PluginEnabled", settings.PluginEnabled);
                command.Parameters.AddWithValue("@FriendRequestEnabled", settings.FriendRequestEnabled);
                command.Parameters.AddWithValue("@PhoneSearchEnabled", settings.PhoneSearchEnabled);
                command.Parameters.AddWithValue("@ShowMomentsToStrangers", settings.ShowMomentsToStrangers);
                command.Parameters.AddWithValue("@UseEnterToSend", settings.UseEnterToSend);
                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "桌面端设置已保存。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public UserSettingsInfo GetExtendedUserSettings(int userId)
        {
            const string sql = @"
SELECT TOP 1
    u.Id AS UserId,
    u.Username,
    u.DisplayName,
    ISNULL(u.PublicUserCode, N'') AS PublicUserCode,
    u.Phone,
    u.Email,
    ISNULL(pp.AvatarUrl, N'') AS AvatarUrl,
    ISNULL(pp.FavoriteGenre, N'') AS FavoriteGenre,
    ISNULL(pp.Gender, N'未填写') AS Gender,
    ISNULL(pp.Region, N'未填写') AS Region,
    ISNULL(pp.Signature, N'') AS Signature
FROM dbo.Users u
LEFT JOIN dbo.PlayerProfiles pp ON pp.UserId = u.Id
WHERE u.Id = @UserId;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        return null;
                    }

                    return new UserSettingsInfo
                    {
                        UserId = Convert.ToInt32(reader["UserId"]),
                        Username = Convert.ToString(reader["Username"]),
                        DisplayName = Convert.ToString(reader["DisplayName"]),
                        PublicUserCode = Convert.ToString(reader["PublicUserCode"]),
                        Phone = Convert.ToString(reader["Phone"]),
                        Email = Convert.ToString(reader["Email"]),
                        AvatarUrl = Convert.ToString(reader["AvatarUrl"]),
                        FavoriteGenre = Convert.ToString(reader["FavoriteGenre"]),
                        Gender = Convert.ToString(reader["Gender"]),
                        Region = Convert.ToString(reader["Region"]),
                        Signature = Convert.ToString(reader["Signature"])
                    };
                }
            }
        }

        public bool UpdateExtendedUserSettings(int userId, string displayName, string phone, string avatarUrl, string publicUserCode, string gender, string region, string signature, out string message)
        {
            if (string.IsNullOrWhiteSpace(displayName))
            {
                message = "昵称不能为空。";
                return false;
            }

            const string sql = @"
IF EXISTS (SELECT 1 FROM dbo.Users WHERE PublicUserCode = @PublicUserCode AND Id <> @UserId)
BEGIN
    RAISERROR(N'这个账号 ID 已经被其他玩家使用。', 16, 1);
    RETURN;
END;

UPDATE dbo.Users
SET DisplayName = @DisplayName,
    Phone = @Phone,
    PublicUserCode = @PublicUserCode
WHERE Id = @UserId;

IF EXISTS (SELECT 1 FROM dbo.PlayerProfiles WHERE UserId = @UserId)
BEGIN
    UPDATE dbo.PlayerProfiles
    SET DisplayName = @DisplayName,
        AvatarUrl = @AvatarUrl,
        Gender = @Gender,
        Region = @Region,
        Signature = @Signature
    WHERE UserId = @UserId;
END
ELSE
BEGIN
    INSERT INTO dbo.PlayerProfiles
    (
        UserId, DisplayName, DisplayTitle, Motto, AvatarUrl, FavoriteGenre, JoinDays, CompletedScripts, WinRate, ReputationLevel, Gender, Region, Signature
    )
    VALUES
    (
        @UserId, @DisplayName, N'互动玩家', N'在这里整理自己的社交名片与开本身份。', @AvatarUrl, N'本格推理', 1, 0, 0, N'新秀玩家', @Gender, @Region, @Signature
    );
END;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@DisplayName", displayName.Trim());
                command.Parameters.AddWithValue("@Phone", NullToEmpty(phone));
                command.Parameters.AddWithValue("@AvatarUrl", NullToEmpty(avatarUrl));
                command.Parameters.AddWithValue("@PublicUserCode", NullToEmpty(publicUserCode));
                command.Parameters.AddWithValue("@Gender", NullToEmpty(gender));
                command.Parameters.AddWithValue("@Region", NullToEmpty(region));
                command.Parameters.AddWithValue("@Signature", NullToEmpty(signature));
                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "个人资料已更新。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        private static string NormalizeMessageType(string messageType)
        {
            if (string.IsNullOrWhiteSpace(messageType))
            {
                return "Text";
            }

            switch (messageType.Trim())
            {
                case "Photo":
                case "Location":
                case "Voice":
                case "VideoCall":
                    return messageType.Trim();
                default:
                    return "Text";
            }
        }

        private static string BuildGroupAvatar(string groupName)
        {
            var seed = Math.Abs((groupName ?? "Group").GetHashCode()) % 5;
            switch (seed)
            {
                case 0:
                    return "https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=400&q=80";
                case 1:
                    return "https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&w=400&q=80";
                case 2:
                    return "https://images.unsplash.com/photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=400&q=80";
                case 3:
                    return "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=400&q=80";
                default:
                    return "https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=400&q=80";
            }
        }

        private static string NullToEmpty(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? string.Empty : value.Trim();
        }
    }
}
