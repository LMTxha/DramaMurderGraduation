using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// DM 日程页后台逻辑，按日期查询主持排班和场次详情。
    /// </summary>
    public partial class DmScheduleDayPage : System.Web.UI.Page
    {
        private readonly ContentRepository _repository = new ContentRepository();
        private DateTime _selectedDate;

        protected string PreviousDayUrl { get; private set; }
        protected string NextDayUrl { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            MaintainScrollPositionOnPostBack = true;
            AuthManager.RequireGameManager();
            _selectedDate = ParseSelectedDate();
            PreviousDayUrl = BuildDayUrl(_selectedDate.AddDays(-1));
            NextDayUrl = BuildDayUrl(_selectedDate.AddDays(1));

            if (!IsPostBack)
            {
                BindSchedule();
            }
        }

        protected void rptDaySessions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out var commandId))
            {
                return;
            }

            var currentUser = AuthManager.GetGameManagerUser();
            if (currentUser == null)
            {
                return;
            }

            pnlMessage.Visible = true;
            bool success;
            string message;
            if (e.CommandName == "AcceptAssignment")
            {
                success = _repository.AcceptDmAssignment(commandId, currentUser.UserId, out message);
            }
            else if (e.CommandName == "CancelAssignment")
            {
                success = _repository.CancelDmAssignment(commandId, currentUser.UserId, currentUser.IsAdmin, out message);
            }
            else if (e.CommandName == "ReleaseSession" || e.CommandName == "FinishSession")
            {
                success = _repository.CancelDmAssignment(commandId, currentUser.UserId, currentUser.IsAdmin, out message);
            }
            else
            {
                return;
            }

            pnlMessage.CssClass = success ? "status-message success" : "status-message error";
            litMessage.Text = message;
            BindSchedule();
            KeepScheduleInView();
        }

        private void KeepScheduleInView()
        {
            const string script = @"
window.setTimeout(function () {
    var target = document.getElementById('dm-day-session-list');
    if (target) {
        target.scrollIntoView({ block: 'start' });
    }
}, 0);";

            ClientScript.RegisterStartupScript(GetType(), "keep-dm-day-session-list", script, true);
        }

        private void BindSchedule()
        {
            var currentUser = AuthManager.GetGameManagerUser();
            if (currentUser == null)
            {
                pnlForbidden.Visible = true;
                pnlSchedule.Visible = false;
                return;
            }

            var sessions = _repository.GetDmSessions(120, currentUser.IsAdmin ? (int?)null : currentUser.UserId)
                .Where(item => item.SessionDateTime.Date == _selectedDate.Date)
                .OrderBy(item => item.SessionDateTime)
                .ThenBy(item => item.SessionId)
                .ToList();

            pnlForbidden.Visible = false;
            pnlSchedule.Visible = true;
            pnlEmpty.Visible = sessions.Count == 0;

            litDayTitle.Text = GetDayTitle(_selectedDate);
            litSelectedDate.Text = _selectedDate.ToString("yyyy-MM-dd");
            litSessionCount.Text = sessions.Count.ToString();
            litPendingCount.Text = sessions.Count(item => !item.HostAcceptedAt.HasValue).ToString();
            litAcceptedCount.Text = sessions.Count(item => item.HostAcceptedAt.HasValue).ToString();
            litActiveCount.Text = sessions.Count(item => item.IsGameStarted && !item.IsGameEnded).ToString();
            litSettledCount.Text = sessions.Count(item => item.IsSettled).ToString();

            rptDaySessions.DataSource = sessions;
            rptDaySessions.DataBind();
        }

        protected string GetHostLink(object hostReservationIdValue)
        {
            var hostReservationId = Convert.ToInt32(hostReservationIdValue);
            if (hostReservationId <= 0)
            {
                return "<span class=\"inline-note\">暂无有效玩家预约</span>";
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
            return acceptedAtValue == null || acceptedAtValue == DBNull.Value ? "待接单" : "已接单";
        }

        public string GetAcceptBadgeClass(object acceptedAtValue)
        {
            return acceptedAtValue == null || acceptedAtValue == DBNull.Value ? "soft" : "success";
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

        private DateTime ParseSelectedDate()
        {
            var raw = Request.QueryString["date"];
            if (DateTime.TryParseExact(raw, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var date))
            {
                return date.Date;
            }

            return DateTime.Today;
        }

        private static string GetDayTitle(DateTime date)
        {
            if (date.Date == DateTime.Today)
            {
                return "今天的主持排班";
            }

            if (date.Date == DateTime.Today.AddDays(1))
            {
                return "明天的主持排班";
            }

            return date.ToString("MM-dd") + " 主持排班";
        }

        private static string BuildDayUrl(DateTime date)
        {
            return "DmScheduleDay.aspx?date=" + date.ToString("yyyy-MM-dd");
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

        private sealed class ChecklistItem
        {
            public bool IsReady { get; set; }
            public string Title { get; set; }
            public string Detail { get; set; }
        }
    }
}
