using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// DM 主持台页面。
    /// 展示当前主持人的场次日程、今日场次、开场检查清单和进入房间入口。
    /// </summary>
    public partial class DmDashboardPage : System.Web.UI.Page
    {
        private readonly ContentRepository _repository = new ContentRepository();

        protected string TodayScheduleUrl => "DmScheduleDay.aspx?date=" + DateTime.Today.ToString("yyyy-MM-dd");

        /// <summary>
        /// 校验 DM/游戏管理权限，并在首次加载时绑定主持台。
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            MaintainScrollPositionOnPostBack = true;
            AuthManager.RequireGameManager();

            if (!IsPostBack)
            {
                BindDashboard();
            }
        }

        /// <summary>
        /// 绑定 DM 看板统计、日程分组、今日场次和待处理清单。
        /// </summary>
        private void BindDashboard()
        {
            var currentUser = AuthManager.GetGameManagerUser();
            if (currentUser == null)
            {
                pnlForbidden.Visible = true;
                pnlDashboard.Visible = false;
                return;
            }

            var sessions = _repository.GetDmSessions(80, currentUser.IsAdmin ? (int?)null : currentUser.UserId);
            pnlForbidden.Visible = false;
            pnlDashboard.Visible = true;
            litRoleName.Text = currentUser.IsAdmin ? "管理员兼 DM" : "游戏指导者 DM";
            litDmName.Text = currentUser.DisplayName;
            litSessionCount.Text = sessions.Count.ToString();
            litTodaySessionCount.Text = sessions.Count(item => item.SessionDateTime.Date == DateTime.Today).ToString();
            litPendingAcceptCount.Text = sessions.Count(item => item.SessionDateTime >= DateTime.Today && !item.HostAcceptedAt.HasValue).ToString();
            litActiveSessionCount.Text = sessions.Count(item => item.IsGameStarted && !item.IsGameEnded).ToString();
            rptScheduleDays.DataSource = BuildScheduleDays(sessions);
            rptScheduleDays.DataBind();

            rptTodaySessions.DataSource = sessions
                .Where(item => item.SessionDateTime.Date == DateTime.Today)
                .OrderBy(item => item.SessionDateTime)
                .ToList();
            rptTodaySessions.DataBind();

            rptChecklistSessions.DataSource = sessions
                .Where(item => item.SessionDateTime >= DateTime.Today)
                .OrderBy(item => item.SessionDateTime)
                .Take(6)
                .ToList();
            rptChecklistSessions.DataBind();

            var sessionView = GetSessionView();
            var visibleSessions = FilterSessions(sessions, sessionView).ToList();
            if (!string.Equals(sessionView, "all", StringComparison.OrdinalIgnoreCase))
            {
                pnlMessage.Visible = true;
                pnlMessage.CssClass = "status-message success";
                litMessage.Text = HttpUtility.HtmlEncode(GetSessionViewMessage(sessionView, visibleSessions.Count));
            }

            rptSessions.DataSource = visibleSessions;
            rptSessions.DataBind();
        }

        /// <summary>
        /// 处理 DM 接受场次分配命令。
        /// </summary>
        protected void rptSessions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out var sessionId))
            {
                return;
            }

            var currentUser = AuthManager.GetGameManagerUser();
            if (currentUser == null)
            {
                return;
            }

            if (string.Equals(e.CommandName, "CancelAssignment", StringComparison.OrdinalIgnoreCase))
            {
                var cancelSuccess = _repository.CancelDmAssignment(sessionId, currentUser.UserId, currentUser.IsAdmin, out var cancelMessage);
                BindDashboard();
                ShowMessage(cancelMessage, cancelSuccess);
                KeepSessionListInView();
                return;
            }

            if (!string.Equals(e.CommandName, "AcceptAssignment", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            var accepted = _repository.AcceptDmAssignment(sessionId, currentUser.UserId, out var acceptMessage);
            if (!accepted)
            {
                BindDashboard();
                ShowMessage(acceptMessage, false);
                KeepSessionListInView();
                return;
            }

            var hostReservationId = _repository.GetHostReservationIdForSession(sessionId);
            if (hostReservationId <= 0)
            {
                _repository.EnsureHostReservationForSession(sessionId, currentUser.UserId, currentUser.IsAdmin, out hostReservationId, out acceptMessage);
            }

            if (hostReservationId > 0)
            {
                Response.Redirect("GameRoom.aspx?reservationId=" + hostReservationId + "&host=1", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            BindDashboard();
            ShowMessage(acceptMessage, false);
            KeepSessionListInView();
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = success ? "status-message success" : "status-message error";
            litMessage.Text = message;
        }

        private void KeepSessionListInView()
        {
            const string script = @"
window.setTimeout(function () {
    var target = document.getElementById('dm-session-list');
    if (target) {
        target.scrollIntoView({ block: 'start' });
    }
}, 0);";

            ClientScript.RegisterStartupScript(GetType(), "keep-dm-session-list", script, true);
        }

        protected string GetHostLink(object sessionIdValue, object hostReservationIdValue, object acceptedAtValue)
        {
            if (acceptedAtValue == null || acceptedAtValue == DBNull.Value)
            {
                return "<span class=\"inline-note\">接单后进入主持</span>";
            }

            var sessionId = Convert.ToInt32(sessionIdValue);
            var hostReservationId = Convert.ToInt32(hostReservationIdValue);
            if (hostReservationId <= 0)
            {
                return "<a class=\"btn-primary small\" href=\"GameRoom.aspx?sessionId=" + sessionId + "&host=1\">进入主持</a>";
            }

            return "<a class=\"btn-primary small\" href=\"GameRoom.aspx?reservationId=" + hostReservationId + "&host=1\">进入主持</a>";
        }

        protected string GetSessionStatusText(object startedValue, object endedValue, object settledValue)
        {
            var started = Convert.ToBoolean(startedValue);
            var ended = Convert.ToBoolean(endedValue);
            var settled = Convert.ToBoolean(settledValue);

            if (settled)
            {
                return "已归档";
            }

            if (ended)
            {
                return "已结算";
            }

            return started ? "进行中" : "待开局";
        }

        public string GetAcceptStatusText(object acceptedAtValue)
        {
            return IsPendingAccept(acceptedAtValue) ? "待接单" : "已接单";
        }

        public string GetAcceptBadgeClass(object acceptedAtValue)
        {
            return IsPendingAccept(acceptedAtValue) ? "soft" : "success";
        }

        protected bool IsPendingAccept(object acceptedAtValue)
        {
            return acceptedAtValue == null || acceptedAtValue == DBNull.Value;
        }

        public string BuildChecklistHtml(object dataItem)
        {
            var session = dataItem as DmSessionInfo;
            if (session == null)
            {
                return string.Empty;
            }

            var items = new[]
            {
                BuildChecklistItem(session.HostAcceptedAt.HasValue, "确认主持接单", session.HostAcceptedAt.HasValue ? "已接单" : "待接单"),
                BuildChecklistItem(session.ReservationCount > 0, "确认玩家到齐情况", session.ReservationCount + "/" + session.MaxPlayers + " 位玩家"),
                BuildChecklistItem(session.AssignedCount >= session.ReservationCount && session.ReservationCount > 0, "检查角色分配", session.AssignedCount + " 个已分配"),
                BuildChecklistItem(session.ReadyCount >= session.ReservationCount && session.ReservationCount > 0, "检查准备状态", session.ReadyCount + " 人已准备"),
                BuildChecklistItem(!string.IsNullOrWhiteSpace(session.HostBriefing), "阅读主持备注", string.IsNullOrWhiteSpace(session.HostBriefing) ? "暂无主持备注" : "已同步"),
                BuildChecklistItem(!string.IsNullOrWhiteSpace(session.PlayerNoteSummary) && session.PlayerNoteSummary != "暂无玩家备注", "同步玩家备注", session.PlayerNoteSummary)
            };

            var builder = new StringBuilder();
            foreach (var item in items)
            {
                builder.Append("<div class=\"dm-checklist-item");
                if (item.IsReady)
                {
                    builder.Append(" ready");
                }

                builder.Append("\"><span class=\"dm-checklist-dot\"></span><div><strong>");
                builder.Append(HttpUtility.HtmlEncode(item.Title));
                builder.Append("</strong><small>");
                builder.Append(HttpUtility.HtmlEncode(item.Detail));
                builder.Append("</small></div></div>");
            }

            return builder.ToString();
        }

        private static IList<ScheduleDayItem> BuildScheduleDays(IList<DmSessionInfo> sessions)
        {
            var items = new List<ScheduleDayItem>();
            for (var offset = 0; offset < 7; offset++)
            {
                var date = DateTime.Today.AddDays(offset);
                var daySessions = sessions.Where(item => item.SessionDateTime.Date == date.Date).OrderBy(item => item.SessionDateTime).ToList();
                var pendingCount = daySessions.Count(item => !item.HostAcceptedAt.HasValue);
                var activeCount = daySessions.Count(item => item.IsGameStarted && !item.IsGameEnded);
                items.Add(new ScheduleDayItem
                {
                    DayLabel = offset == 0 ? "今天" : offset == 1 ? "明天" : date.ToString("MM-dd"),
                    SessionCountText = daySessions.Count + " 场主持",
                    Summary = daySessions.Count == 0 ? "当天暂无排班" : "待接单 " + pendingCount + " 场 / 进行中 " + activeCount + " 场",
                    Url = "DmScheduleDay.aspx?date=" + date.ToString("yyyy-MM-dd"),
                    CssClass = offset == 0 ? "today" : pendingCount > 0 ? "attention" : string.Empty
                });
            }

            return items;
        }

        private string GetSessionView()
        {
            var view = (Request.QueryString["view"] ?? string.Empty).Trim().ToLowerInvariant();
            switch (view)
            {
                case "pending":
                case "active":
                    return view;
                default:
                    return "all";
            }
        }

        private static IEnumerable<DmSessionInfo> FilterSessions(IEnumerable<DmSessionInfo> sessions, string view)
        {
            switch (view)
            {
                case "pending":
                    return sessions.Where(item => item.SessionDateTime >= DateTime.Today && !item.HostAcceptedAt.HasValue);
                case "active":
                    return sessions.Where(item => item.IsGameStarted && !item.IsGameEnded);
                default:
                    return sessions;
            }
        }

        private static string GetSessionViewMessage(string view, int count)
        {
            switch (view)
            {
                case "pending":
                    return "已筛选待接收主持任务，共 " + count + " 场。";
                case "active":
                    return "已筛选进行中的主持房间，共 " + count + " 场。";
                default:
                    return string.Empty;
            }
        }

        private static ChecklistItem BuildChecklistItem(bool isReady, string title, string detail)
        {
            return new ChecklistItem
            {
                IsReady = isReady,
                Title = title,
                Detail = detail
            };
        }

        private sealed class ScheduleDayItem
        {
            public string DayLabel { get; set; }
            public string SessionCountText { get; set; }
            public string Summary { get; set; }
            public string Url { get; set; }
            public string CssClass { get; set; }
        }

        private sealed class ChecklistItem
        {
            public bool IsReady { get; set; }
            public string Title { get; set; }
            public string Detail { get; set; }
        }
    }
}
