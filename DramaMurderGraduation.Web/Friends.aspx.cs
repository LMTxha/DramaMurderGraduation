using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public partial class FriendsPage : System.Web.UI.Page
    {
        private readonly AccountRepository _accountRepository = new AccountRepository();
        private readonly ContentRepository _contentRepository = new ContentRepository();
        private readonly FriendWorkspaceRepository _workspaceRepository = new FriendWorkspaceRepository();
        private const string FriendSearchViewStateKey = "FriendSearch";
        private const string ConversationSearchViewStateKey = "ConversationSearch";
        private const string ReplyMomentViewStateKey = "ReplyMomentId";
        private const string ReplyCommentViewStateKey = "ReplyCommentId";
        private const string ReplyDisplayViewStateKey = "ReplyDisplayName";

        protected FriendChatSummaryInfo SelectedFriendSummary { get; private set; }
        protected UserSettingsInfo CurrentUserProfile { get; private set; } = new UserSettingsInfo();
        protected UserDesktopSettingsInfo CurrentDesktopSettings { get; private set; } = new UserDesktopSettingsInfo();
        protected int GroupConversationCount { get; private set; }
        protected int ServiceAccountCount { get; private set; }
        protected bool HasSelectedFriend => SelectedFriendSummary != null;
        protected bool HasReplyTarget => ReplyMomentId.HasValue && ReplyCommentId.HasValue && !string.IsNullOrWhiteSpace(ReplyTargetDisplayName);
        protected bool HasPendingFriendRequests { get; private set; }
        protected string ReplyTargetDisplayName => Convert.ToString(ViewState[ReplyDisplayViewStateKey]);
        protected string ActiveWorkspaceMode => (Request.QueryString["mode"] ?? "chat").Trim().ToLowerInvariant();
        protected bool IsContactsView => ActiveWorkspaceMode == "contacts";
        protected bool IsSettingsView => ActiveWorkspaceMode == "settings";
        protected bool IsMomentsView => ActiveWorkspaceMode == "moments";
        protected bool IsWalletView => ActiveWorkspaceMode == "wallet";
        private string FriendSearchKeyword
        {
            get => Convert.ToString(ViewState[FriendSearchViewStateKey]) ?? string.Empty;
            set => ViewState[FriendSearchViewStateKey] = value ?? string.Empty;
        }

        private string ConversationSearchKeyword
        {
            get => Convert.ToString(ViewState[ConversationSearchViewStateKey]) ?? string.Empty;
            set => ViewState[ConversationSearchViewStateKey] = value ?? string.Empty;
        }

        private int? ReplyMomentId
        {
            get => ViewState[ReplyMomentViewStateKey] == null ? (int?)null : Convert.ToInt32(ViewState[ReplyMomentViewStateKey]);
            set => ViewState[ReplyMomentViewStateKey] = value;
        }

        private int? ReplyCommentId
        {
            get => ViewState[ReplyCommentViewStateKey] == null ? (int?)null : Convert.ToInt32(ViewState[ReplyCommentViewStateKey]);
            set => ViewState[ReplyCommentViewStateKey] = value;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Page.Form != null)
            {
                Page.Form.Enctype = "multipart/form-data";
            }

            AuthManager.RequireLogin();

            LoadSelectionState();

            if (!IsPostBack)
            {
                BindPage();
            }
        }

        protected void btnSearchFriends_Click(object sender, EventArgs e)
        {
            FriendSearchKeyword = txtFriendSearch.Text.Trim();
            BindPage();
        }

        protected void btnClearFriendSearch_Click(object sender, EventArgs e)
        {
            FriendSearchKeyword = string.Empty;
            txtFriendSearch.Text = string.Empty;
            BindPage();
        }

        protected void btnSearchConversation_Click(object sender, EventArgs e)
        {
            ConversationSearchKeyword = txtConversationSearch.Text.Trim();
            BindPage();
        }

        protected void btnClearConversationSearch_Click(object sender, EventArgs e)
        {
            ConversationSearchKeyword = string.Empty;
            txtConversationSearch.Text = string.Empty;
            BindPage();
        }

        protected void btnCancelReply_Click(object sender, EventArgs e)
        {
            ClearReplyTarget();
            pnlMomentMessage.Visible = true;
            ShowMessage(pnlMomentMessage, litMomentMessage, "已退出评论回复模式。", true);
            BindPage();
        }

        protected void btnSendFriendRequest_Click(object sender, EventArgs e)
        {
            pnlFriendMessage.Visible = true;

            if (!int.TryParse(ddlFriendCandidate.SelectedValue, out var receiverUserId) || receiverUserId <= 0)
            {
                ShowMessage(pnlFriendMessage, litFriendMessage, "请选择要添加的玩家。", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _accountRepository.SendFriendRequest(currentUser.UserId, receiverUserId, txtFriendRequestMessage.Text.Trim(), out var message);
            ShowMessage(pnlFriendMessage, litFriendMessage, message, success);
            if (success)
            {
                txtFriendRequestMessage.Text = string.Empty;
            }

            BindPage();
        }

        protected void btnSendFriendRequestByCode_Click(object sender, EventArgs e)
        {
            pnlFriendMessage.Visible = true;

            if (string.IsNullOrWhiteSpace(txtFriendAccountId.Text))
            {
                ShowMessage(pnlFriendMessage, litFriendMessage, "请输入对方的账号 ID。", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _accountRepository.SendFriendRequestByPublicId(currentUser.UserId, txtFriendAccountId.Text.Trim(), txtFriendRequestMessage.Text.Trim(), out var message);
            ShowMessage(pnlFriendMessage, litFriendMessage, message, success);
            if (success)
            {
                txtFriendAccountId.Text = string.Empty;
                txtFriendRequestMessage.Text = string.Empty;
            }

            BindPage();
        }

        protected void btnCreateGroup_Click(object sender, EventArgs e)
        {
            pnlGroupMessage.Visible = true;

            var memberIds = new List<int>();
            foreach (ListItem item in cblGroupMembers.Items)
            {
                if (item.Selected && int.TryParse(item.Value, out var userId))
                {
                    memberIds.Add(userId);
                }
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _workspaceRepository.CreateChatGroup(
                currentUser.UserId,
                txtGroupName.Text.Trim(),
                txtGroupAnnouncement.Text.Trim(),
                memberIds,
                out var message);

            ShowMessage(pnlGroupMessage, litGroupMessage, message, success);
            if (success)
            {
                txtGroupName.Text = string.Empty;
                txtGroupAnnouncement.Text = string.Empty;
                cblGroupMembers.ClearSelection();
            }

            BindPage();
        }

        protected void btnCreateQuickNote_Click(object sender, EventArgs e)
        {
            pnlQuickNoteMessage.Visible = true;

            var currentUser = AuthManager.GetCurrentUser();
            var success = _workspaceRepository.CreateQuickNote(
                currentUser.UserId,
                txtQuickNoteTitle.Text.Trim(),
                txtQuickNoteContent.Text.Trim(),
                out var message);

            ShowMessage(pnlQuickNoteMessage, litQuickNoteMessage, message, success);
            if (success)
            {
                txtQuickNoteTitle.Text = string.Empty;
                txtQuickNoteContent.Text = string.Empty;
            }

            BindPage();
        }

        protected void btnLogoutFromFriends_Click(object sender, EventArgs e)
        {
            AuthManager.SignOut();
            Response.Redirect("~/Login.aspx", true);
        }

        protected void rptIncomingFriendRequests_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            pnlFriendMessage.Visible = true;
            var parts = Convert.ToString(e.CommandArgument).Split('|');
            if (parts.Length == 0 || !int.TryParse(parts[0], out var requestId))
            {
                ShowMessage(pnlFriendMessage, litFriendMessage, "未找到对应的好友申请。", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var approved = string.Equals(e.CommandName, "Accept", StringComparison.OrdinalIgnoreCase);
            var success = _accountRepository.ReviewFriendRequest(requestId, currentUser.UserId, approved, out var message);
            ShowMessage(pnlFriendMessage, litFriendMessage, message, success);
            if (success && approved && parts.Length > 1 && int.TryParse(parts[1], out var senderUserId))
            {
                Response.Redirect("~/Friends.aspx?friendId=" + senderUserId + "#chat-panel", true);
                return;
            }

            BindPage();
        }

        protected void btnSendChatMessage_Click(object sender, EventArgs e)
        {
            pnlChatMessage.Visible = true;

            if (!HasSelectedFriend)
            {
                ShowMessage(pnlChatMessage, litChatMessage, "请先选择一个好友再发送消息。", false);
                return;
            }

            var messageType = ddlChatMessageType.SelectedValue;
            var content = txtChatContent.Text.Trim();
            var locationText = txtChatLocation.Text.Trim();

            if (!UploadHelper.TrySave(fuChatAttachment, "chat", out var uploadedUrl, out var uploadError))
            {
                ShowMessage(pnlChatMessage, litChatMessage, uploadError, false);
                return;
            }

            var attachmentUrl = string.IsNullOrWhiteSpace(uploadedUrl) ? txtChatAttachmentUrl.Text.Trim() : uploadedUrl;

            if (messageType == "VideoCall" && string.IsNullOrWhiteSpace(content))
            {
                content = "发起了一次视频通话邀请，方便你们在开本前先碰一下。";
            }
            else if (messageType == "Voice" && string.IsNullOrWhiteSpace(content))
            {
                content = "发来一条语音留言。";
            }
            else if (messageType == "Location" && string.IsNullOrWhiteSpace(locationText))
            {
                locationText = "门店前台 / 剧本杀大厅";
            }
            else if (messageType == "Photo" && string.IsNullOrWhiteSpace(content))
            {
                content = "分享了一张照片。";
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _accountRepository.SendFriendMessage(currentUser.UserId, SelectedFriendSummary.FriendUserId, messageType, content, attachmentUrl, locationText, out var message);
            ShowMessage(pnlChatMessage, litChatMessage, message, success);
            if (success)
            {
                txtChatContent.Text = string.Empty;
                txtChatAttachmentUrl.Text = string.Empty;
                txtChatLocation.Text = string.Empty;
            }

            BindPage();
        }

        protected void btnSendGift_Click(object sender, EventArgs e)
        {
            pnlGiftMessage.Visible = true;

            if (!int.TryParse(ddlGiftReceiver.SelectedValue, out var receiverUserId) || receiverUserId <= 0)
            {
                ShowMessage(pnlGiftMessage, litGiftMessage, "请选择收礼好友。", false);
                return;
            }

            if (!int.TryParse(ddlGiftCatalog.SelectedValue, out var giftId) || giftId <= 0)
            {
                ShowMessage(pnlGiftMessage, litGiftMessage, "请选择礼物。", false);
                return;
            }

            if (!int.TryParse(txtGiftQuantity.Text, out var quantity) || quantity <= 0 || quantity > 99)
            {
                ShowMessage(pnlGiftMessage, litGiftMessage, "礼物数量请输入 1 到 99 之间的整数。", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _accountRepository.SendGift(currentUser.UserId, receiverUserId, giftId, quantity, out var message);
            ShowMessage(pnlGiftMessage, litGiftMessage, message, success);
            BindPage();
        }

        protected void btnSendTransfer_Click(object sender, EventArgs e)
        {
            pnlTransferMessage.Visible = true;

            if (!int.TryParse(ddlTransferReceiver.SelectedValue, out var receiverUserId) || receiverUserId <= 0)
            {
                ShowMessage(pnlTransferMessage, litTransferMessage, "请选择接收好友。", false);
                return;
            }

            if (!decimal.TryParse(txtTransferAmount.Text, out var amount) || amount <= 0)
            {
                ShowMessage(pnlTransferMessage, litTransferMessage, "请输入正确的金额。", false);
                return;
            }

            amount = decimal.Round(amount, 2, MidpointRounding.AwayFromZero);
            if (amount > 20000M)
            {
                ShowMessage(pnlTransferMessage, litTransferMessage, "单笔金额不能超过 20000 元。", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _accountRepository.SendPeerTransfer(currentUser.UserId, receiverUserId, amount, ddlTransferType.SelectedValue, txtTransferNote.Text.Trim(), out var message);
            ShowMessage(pnlTransferMessage, litTransferMessage, message, success);
            if (success)
            {
                txtTransferAmount.Text = "6.60";
                txtTransferNote.Text = string.Empty;
            }

            BindPage();
        }

        protected void btnCreateMoment_Click(object sender, EventArgs e)
        {
            pnlMomentMessage.Visible = true;

            var currentUser = AuthManager.GetCurrentUser();
            if (!UploadHelper.TrySave(fuMomentImage, "moments", out var uploadedImageUrl, out var uploadError))
            {
                ShowMessage(pnlMomentMessage, litMomentMessage, uploadError, false);
                return;
            }

            var imageUrl = string.IsNullOrWhiteSpace(uploadedImageUrl) ? txtMomentImageUrl.Text.Trim() : uploadedImageUrl;
            var success = _accountRepository.CreateMoment(currentUser.UserId, txtMomentContent.Text.Trim(), imageUrl, txtMomentLocation.Text.Trim(), ddlMomentVisibility.SelectedValue, out var message);
            ShowMessage(pnlMomentMessage, litMomentMessage, message, success);
            if (success)
            {
                txtMomentContent.Text = string.Empty;
                txtMomentImageUrl.Text = string.Empty;
                txtMomentLocation.Text = string.Empty;
                SelectListItemIfExists(ddlMomentVisibility, "Friends");
            }

            BindPage();
        }

        protected void btnRemoveFriend_Click(object sender, EventArgs e)
        {
            pnlFriendMessage.Visible = true;

            if (!HasSelectedFriend)
            {
                ShowMessage(pnlFriendMessage, litFriendMessage, "当前没有可解除的好友。", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _accountRepository.RemoveFriend(currentUser.UserId, SelectedFriendSummary.FriendUserId, out var message);
            ShowMessage(pnlFriendMessage, litFriendMessage, message, success);

            if (success)
            {
                Response.Redirect("~/Friends.aspx");
                return;
            }

            BindPage();
        }

        protected void btnBlockFriend_Click(object sender, EventArgs e)
        {
            pnlFriendMessage.Visible = true;

            if (!HasSelectedFriend)
            {
                ShowMessage(pnlFriendMessage, litFriendMessage, "当前没有可拉黑的好友。", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _accountRepository.BlockUser(currentUser.UserId, SelectedFriendSummary.FriendUserId, out var message);
            ShowMessage(pnlFriendMessage, litFriendMessage, message, success);

            if (success)
            {
                Response.Redirect("~/Friends.aspx");
                return;
            }

            BindPage();
        }

        protected void btnTogglePinConversation_Click(object sender, EventArgs e)
        {
            pnlChatMessage.Visible = true;

            if (!HasSelectedFriend)
            {
                ShowMessage(pnlChatMessage, litChatMessage, "当前没有可置顶的好友会话。", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var targetPinned = !SelectedFriendSummary.IsPinned;
            var success = _accountRepository.SetConversationPinned(currentUser.UserId, SelectedFriendSummary.FriendUserId, targetPinned, out var message);
            ShowMessage(pnlChatMessage, litChatMessage, message, success);
            BindPage();
        }

        protected void btnHideConversation_Click(object sender, EventArgs e)
        {
            pnlChatMessage.Visible = true;

            if (!HasSelectedFriend)
            {
                ShowMessage(pnlChatMessage, litChatMessage, "当前没有可隐藏的好友会话。", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _accountRepository.SetConversationHidden(currentUser.UserId, SelectedFriendSummary.FriendUserId, true, out var message);
            ShowMessage(pnlChatMessage, litChatMessage, message, success);
            if (success)
            {
                Response.Redirect("~/Friends.aspx");
                return;
            }

            BindPage();
        }

        protected void rptHiddenFriendSummaries_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            pnlFriendMessage.Visible = true;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out var friendUserId))
            {
                ShowMessage(pnlFriendMessage, litFriendMessage, "未找到要恢复的隐藏会话。", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _accountRepository.SetConversationHidden(currentUser.UserId, friendUserId, false, out var message);
            ShowMessage(pnlFriendMessage, litFriendMessage, message, success);
            BindPage();
        }

        protected void btnSendGameInvite_Click(object sender, EventArgs e)
        {
            pnlChatMessage.Visible = true;

            if (!HasSelectedFriend)
            {
                ShowMessage(pnlChatMessage, litChatMessage, "请先选中一个好友，再发起开本邀请。", false);
                return;
            }

            if (!int.TryParse(ddlInviteScript.SelectedValue, out var scriptId) || scriptId <= 0)
            {
                ShowMessage(pnlChatMessage, litChatMessage, "请选择要邀请的剧本。", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _accountRepository.SendGameInvite(currentUser.UserId, SelectedFriendSummary.FriendUserId, scriptId, out var message);
            ShowMessage(pnlChatMessage, litChatMessage, message, success);
            BindPage();
        }

        protected void rptMoments_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            pnlMomentMessage.Visible = true;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out var momentId))
            {
                ShowMessage(pnlMomentMessage, litMomentMessage, "未找到对应动态。", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = false;
            string message;

            if (string.Equals(e.CommandName, "Comment", StringComparison.OrdinalIgnoreCase))
            {
                var txtComment = e.Item.FindControl("txtMomentComment") as TextBox;
                var parentCommentId = HasReplyTarget && ReplyMomentId == momentId ? ReplyCommentId : (int?)null;
                success = _accountRepository.AddMomentComment(currentUser.UserId, momentId, txtComment == null ? string.Empty : txtComment.Text.Trim(), parentCommentId, out message);
                if (success)
                {
                    ClearReplyTarget();
                }
            }
            else if (string.Equals(e.CommandName, "ReplyComment", StringComparison.OrdinalIgnoreCase))
            {
                var parts = Convert.ToString(e.CommandArgument).Split('|');
                if (parts.Length >= 3 && int.TryParse(parts[0], out var replyCommentId) && int.TryParse(parts[1], out var replyMomentId))
                {
                    ReplyCommentId = replyCommentId;
                    ReplyMomentId = replyMomentId;
                    ViewState[ReplyDisplayViewStateKey] = parts[2];
                    ShowMessage(pnlMomentMessage, litMomentMessage, "已切换到评论回复模式。", true);
                    BindPage();
                    return;
                }

                success = false;
                message = "未找到要回复的评论。";
            }
            else if (string.Equals(e.CommandName, "DeleteMoment", StringComparison.OrdinalIgnoreCase))
            {
                success = _accountRepository.DeleteMoment(currentUser.UserId, momentId, out message);
                if (success)
                {
                    ClearReplyTarget();
                }
            }
            else
            {
                success = _accountRepository.ToggleMomentLike(currentUser.UserId, momentId, out message);
            }

            ShowMessage(pnlMomentMessage, litMomentMessage, message, success);
            BindPage();
        }

        protected void rptMomentComments_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            pnlMomentMessage.Visible = true;
            var currentUser = AuthManager.GetCurrentUser();

            if (string.Equals(e.CommandName, "ReplyComment", StringComparison.OrdinalIgnoreCase))
            {
                var parts = Convert.ToString(e.CommandArgument).Split('|');
                if (parts.Length >= 3 && int.TryParse(parts[0], out var replyCommentId) && int.TryParse(parts[1], out var replyMomentId))
                {
                    ReplyCommentId = replyCommentId;
                    ReplyMomentId = replyMomentId;
                    ViewState[ReplyDisplayViewStateKey] = parts[2];
                    ShowMessage(pnlMomentMessage, litMomentMessage, "已切换到评论回复模式。", true);
                    BindPage();
                    return;
                }

                ShowMessage(pnlMomentMessage, litMomentMessage, "未找到要回复的评论。", false);
                return;
            }

            if (!string.Equals(e.CommandName, "DeleteComment", StringComparison.OrdinalIgnoreCase) ||
                !int.TryParse(Convert.ToString(e.CommandArgument), out var commentId))
            {
                ShowMessage(pnlMomentMessage, litMomentMessage, "未找到对应评论。", false);
                return;
            }

            var success = _accountRepository.DeleteMomentComment(currentUser.UserId, commentId, out var message);
            ShowMessage(pnlMomentMessage, litMomentMessage, message, success);
            BindPage();
        }

        protected void rptBlockedUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            pnlFriendMessage.Visible = true;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out var blockedUserId))
            {
                ShowMessage(pnlFriendMessage, litFriendMessage, "未找到对应黑名单记录。", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _accountRepository.UnblockUser(currentUser.UserId, blockedUserId, out var message);
            ShowMessage(pnlFriendMessage, litFriendMessage, message, success);
            BindPage();
        }

        protected void rptConversation_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            pnlChatMessage.Visible = true;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out var messageId))
            {
                ShowMessage(pnlChatMessage, litChatMessage, "未找到对应消息。", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _accountRepository.RevokeFriendMessage(currentUser.UserId, messageId, out var message);
            ShowMessage(pnlChatMessage, litChatMessage, message, success);
            BindPage();
        }

        protected void rptMoments_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
            {
                return;
            }

            var moment = e.Item.DataItem as MomentPostInfo;
            var repeater = e.Item.FindControl("rptMomentComments") as Repeater;
            if (moment == null || repeater == null)
            {
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var comments = _accountRepository.GetMomentComments(currentUser.UserId, moment.Id, 20);
            repeater.DataSource = BuildCommentThread(comments);
            repeater.DataBind();
        }

        public string GetFriendItemCss(object friendUserId)
        {
            return SelectedFriendSummary != null && SafeToInt(friendUserId) == SelectedFriendSummary.FriendUserId
                ? "wechat-chat-row active"
                : "wechat-chat-row";
        }

        public string GetFriendLink(object friendUserId)
        {
            return "Friends.aspx?friendId=" + SafeToInt(friendUserId) + "#chat-panel";
        }

        public string GetFriendProfileLink(object friendUserId)
        {
            return "FriendProfile.aspx?friendId=" + SafeToInt(friendUserId);
        }

        public string GetModeCss(string mode)
        {
            var normalizedMode = string.IsNullOrWhiteSpace(mode) ? "chat" : mode.Trim().ToLowerInvariant();
            return ActiveWorkspaceMode == normalizedMode ? "active" : string.Empty;
        }

        public string GetWorkbenchModeCss()
        {
            return "wechat-mode-" + ActiveWorkspaceMode;
        }

        public string GetCurrentDisplayName()
        {
            if (!string.IsNullOrWhiteSpace(CurrentUserProfile.DisplayName))
            {
                return CurrentUserProfile.DisplayName;
            }

            var currentUser = AuthManager.GetCurrentUser();
            return currentUser == null ? "玩家" : currentUser.DisplayName;
        }

        public string GetCurrentPublicCode()
        {
            if (!string.IsNullOrWhiteSpace(CurrentUserProfile.PublicUserCode))
            {
                return CurrentUserProfile.PublicUserCode;
            }

            var currentUser = AuthManager.GetCurrentUser();
            return currentUser == null ? string.Empty : currentUser.PublicUserCode;
        }

        public string GetCurrentAvatarUrl()
        {
            return GetAvatarUrl(CurrentUserProfile.AvatarUrl);
        }

        public string GetMessageAvatarUrl(object senderUserId)
        {
            var currentUser = AuthManager.GetCurrentUser();
            if (currentUser != null && SafeToInt(senderUserId) == currentUser.UserId)
            {
                return GetCurrentAvatarUrl();
            }

            return HasSelectedFriend ? GetAvatarUrl(SelectedFriendSummary.AvatarUrl) : GetAvatarUrl(string.Empty);
        }

        public string GetPinButtonText()
        {
            return HasSelectedFriend && SelectedFriendSummary.IsPinned ? "取消置顶" : "置顶会话";
        }

        public string GetChatBubbleClass(object senderUserId)
        {
            return SafeToInt(senderUserId) == AuthManager.GetCurrentUser().UserId
                ? "chat-message-bubble outgoing"
                : "chat-message-bubble incoming";
        }

        public string GetMessageTypeLabel(object value)
        {
            switch (Convert.ToString(value))
            {
                case "Gift":
                    return "礼物";
                case "Photo":
                    return "照片";
                case "Location":
                    return "位置";
                case "Voice":
                    return "语音";
                case "VideoCall":
                    return "视频通话";
                case "RedPacket":
                    return "红包";
                case "Transfer":
                    return "转账";
                default:
                    return "文字";
            }
        }

        public bool CanRevokeMessage(object senderUserId, object isRevoked)
        {
            return SafeToInt(senderUserId) == AuthManager.GetCurrentUser().UserId && !(isRevoked != null && isRevoked != DBNull.Value && Convert.ToBoolean(isRevoked));
        }

        public string GetChatBody(object content, object isRevoked)
        {
            if (isRevoked != null && isRevoked != DBNull.Value && Convert.ToBoolean(isRevoked))
            {
                return "这条消息已被撤回。";
            }

            return Convert.ToString(content);
        }

        public string GetAvatarUrl(object avatarUrl)
        {
            var value = Convert.ToString(avatarUrl)?.Trim();
            if (string.IsNullOrWhiteSpace(value))
            {
                return "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80";
            }

            if (value.StartsWith("~/", StringComparison.Ordinal))
            {
                return ResolveUrl(value);
            }

            if (value.StartsWith("/", StringComparison.Ordinal) || Uri.IsWellFormedUriString(value, UriKind.Absolute))
            {
                return value;
            }

            return ResolveUrl("~/" + value.TrimStart('/'));
        }

        public IHtmlString RenderReplyTarget(object replyToDisplayName)
        {
            var value = Convert.ToString(replyToDisplayName);
            if (string.IsNullOrWhiteSpace(value))
            {
                return new HtmlString(string.Empty);
            }

            return new HtmlString("<span class=\"reply-target\">回复 @" + HttpUtility.HtmlEncode(value) + "</span>");
        }

        public string GetMomentCommentCss(object replyDepth)
        {
            var depth = Math.Max(0, SafeToInt(replyDepth));
            return depth <= 0 ? "moment-comment" : "moment-comment reply-depth-" + Math.Min(depth, 3);
        }

        public string FormatChatSummaryTime(object value)
        {
            if (value == null || value == DBNull.Value)
            {
                return "刚成为好友";
            }

            return Convert.ToDateTime(value).ToString("MM-dd HH:mm");
        }

        public IHtmlString RenderUnreadBadge(object unreadCount)
        {
            var count = SafeToInt(unreadCount);
            if (count <= 0)
            {
                return new HtmlString(string.Empty);
            }

            return new HtmlString("<span class=\"badge-inline unread-badge\">未读 " + count + "</span>");
        }

        public string GetFriendRequestCommandArgument(object requestId, object senderUserId)
        {
            return SafeToInt(requestId) + "|" + SafeToInt(senderUserId);
        }

        public string GetMomentLikeButtonText(object isLiked, object likeCount)
        {
            var liked = isLiked != null && isLiked != DBNull.Value && Convert.ToBoolean(isLiked);
            return (liked ? "已点赞 " : "点赞 ") + SafeToInt(likeCount);
        }

        public string GetMomentVisibilityLabel(object visibility)
        {
            switch (Convert.ToString(visibility))
            {
                case "Public":
                    return "公开";
                case "Private":
                    return "仅自己";
                default:
                    return "仅好友";
            }
        }

        public bool CanDeleteOwnContent(object userId)
        {
            var currentUser = AuthManager.GetCurrentUser();
            return currentUser != null && SafeToInt(userId) == currentUser.UserId;
        }

        public string GetTransferLabel(object transferType)
        {
            return string.Equals(Convert.ToString(transferType), "RedPacket", StringComparison.OrdinalIgnoreCase) ? "红包" : "转账";
        }

        public string GetTransferRecordClass(object transferType)
        {
            return string.Equals(Convert.ToString(transferType), "RedPacket", StringComparison.OrdinalIgnoreCase)
                ? "wx-request-card wx-transfer-record redpacket"
                : "wx-request-card wx-transfer-record transfer";
        }

        public string HtmlEncode(object value)
        {
            return HttpUtility.HtmlEncode(Convert.ToString(value));
        }

        public IHtmlString RenderHighlightedPreview(object preview)
        {
            return new HtmlString(HighlightKeyword(Convert.ToString(preview), FriendSearchKeyword));
        }

        public IHtmlString RenderHighlightedChatBody(object content, object isRevoked)
        {
            return new HtmlString(HighlightKeyword(GetChatBody(content, isRevoked), ConversationSearchKeyword));
        }

        public IHtmlString RenderChatMessageContent(object messageType, object content, object isRevoked)
        {
            if (isRevoked != null && isRevoked != DBNull.Value && Convert.ToBoolean(isRevoked))
            {
                return new HtmlString("<p>\u8fd9\u6761\u6d88\u606f\u5df2\u88ab\u64a4\u56de\u3002</p>");
            }

            var type = Convert.ToString(messageType);
            if (string.Equals(type, "RedPacket", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(type, "Transfer", StringComparison.OrdinalIgnoreCase))
            {
                var rawContent = Convert.ToString(content);
                var amountText = ExtractMoneyAmount(rawContent);
                var label = string.Equals(type, "RedPacket", StringComparison.OrdinalIgnoreCase) ? "\u5fae\u4fe1\u7ea2\u5305" : "\u5fae\u4fe1\u8f6c\u8d26";
                var status = string.Equals(type, "RedPacket", StringComparison.OrdinalIgnoreCase) ? "\u5df2\u5b58\u5165\u5bf9\u65b9\u4f59\u989d" : "\u5df2\u8f6c\u5165\u5bf9\u65b9\u4f59\u989d";
                var css = string.Equals(type, "RedPacket", StringComparison.OrdinalIgnoreCase) ? "redpacket" : "transfer";
                var note = StripMoneyPrefix(rawContent);
                if (string.IsNullOrWhiteSpace(note))
                {
                    note = string.Equals(type, "RedPacket", StringComparison.OrdinalIgnoreCase) ? "\u7ea2" : "\u8f6c";
                }

                return new HtmlString(
                    "<div class=\"wx-money-message " + css + "\">" +
                    "<p class=\"wx-money-note\">" + HighlightKeyword(note, ConversationSearchKeyword) + "</p>" +
                    "<p class=\"wx-money-title\"><strong>" + HttpUtility.HtmlEncode(label) + "</strong><span>\uffe5 " + HttpUtility.HtmlEncode(amountText) + "</span></p>" +
                    "<p class=\"wx-money-status\">" + HttpUtility.HtmlEncode(status) + "</p>" +
                    "</div>");
            }

            return new HtmlString("<p>" + HighlightKeyword(GetChatBody(content, isRevoked), ConversationSearchKeyword) + "</p>");
        }

        private static string ExtractMoneyAmount(string content)
        {
            var match = Regex.Match(content ?? string.Empty, @"(\d+(?:\.\d{1,2})?)");
            return match.Success ? match.Groups[1].Value : "0.00";
        }

        private static string StripMoneyPrefix(string content)
        {
            var value = content ?? string.Empty;
            var separatorIndex = value.IndexOf('\u00b7');
            if (separatorIndex >= 0 && separatorIndex + 1 < value.Length)
            {
                return value.Substring(separatorIndex + 1).Trim();
            }

            return string.Empty;
        }

        public IHtmlString RenderHighlightedChatLocation(object locationText)
        {
            var value = Convert.ToString(locationText);
            if (string.IsNullOrWhiteSpace(value))
            {
                return new HtmlString(string.Empty);
            }

            return new HtmlString("<p class=\"chat-location\">位置：" + HighlightKeyword(value, ConversationSearchKeyword) + "</p>");
        }

        public IHtmlString RenderChatAttachment(object attachmentUrl)
        {
            var value = Convert.ToString(attachmentUrl);
            if (string.IsNullOrWhiteSpace(value))
            {
                return new HtmlString(string.Empty);
            }

            var safeUrl = HttpUtility.HtmlAttributeEncode(value);
            return new HtmlString("<p class=\"chat-attachment\"><a class=\"text-link strong\" href=\"" + safeUrl + "\" target=\"_blank\" rel=\"noopener\">查看照片 / 附件</a></p>");
        }

        public IHtmlString RenderChatLocation(object locationText)
        {
            var value = Convert.ToString(locationText);
            if (string.IsNullOrWhiteSpace(value))
            {
                return new HtmlString(string.Empty);
            }

            return new HtmlString("<p class=\"chat-location\">位置：" + HttpUtility.HtmlEncode(value) + "</p>");
        }

        public IHtmlString RenderMomentImage(object imageUrl)
        {
            var value = Convert.ToString(imageUrl);
            if (string.IsNullOrWhiteSpace(value))
            {
                return new HtmlString(string.Empty);
            }

            return new HtmlString("<img class=\"moment-image\" src=\"" + HttpUtility.HtmlAttributeEncode(value) + "\" alt=\"朋友圈配图\" />");
        }

        public IHtmlString RenderMomentLocation(object locationText)
        {
            var value = Convert.ToString(locationText);
            if (string.IsNullOrWhiteSpace(value))
            {
                return new HtmlString(string.Empty);
            }

            return new HtmlString("<p class=\"chat-location\">打卡位置：" + HttpUtility.HtmlEncode(value) + "</p>");
        }

        private void LoadSelectionState()
        {
            var currentUser = AuthManager.GetCurrentUser();
            var summaries = _accountRepository.GetFriendChatSummaries(currentUser.UserId);
            SelectedFriendSummary = ResolveSelectedFriendSummary(summaries);
        }

        private void BindPage()
        {
            var currentUser = AuthManager.GetCurrentUser();
            CurrentUserProfile = _workspaceRepository.GetExtendedUserSettings(currentUser.UserId) ?? _accountRepository.GetUserSettings(currentUser.UserId) ?? new UserSettingsInfo
            {
                UserId = currentUser.UserId,
                Username = currentUser.Username,
                DisplayName = currentUser.DisplayName,
                PublicUserCode = currentUser.PublicUserCode,
                Phone = currentUser.Phone,
                Email = string.Empty
            };

            CurrentDesktopSettings = _workspaceRepository.GetDesktopSettings(currentUser.UserId) ?? new UserDesktopSettingsInfo
            {
                UserId = currentUser.UserId,
                LoginConfirmMode = "MobileConfirm",
                KeepChatHistory = true,
                StoragePath = @"C:\Users\Aurora\xwechat_files",
                AutoDownloadMaxMb = 20,
                NotificationEnabled = true,
                PluginEnabled = true,
                FriendRequestEnabled = true
            };

            var hiddenIds = _accountRepository.GetHiddenFriendIds(currentUser.UserId);
            var friendSummaries = _accountRepository.GetFriendChatSummaries(currentUser.UserId)
                .Where(item => !hiddenIds.Contains(item.FriendUserId))
                .ToList();
            var hiddenSummaries = BuildHiddenSummaries(currentUser.UserId);
            var contactFriends = _accountRepository.GetFriends(currentUser.UserId)
                .OrderBy(item => item.DisplayName)
                .ThenBy(item => item.UserId)
                .ToList();
            var chatGroups = _workspaceRepository.GetChatGroups(currentUser.UserId)
                .Where(item => !item.IsHidden)
                .ToList();
            var pinnedFriendIds = _accountRepository.GetPinnedFriendIds(currentUser.UserId);
            foreach (var summary in friendSummaries)
            {
                summary.IsPinned = pinnedFriendIds.Contains(summary.FriendUserId);
            }

            if (!string.IsNullOrWhiteSpace(FriendSearchKeyword))
            {
                friendSummaries = friendSummaries
                    .Where(item =>
                        (item.DisplayName ?? string.Empty).IndexOf(FriendSearchKeyword, StringComparison.OrdinalIgnoreCase) >= 0 ||
                        (item.LastMessagePreview ?? string.Empty).IndexOf(FriendSearchKeyword, StringComparison.OrdinalIgnoreCase) >= 0)
                    .ToList();
            }

            friendSummaries = OrderFriendSummaries(friendSummaries);
            var selectedFriend = ResolveSelectedFriendSummary(friendSummaries);
            if (selectedFriend != null)
            {
                _accountRepository.MarkConversationAsRead(currentUser.UserId, selectedFriend.FriendUserId);
                friendSummaries = _accountRepository.GetFriendChatSummaries(currentUser.UserId)
                    .Where(item => !hiddenIds.Contains(item.FriendUserId))
                    .ToList();
                foreach (var summary in friendSummaries)
                {
                    summary.IsPinned = pinnedFriendIds.Contains(summary.FriendUserId);
                }
                if (!string.IsNullOrWhiteSpace(FriendSearchKeyword))
                {
                    friendSummaries = friendSummaries
                        .Where(item =>
                            (item.DisplayName ?? string.Empty).IndexOf(FriendSearchKeyword, StringComparison.OrdinalIgnoreCase) >= 0 ||
                            (item.LastMessagePreview ?? string.Empty).IndexOf(FriendSearchKeyword, StringComparison.OrdinalIgnoreCase) >= 0)
                        .ToList();
                }
                friendSummaries = OrderFriendSummaries(friendSummaries);
                selectedFriend = ResolveSelectedFriendSummary(friendSummaries);
            }

            var incomingRequests = _accountRepository.GetIncomingFriendRequests(currentUser.UserId);
            HasPendingFriendRequests = incomingRequests.Count > 0;
            var momentFeed = _accountRepository.GetMomentFeed(currentUser.UserId, 20);
            var blockedUsers = _accountRepository.GetBlockedUsers(currentUser.UserId);

            SelectedFriendSummary = selectedFriend;
            if (HasSelectedFriend)
            {
                btnTogglePinConversation.Text = GetPinButtonText();
            }

            litFriendCount.Text = (friendSummaries.Count + hiddenSummaries.Count).ToString();
            litFriendCountCard.Text = friendSummaries.Count.ToString();
            litPendingRequestCount.Text = incomingRequests.Count.ToString();
            litPendingRequestCountCard.Text = incomingRequests.Count.ToString();
            litContactFriendTotal.Text = (friendSummaries.Count + hiddenSummaries.Count).ToString();
            litContactRequestTotal.Text = incomingRequests.Count.ToString();
            litChatSummaryCount.Text = friendSummaries.Count.ToString();
            litMomentCount.Text = momentFeed.Count.ToString();
            litMomentCountCard.Text = momentFeed.Count.ToString();
            GroupConversationCount = chatGroups.Count;
            ServiceAccountCount = _accountRepository.GetSuggestedFriends(currentUser.UserId, 50).Count;

            txtFriendSearch.Text = FriendSearchKeyword;
            txtConversationSearch.Text = ConversationSearchKeyword;

            rptFriendSummaries.DataSource = friendSummaries;
            rptFriendSummaries.DataBind();

            rptHiddenFriendSummaries.DataSource = hiddenSummaries;
            rptHiddenFriendSummaries.DataBind();

            rptContactFriends.DataSource = contactFriends;
            rptContactFriends.DataBind();

            rptChatGroups.DataSource = chatGroups;
            rptChatGroups.DataBind();

            rptIncomingFriendRequests.DataSource = incomingRequests;
            rptIncomingFriendRequests.DataBind();

            rptBlockedUsers.DataSource = blockedUsers;
            rptBlockedUsers.DataBind();

            rptQuickNotes.DataSource = _workspaceRepository.GetQuickNotes(currentUser.UserId, 8);
            rptQuickNotes.DataBind();

            BindFriendForms(currentUser.UserId, selectedFriend);
            BindConversation(currentUser.UserId, selectedFriend);
            BindMoments(momentFeed);
        }

        private void BindFriendForms(int userId, FriendChatSummaryInfo selectedFriend)
        {
            var friends = _accountRepository.GetFriends(userId);
            var recipients = _accountRepository.GetGiftRecipientCandidates(userId, 80).Where(item => friends.Any(friend => friend.UserId == item.Id)).ToList();
            var featuredScripts = _contentRepository.GetFeaturedScripts(12);

            ddlFriendCandidate.DataSource = _accountRepository.GetSuggestedFriends(userId, 50);
            ddlFriendCandidate.DataTextField = "DisplayName";
            ddlFriendCandidate.DataValueField = "Id";
            ddlFriendCandidate.DataBind();
            ddlFriendCandidate.Items.Insert(0, new ListItem("请选择要添加的玩家", string.Empty));

            cblGroupMembers.DataSource = friends;
            cblGroupMembers.DataTextField = "DisplayName";
            cblGroupMembers.DataValueField = "UserId";
            cblGroupMembers.DataBind();

            ddlGiftCatalog.DataSource = _accountRepository.GetGiftCatalog();
            ddlGiftCatalog.DataTextField = "Name";
            ddlGiftCatalog.DataValueField = "Id";
            ddlGiftCatalog.DataBind();
            ddlGiftCatalog.Items.Insert(0, new ListItem("请选择礼物", string.Empty));

            ddlGiftReceiver.DataSource = recipients;
            ddlGiftReceiver.DataTextField = "DisplayName";
            ddlGiftReceiver.DataValueField = "Id";
            ddlGiftReceiver.DataBind();
            ddlGiftReceiver.Items.Insert(0, new ListItem("请选择好友", string.Empty));

            ddlTransferReceiver.DataSource = recipients;
            ddlTransferReceiver.DataTextField = "DisplayName";
            ddlTransferReceiver.DataValueField = "Id";
            ddlTransferReceiver.DataBind();
            ddlTransferReceiver.Items.Insert(0, new ListItem("请选择好友", string.Empty));

            ddlInviteScript.DataSource = featuredScripts;
            ddlInviteScript.DataTextField = "Name";
            ddlInviteScript.DataValueField = "Id";
            ddlInviteScript.DataBind();
            ddlInviteScript.Items.Insert(0, new ListItem("请选择要邀请的剧本", string.Empty));

            EnsureMessageTypeOptions();
            EnsureTransferTypeOptions();
            EnsureMomentVisibilityOptions();

            if (selectedFriend != null)
            {
                SelectListItemIfExists(ddlGiftReceiver, selectedFriend.FriendUserId.ToString());
                SelectListItemIfExists(ddlTransferReceiver, selectedFriend.FriendUserId.ToString());
            }

            rptTransferRecords.DataSource = _accountRepository.GetFriendMoneyTransfers(userId, 8);
            rptTransferRecords.DataBind();
        }

        private void BindConversation(int userId, FriendChatSummaryInfo selectedFriend)
        {
            if (selectedFriend == null)
            {
                rptConversation.DataSource = new List<FriendChatMessageInfo>();
                rptConversation.DataBind();
                return;
            }

            var conversation = _accountRepository.GetFriendConversation(userId, selectedFriend.FriendUserId, 40);
            if (!string.IsNullOrWhiteSpace(ConversationSearchKeyword))
            {
                var keyword = ConversationSearchKeyword;
                conversation = conversation
                    .Where(item =>
                        (item.Content ?? string.Empty).IndexOf(keyword, StringComparison.OrdinalIgnoreCase) >= 0 ||
                        (item.MessageType ?? string.Empty).IndexOf(keyword, StringComparison.OrdinalIgnoreCase) >= 0 ||
                        (item.LocationText ?? string.Empty).IndexOf(keyword, StringComparison.OrdinalIgnoreCase) >= 0)
                    .ToList();
            }
            rptConversation.DataSource = conversation;
            rptConversation.DataBind();
        }

        private void BindMoments(IList<MomentPostInfo> momentFeed)
        {
            rptMoments.DataSource = momentFeed;
            rptMoments.DataBind();
        }

        private IList<FriendChatSummaryInfo> BuildHiddenSummaries(int userId)
        {
            var hiddenIds = _accountRepository.GetHiddenFriendIds(userId);
            if (hiddenIds.Count == 0)
            {
                return new List<FriendChatSummaryInfo>();
            }

            var allSummaries = _accountRepository.GetFriendChatSummaries(userId);
            var pinnedIds = _accountRepository.GetPinnedFriendIds(userId);
            foreach (var summary in allSummaries)
            {
                summary.IsPinned = pinnedIds.Contains(summary.FriendUserId);
            }

            var summaryLookup = allSummaries.ToDictionary(item => item.FriendUserId, item => item);
            var hiddenSummaries = new List<FriendChatSummaryInfo>();
            foreach (var hiddenId in hiddenIds)
            {
                if (summaryLookup.TryGetValue(hiddenId, out var summary))
                {
                    summary.IsHidden = true;
                    hiddenSummaries.Add(summary);
                }
            }

            if (hiddenSummaries.Count == hiddenIds.Count)
            {
                return OrderFriendSummaries(hiddenSummaries);
            }

            var friendLookup = _accountRepository.GetFriends(userId).ToDictionary(item => item.UserId, item => item);
            foreach (var hiddenId in hiddenIds.Where(id => hiddenSummaries.All(item => item.FriendUserId != id)))
            {
                if (!friendLookup.TryGetValue(hiddenId, out var friend))
                {
                    continue;
                }

                hiddenSummaries.Add(new FriendChatSummaryInfo
                {
                    FriendUserId = friend.UserId,
                    Username = friend.Username,
                    DisplayName = friend.DisplayName,
                    AvatarUrl = friend.AvatarUrl,
                    FavoriteGenre = friend.FavoriteGenre,
                    ReputationLevel = friend.ReputationLevel,
                    LastMessagePreview = "该会话已隐藏",
                    IsHidden = true
                });
            }

            return OrderFriendSummaries(hiddenSummaries);
        }

        private static List<FriendChatSummaryInfo> OrderFriendSummaries(IEnumerable<FriendChatSummaryInfo> summaries)
        {
            return summaries
                .OrderByDescending(item => item.IsPinned)
                .ThenByDescending(item => item.LastMessageAt ?? DateTime.MinValue)
                .ThenBy(item => item.DisplayName)
                .ToList();
        }

        private FriendChatSummaryInfo ResolveSelectedFriendSummary(IList<FriendChatSummaryInfo> friendSummaries)
        {
            if (friendSummaries == null || friendSummaries.Count == 0)
            {
                return null;
            }

            if (int.TryParse(Request.QueryString["friendId"], out var friendUserId))
            {
                var selected = friendSummaries.FirstOrDefault(item => item.FriendUserId == friendUserId);
                if (selected != null)
                {
                    return selected;
                }
            }

            return friendSummaries[0];
        }

        private void EnsureMessageTypeOptions()
        {
            if (ddlChatMessageType.Items.Count > 0)
            {
                return;
            }

            ddlChatMessageType.Items.Add(new ListItem("文字消息", "Text"));
            ddlChatMessageType.Items.Add(new ListItem("照片分享", "Photo"));
            ddlChatMessageType.Items.Add(new ListItem("视频通话邀请", "VideoCall"));
            ddlChatMessageType.Items.Add(new ListItem("位置共享", "Location"));
            ddlChatMessageType.Items.Add(new ListItem("语音留言", "Voice"));
        }

        private void EnsureTransferTypeOptions()
        {
            if (ddlTransferType.Items.Count > 0)
            {
                return;
            }

            ddlTransferType.Items.Add(new ListItem("互动红包", "RedPacket"));
            ddlTransferType.Items.Add(new ListItem("好友转账", "Transfer"));
        }

        private void EnsureMomentVisibilityOptions()
        {
            if (ddlMomentVisibility.Items.Count > 0)
            {
                return;
            }

            ddlMomentVisibility.Items.Add(new ListItem("仅好友可见", "Friends"));
            ddlMomentVisibility.Items.Add(new ListItem("公开展示", "Public"));
            ddlMomentVisibility.Items.Add(new ListItem("仅自己可见", "Private"));
        }

        private static void SelectListItemIfExists(ListControl listControl, string value)
        {
            var item = listControl.Items.FindByValue(value);
            if (item == null)
            {
                return;
            }

            listControl.ClearSelection();
            item.Selected = true;
        }

        private static int SafeToInt(object value)
        {
            return value != null && int.TryParse(Convert.ToString(value), out var parsed) ? parsed : 0;
        }

        private static void ShowMessage(WebControl panel, Literal literal, string message, bool success)
        {
            panel.Visible = true;
            panel.CssClass = success ? "status-message success" : "status-message error";
            literal.Text = HttpUtility.HtmlEncode(message);
        }

        private static IList<MomentCommentInfo> BuildCommentThread(IList<MomentCommentInfo> comments)
        {
            var ordered = new List<MomentCommentInfo>();
            if (comments == null || comments.Count == 0)
            {
                return ordered;
            }

            var roots = comments
                .Where(item => !item.ParentCommentId.HasValue)
                .OrderBy(item => item.CreatedAt)
                .ThenBy(item => item.Id)
                .ToList();

            var commentsByParent = comments
                .Where(item => item.ParentCommentId.HasValue)
                .GroupBy(item => item.ParentCommentId.Value)
                .ToDictionary(group => group.Key, group => group.OrderBy(item => item.CreatedAt).ThenBy(item => item.Id).ToList());

            foreach (var root in roots)
            {
                AppendMomentCommentBranch(root, commentsByParent, ordered, 0);
            }

            foreach (var orphan in comments
                .Where(item => item.ParentCommentId.HasValue && ordered.All(existing => existing.Id != item.Id))
                .OrderBy(item => item.CreatedAt)
                .ThenBy(item => item.Id))
            {
                AppendMomentCommentBranch(orphan, commentsByParent, ordered, 1);
            }

            return ordered;
        }

        private static void AppendMomentCommentBranch(MomentCommentInfo current, IDictionary<int, List<MomentCommentInfo>> commentsByParent, IList<MomentCommentInfo> ordered, int depth)
        {
            current.ReplyDepth = depth;
            ordered.Add(current);

            if (!commentsByParent.TryGetValue(current.Id, out var children))
            {
                return;
            }

            foreach (var child in children)
            {
                AppendMomentCommentBranch(child, commentsByParent, ordered, depth + 1);
            }
        }

        private static string HighlightKeyword(string rawText, string keyword)
        {
            var safeText = HttpUtility.HtmlEncode(rawText ?? string.Empty);
            if (string.IsNullOrWhiteSpace(keyword))
            {
                return safeText;
            }

            return Regex.Replace(
                safeText,
                Regex.Escape(keyword.Trim()),
                match => "<mark class=\"text-highlight\">" + match.Value + "</mark>",
                RegexOptions.IgnoreCase);
        }

        private void ClearReplyTarget()
        {
            ReplyMomentId = null;
            ReplyCommentId = null;
            ViewState[ReplyDisplayViewStateKey] = null;
        }
    }
}
