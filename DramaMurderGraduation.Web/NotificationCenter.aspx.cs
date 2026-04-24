using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public partial class NotificationCenterPage : System.Web.UI.Page
    {
        private readonly ContentRepository _repository = new ContentRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireLogin();

            if (!IsPostBack)
            {
                BindFilterOptions();
                BindPage();
            }
        }

        public void btnApplyNotificationFilter_Click(object sender, EventArgs e)
        {
            BindPage();
        }

        protected void btnMarkAllRead_Click(object sender, EventArgs e)
        {
            var currentUser = AuthManager.GetCurrentUser();
            if (currentUser == null)
            {
                return;
            }

            var notifications = _repository.GetUserNotifications(currentUser.UserId, 120);
            _repository.MarkNotificationsAsRead(currentUser.UserId, notifications.Select(item => item.NotificationKey).ToList());
            ShowMessage("当前通知已全部标记为已读。", true);
            BindPage();
        }

        public void rptNotifications_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!string.Equals(e.CommandName, "MarkRead", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            if (currentUser == null)
            {
                return;
            }

            var key = Convert.ToString(e.CommandArgument);
            if (string.IsNullOrWhiteSpace(key))
            {
                ShowMessage("未找到对应通知。", false);
                return;
            }

            _repository.MarkNotificationsAsRead(currentUser.UserId, new[] { key });
            ShowMessage("通知已标记为已读。", true);
            BindPage();
        }

        private void BindPage()
        {
            var currentUser = AuthManager.GetCurrentUser();
            if (currentUser == null)
            {
                return;
            }

            var allNotifications = _repository.GetUserNotifications(currentUser.UserId, 120);
            var notifications = ApplyFilter(allNotifications);
            litTotalCount.Text = allNotifications.Count.ToString();
            litUnreadCount.Text = allNotifications.Count(item => !item.IsRead).ToString();
            litRecentCount.Text = allNotifications.Count(item => item.CreatedAt >= DateTime.Now.AddHours(-24)).ToString();

            rptNotifications.DataSource = notifications;
            rptNotifications.DataBind();
            litEmptyNotifications.Text = notifications.Count == 0
                ? "<div class=\"empty-state\"><h3>当前筛选下没有通知</h3><p>可以切换到“全部通知”查看完整消息，或回到玩家中心继续操作。</p></div>"
                : string.Empty;
        }

        private void BindFilterOptions()
        {
            ddlNotificationFilter.Items.Clear();
            ddlNotificationFilter.Items.Add(new ListItem("全部通知", "All"));
            ddlNotificationFilter.Items.Add(new ListItem("仅看未读", "Unread"));
            ddlNotificationFilter.Items.Add(new ListItem("订单回复", "订单回复"));
            ddlNotificationFilter.Items.Add(new ListItem("客服会话", "客服会话"));
            ddlNotificationFilter.Items.Add(new ListItem("优惠券", "优惠券"));
            ddlNotificationFilter.Items.Add(new ListItem("到店提醒", "到店提醒"));
            ddlNotificationFilter.Items.Add(new ListItem("售后进度", "售后进度"));

            var requestedFilter = Request.QueryString["filter"];
            var item = ddlNotificationFilter.Items.FindByValue(requestedFilter ?? string.Empty);
            if (item != null)
            {
                ddlNotificationFilter.ClearSelection();
                item.Selected = true;
            }
        }

        private IList<UserNotificationInfo> ApplyFilter(IList<UserNotificationInfo> notifications)
        {
            switch (ddlNotificationFilter.SelectedValue ?? "All")
            {
                case "Unread":
                    return notifications.Where(item => !item.IsRead).ToList();
                case "订单回复":
                case "客服会话":
                case "优惠券":
                case "到店提醒":
                case "售后进度":
                    return notifications.Where(item => string.Equals(item.Category, ddlNotificationFilter.SelectedValue, StringComparison.OrdinalIgnoreCase)).ToList();
                default:
                    return notifications;
            }
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = success ? "status-message success" : "status-message error";
            litMessage.Text = Server.HtmlEncode(message);
        }
    }
}
