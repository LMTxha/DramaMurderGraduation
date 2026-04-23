using System;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    public partial class DmDashboardPage : System.Web.UI.Page
    {
        private readonly ContentRepository _repository = new ContentRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireLogin();

            if (!IsPostBack)
            {
                BindDashboard();
            }
        }

        private void BindDashboard()
        {
            var currentUser = AuthManager.GetCurrentUser();
            if (currentUser == null || !currentUser.CanManageGameRoom)
            {
                pnlForbidden.Visible = true;
                pnlDashboard.Visible = false;
                return;
            }

            var sessions = _repository.GetDmSessions(80);
            pnlForbidden.Visible = false;
            pnlDashboard.Visible = true;
            litRoleName.Text = currentUser.IsAdmin ? "管理员兼 DM" : "游戏指导者 DM";
            litDmName.Text = currentUser.DisplayName;
            litSessionCount.Text = sessions.Count.ToString();

            rptSessions.DataSource = sessions;
            rptSessions.DataBind();
        }

        protected string GetHostLink(object hostReservationIdValue)
        {
            var hostReservationId = Convert.ToInt32(hostReservationIdValue);
            if (hostReservationId <= 0)
            {
                return "<span class=\"inline-note\">暂无有效玩家预约</span>";
            }

            return "<a class=\"btn-primary small\" href=\"GameRoom.aspx?reservationId=" + hostReservationId + "\">进入主持</a>";
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
    }
}
