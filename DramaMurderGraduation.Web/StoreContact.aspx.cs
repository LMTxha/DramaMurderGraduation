using System;
using System.Linq;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// 门店联系与到店咨询页面。
    /// 游客和登录用户都可以提交到店意向，后台角色可以在同页处理联系单。
    /// </summary>
    public partial class StoreContactPage : System.Web.UI.Page
    {
        private readonly ContentRepository _repository = new ContentRepository();

        /// <summary>
        /// 首次加载时绑定门店信息、剧本下拉项、我的联系单和后台管理区。
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            BindPage();
        }

        /// <summary>
        /// 提交到店咨询/探店预约。
        /// </summary>
        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            pnlMessage.Visible = true;

            if (!DateTime.TryParse(txtPreferredTime.Text.Trim(), out var preferredTime))
            {
                ShowMessage("请填写有效的到店时间。", false);
                return;
            }

            if (!int.TryParse(txtTeamSize.Text.Trim(), out var teamSize))
            {
                ShowMessage("请填写有效的组队人数。", false);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtContactName.Text) || string.IsNullOrWhiteSpace(txtPhone.Text))
            {
                ShowMessage("联系人和联系电话不能为空。", false);
                return;
            }

            int? scriptId = null;
            if (int.TryParse(ddlScripts.SelectedValue, out var parsedScriptId) && parsedScriptId > 0)
            {
                scriptId = parsedScriptId;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _repository.CreateStoreVisitRequest(
                currentUser == null ? (int?)null : currentUser.UserId,
                scriptId,
                preferredTime,
                teamSize,
                txtContactName.Text.Trim(),
                txtPhone.Text.Trim(),
                txtNote.Text.Trim(),
                out var message);

            ShowMessage(message, success);

            if (!success)
            {
                return;
            }

            txtNote.Text = string.Empty;
            BindRequests();
            if (pnlAdminStoreManager.Visible)
            {
                BindAdminStoreRequests();
            }
        }

        /// <summary>
        /// 玩家处理自己的到店联系单，例如确认安排或申请改期。
        /// </summary>
        protected void rptRequests_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            pnlMessage.Visible = true;

            var currentUser = AuthManager.GetCurrentUser();
            if (currentUser == null)
            {
                ShowMessage("请先登录后再处理自己的到店联系单。", false);
                return;
            }

            if (!int.TryParse(Convert.ToString(e.CommandArgument), out var requestId))
            {
                ShowMessage("未找到对应的到店联系单。", false);
                return;
            }

            bool success;
            string message;

            if (string.Equals(e.CommandName, "ConfirmReceived", StringComparison.OrdinalIgnoreCase))
            {
                success = _repository.ConfirmStoreVisitRequestByPlayer(requestId, currentUser.UserId, out message);
            }
            else if (string.Equals(e.CommandName, "RequestReschedule", StringComparison.OrdinalIgnoreCase))
            {
                var remarkBox = e.Item.FindControl("txtRescheduleRemark") as TextBox;
                success = _repository.RequestStoreVisitReschedule(requestId, currentUser.UserId, remarkBox == null ? string.Empty : remarkBox.Text.Trim(), out message);
            }
            else
            {
                return;
            }

            ShowMessage(message, success);
            BindRequests();
            if (pnlAdminStoreManager.Visible)
            {
                BindAdminStoreRequests();
            }
        }

        protected void btnFilterAdminStoreRequests_Click(object sender, EventArgs e)
        {
            BindAdminStoreRequests();
        }

        protected void btnResetAdminStoreRequests_Click(object sender, EventArgs e)
        {
            txtAdminStoreKeyword.Text = string.Empty;
            ddlAdminStoreStatus.SelectedValue = string.Empty;
            BindAdminStoreRequests();
        }

        protected void rptAdminStoreRequests_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            pnlMessage.Visible = true;

            var currentUser = AuthManager.GetAdminUser();
            if (currentUser == null)
            {
                ShowMessage("只有系统管理员可以审核和回复玩家到店需求。", false);
                return;
            }

            if (!int.TryParse(Convert.ToString(e.CommandArgument), out var requestId))
            {
                ShowMessage("未找到对应的到店联系单。", false);
                return;
            }

            var status = MapAdminStoreStatus(e.CommandName);
            if (string.IsNullOrWhiteSpace(status))
            {
                return;
            }

            var assignedRoomBox = e.Item.FindControl("txtAdminAssignedRoomName") as TextBox;
            var remarkBox = e.Item.FindControl("txtAdminStoreRemark") as TextBox;
            var replyBox = e.Item.FindControl("txtAdminStoreReply") as TextBox;
            var assignedRoomName = assignedRoomBox == null ? string.Empty : assignedRoomBox.Text.Trim();
            var adminRemark = remarkBox == null ? string.Empty : remarkBox.Text.Trim();
            var adminReply = BuildAdminStoreReply(e.CommandName, assignedRoomName, replyBox == null ? string.Empty : replyBox.Text.Trim());

            var success = _repository.ReviewStoreVisitRequest(
                requestId,
                status,
                assignedRoomName,
                adminRemark,
                adminReply,
                currentUser.UserId,
                out var message);

            ShowMessage(message, success);
            BindAdminStoreRequests();
            BindRequests();
        }

        private void BindPage()
        {
            var settings = _repository.GetSiteSettings();
            var selectableScripts = _repository.GetScripts(string.Empty, null);
            var sessions = _repository.GetUpcomingSessions(20);
            var currentUser = AuthManager.GetCurrentUser();

            litStoreName.Text = string.IsNullOrWhiteSpace(settings.SiteName) ? "线下门店" : settings.SiteName;
            litStoreAddress.Text = string.IsNullOrWhiteSpace(settings.Address) ? "门店地址待补充" : settings.Address;
            litBusinessHours.Text = string.IsNullOrWhiteSpace(settings.BusinessHours) ? "营业时间待补充" : settings.BusinessHours;
            litPhone.Text = string.IsNullOrWhiteSpace(settings.ContactPhone) ? "门店电话待补充" : settings.ContactPhone;
            litWeChat.Text = string.IsNullOrWhiteSpace(settings.ContactWeChat) ? "门店客服在线" : settings.ContactWeChat;

            ddlScripts.Items.Clear();
            ddlScripts.Items.Add(new ListItem("由门店推荐安排", string.Empty));
            foreach (var script in selectableScripts.OrderBy(item => item.Name))
            {
                ddlScripts.Items.Add(new ListItem(script.Name + " / " + script.PlayerMin + "-" + script.PlayerMax + " 人", script.Id.ToString()));
            }

            var recommendedSession = sessions.FirstOrDefault(item => string.Equals(item.ScriptName, "潮声烛灯时", StringComparison.OrdinalIgnoreCase))
                ?? sessions.FirstOrDefault();
            litRecommendedSession.Text = recommendedSession == null
                ? "请联系门店确认最新排期"
                : recommendedSession.ScriptName + " / " + recommendedSession.RoomName + " / " + recommendedSession.SessionDateTime.ToString("MM-dd HH:mm");

            txtPreferredTime.Text = DateTime.Now.AddDays(1).Date.AddHours(19).AddMinutes(30).ToString("yyyy-MM-dd HH:mm");
            txtTeamSize.Text = "6";
            txtNote.Text = "希望先在线上选好剧本并完成支付，到店后直接开本。";

            if (int.TryParse(Request.QueryString["scriptId"], out var queryScriptId))
            {
                var target = ddlScripts.Items.FindByValue(queryScriptId.ToString());
                if (target != null)
                {
                    ddlScripts.ClearSelection();
                    target.Selected = true;
                }
            }

            if (currentUser != null)
            {
                txtContactName.Text = currentUser.DisplayName;
                txtPhone.Text = currentUser.Phone;
            }

            BindAdminStoreStatusOptions();
            pnlAdminStoreManager.Visible = AuthManager.HasAdminAccess(currentUser);
            if (pnlAdminStoreManager.Visible)
            {
                BindAdminStoreRequests();
            }

            BindRequests();
        }

        private void BindAdminStoreStatusOptions()
        {
            if (ddlAdminStoreStatus.Items.Count > 0)
            {
                return;
            }

            ddlAdminStoreStatus.Items.Add(new ListItem("全部联系单", string.Empty));
            ddlAdminStoreStatus.Items.Add(new ListItem("待门店联系", "待门店联系"));
            ddlAdminStoreStatus.Items.Add(new ListItem("已安排排期", "已安排排期"));
            ddlAdminStoreStatus.Items.Add(new ListItem("玩家已确认", "玩家已确认"));
            ddlAdminStoreStatus.Items.Add(new ListItem("玩家申请改期", "玩家申请改期"));
            ddlAdminStoreStatus.Items.Add(new ListItem("已到店完成", "已到店完成"));
            ddlAdminStoreStatus.Items.Add(new ListItem("已关闭", "已关闭"));
        }

        private void BindAdminStoreRequests()
        {
            var currentUser = AuthManager.GetAdminUser();
            if (currentUser == null)
            {
                return;
            }

            rptAdminStoreRequests.DataSource = _repository.GetStoreVisitRequests(
                30,
                null,
                string.IsNullOrWhiteSpace(ddlAdminStoreStatus.SelectedValue) ? null : ddlAdminStoreStatus.SelectedValue,
                txtAdminStoreKeyword.Text.Trim(),
                null);
            rptAdminStoreRequests.DataBind();
        }

        private void BindRequests()
        {
            var currentUser = AuthManager.GetCurrentUser();
            if (currentUser == null)
            {
                pnlAnonymousHint.Visible = true;
                rptRequests.DataSource = null;
                rptRequests.DataBind();
                return;
            }

            pnlAnonymousHint.Visible = false;
            rptRequests.DataSource = _repository.GetStoreVisitRequests(8, currentUser.UserId);
            rptRequests.DataBind();
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.CssClass = success ? "status-message success" : "status-message error";
            litMessage.Text = message;
        }

        private static string MapAdminStoreStatus(string commandName)
        {
            switch (commandName)
            {
                case "ApproveStore":
                    return "已安排排期";
                case "CompleteStore":
                    return "已到店完成";
                case "RejectStore":
                    return "已关闭";
                default:
                    return string.Empty;
            }
        }

        private static string BuildAdminStoreReply(string commandName, string assignedRoomName, string customReply)
        {
            if (!string.IsNullOrWhiteSpace(customReply))
            {
                return customReply.Trim();
            }

            var roomName = string.IsNullOrWhiteSpace(assignedRoomName) ? "门店待确认房间" : assignedRoomName.Trim();
            switch (commandName)
            {
                case "ApproveStore":
                    return "你的到店需求已审核通过，门店已安排 " + roomName + "。请按预约时间到店，工作人员会协助开本。";
                case "CompleteStore":
                    return "本次到店已登记完成，感谢你的到店体验。";
                case "RejectStore":
                    return "这张到店联系单暂时无法安排，已关闭。如需重新安排，请重新提交到店需求。";
                default:
                    return string.Empty;
            }
        }
    }
}
