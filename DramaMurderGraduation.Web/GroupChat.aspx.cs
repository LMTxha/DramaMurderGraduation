using System;
using System.Web;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public partial class GroupChatPage : System.Web.UI.Page
    {
        private readonly FriendWorkspaceRepository _workspaceRepository = new FriendWorkspaceRepository();
        private ChatGroupInfo _group;
        private CurrentUserInfo _currentUser;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Page.Form != null)
            {
                Page.Form.Enctype = "multipart/form-data";
            }

            AuthManager.RequireLogin();
            _currentUser = AuthManager.GetCurrentUser();

            if (!int.TryParse(Request.QueryString["groupId"], out var groupId) || groupId <= 0)
            {
                Response.Redirect("~/Friends.aspx#group-list", true);
                return;
            }

            _group = _workspaceRepository.GetChatGroupById(_currentUser.UserId, groupId);
            if (_group == null)
            {
                Response.Redirect("~/Friends.aspx#group-list", true);
                return;
            }

            EnsureMessageTypeOptions();
            if (!IsPostBack)
            {
                BindPage(markAsRead: true);
            }
        }

        protected void btnSendGroupMessage_Click(object sender, EventArgs e)
        {
            pnlGroupMessage.Visible = true;

            if (!UploadHelper.TrySave(fuGroupAttachment, "group", out var uploadedUrl, out var uploadError))
            {
                ShowMessage(uploadError, false);
                return;
            }

            var attachmentUrl = string.IsNullOrWhiteSpace(uploadedUrl) ? txtGroupAttachmentUrl.Text.Trim() : uploadedUrl;
            var content = txtGroupContent.Text.Trim();
            var locationText = txtGroupLocation.Text.Trim();
            var messageType = ddlGroupMessageType.SelectedValue;

            if (messageType == "Photo" && string.IsNullOrWhiteSpace(content))
            {
                content = "分享了一张图片。";
            }
            else if (messageType == "Voice" && string.IsNullOrWhiteSpace(content))
            {
                content = "发送了一条语音留言。";
            }
            else if (messageType == "VideoCall" && string.IsNullOrWhiteSpace(content))
            {
                content = "发起了群视频通话邀请。";
            }
            else if (messageType == "Location" && string.IsNullOrWhiteSpace(locationText))
            {
                locationText = "剧本杀门店集合点";
            }

            var success = _workspaceRepository.SendGroupMessage(_currentUser.UserId, _group.GroupId, messageType, content, attachmentUrl, locationText, out var message);
            ShowMessage(message, success);
            if (success)
            {
                txtGroupContent.Text = string.Empty;
                txtGroupAttachmentUrl.Text = string.Empty;
                txtGroupLocation.Text = string.Empty;
            }

            BindPage(markAsRead: success);
        }

        protected void btnTogglePinGroup_Click(object sender, EventArgs e)
        {
            pnlGroupMessage.Visible = true;
            var success = _workspaceRepository.SetGroupConversationPreference(_currentUser.UserId, _group.GroupId, !_group.IsPinned, null, null, out var message);
            ShowMessage(success ? (_group.IsPinned ? "已取消群聊置顶。" : "群聊已置顶。") : message, success);
            BindPage(markAsRead: false);
        }

        protected void btnMuteGroup_Click(object sender, EventArgs e)
        {
            pnlGroupMessage.Visible = true;
            var success = _workspaceRepository.SetGroupConversationPreference(_currentUser.UserId, _group.GroupId, null, null, !_group.IsMuted, out var message);
            ShowMessage(success ? (_group.IsMuted ? "已关闭免打扰。" : "群聊已设为免打扰。") : message, success);
            BindPage(markAsRead: false);
        }

        protected void btnHideGroup_Click(object sender, EventArgs e)
        {
            pnlGroupMessage.Visible = true;
            var success = _workspaceRepository.SetGroupConversationPreference(_currentUser.UserId, _group.GroupId, null, true, null, out var message);
            ShowMessage(success ? "群聊已隐藏，可在好友互动中重新显示。" : message, success);
            BindPage(markAsRead: false);
        }

        private void BindPage(bool markAsRead)
        {
            _group = _workspaceRepository.GetChatGroupById(_currentUser.UserId, _group.GroupId);
            litGroupName.Text = HttpUtility.HtmlEncode(_group.Name);
            litGroupNameSide.Text = HttpUtility.HtmlEncode(_group.Name);
            litAnnouncement.Text = string.IsNullOrWhiteSpace(_group.Announcement)
                ? "暂无群公告，可在群里沟通开本、线索和到店安排。"
                : HttpUtility.HtmlEncode(_group.Announcement);
            litMemberCount.Text = _group.MemberCount.ToString();
            btnTogglePinGroup.Text = _group.IsPinned ? "取消置顶" : "置顶";
            btnMuteGroup.Text = _group.IsMuted ? "关闭免打扰" : "免打扰";

            rptMembers.DataSource = _workspaceRepository.GetChatGroupMembers(_currentUser.UserId, _group.GroupId);
            rptMembers.DataBind();
            BindMessages(markAsRead);
        }

        private void BindMessages(bool markAsRead)
        {
            if (markAsRead)
            {
                _workspaceRepository.MarkGroupConversationAsRead(_currentUser.UserId, _group.GroupId);
            }

            rptGroupMessages.DataSource = _workspaceRepository.GetChatGroupMessages(_currentUser.UserId, _group.GroupId, 80);
            rptGroupMessages.DataBind();
        }

        protected string GetGroupBubbleClass(object senderUserId)
        {
            return Convert.ToInt32(senderUserId) == _currentUser.UserId
                ? "chat-message-bubble outgoing"
                : "chat-message-bubble incoming";
        }

        protected string GetAvatarUrl(object avatarUrl)
        {
            var value = Convert.ToString(avatarUrl)?.Trim();
            if (string.IsNullOrWhiteSpace(value))
            {
                return "https://api.dicebear.com/8.x/initials/svg?seed=DM";
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

        protected string GetMessageTypeLabel(object messageType)
        {
            switch (Convert.ToString(messageType))
            {
                case "Photo":
                    return "照片";
                case "VideoCall":
                    return "视频通话";
                case "Location":
                    return "位置";
                case "Voice":
                    return "语音";
                default:
                    return "文字";
            }
        }

        protected IHtmlString RenderAttachment(object attachmentUrl)
        {
            var value = Convert.ToString(attachmentUrl);
            if (string.IsNullOrWhiteSpace(value))
            {
                return new HtmlString(string.Empty);
            }

            var safeUrl = HttpUtility.HtmlAttributeEncode(value);
            return new HtmlString("<p class=\"chat-attachment\"><a class=\"text-link strong\" href=\"" + safeUrl + "\" target=\"_blank\" rel=\"noopener\">查看附件</a></p>");
        }

        protected IHtmlString RenderLocation(object locationText)
        {
            var value = Convert.ToString(locationText);
            if (string.IsNullOrWhiteSpace(value))
            {
                return new HtmlString(string.Empty);
            }

            return new HtmlString("<p class=\"chat-location\">位置：" + HttpUtility.HtmlEncode(value) + "</p>");
        }

        protected string HtmlEncode(object value)
        {
            return HttpUtility.HtmlEncode(Convert.ToString(value));
        }

        private void EnsureMessageTypeOptions()
        {
            if (ddlGroupMessageType.Items.Count > 0)
            {
                return;
            }

            ddlGroupMessageType.Items.Add(new ListItem("文字消息", "Text"));
            ddlGroupMessageType.Items.Add(new ListItem("照片分享", "Photo"));
            ddlGroupMessageType.Items.Add(new ListItem("视频通话邀请", "VideoCall"));
            ddlGroupMessageType.Items.Add(new ListItem("位置共享", "Location"));
            ddlGroupMessageType.Items.Add(new ListItem("语音留言", "Voice"));
        }

        private void ShowMessage(string message, bool success)
        {
            pnlGroupMessage.CssClass = success ? "status-message success wx-chat-status" : "status-message error wx-chat-status";
            litGroupMessage.Text = message;
        }
    }
}
