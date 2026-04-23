using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public partial class BookingPage : System.Web.UI.Page
    {
        private readonly ContentRepository _repository = new ContentRepository();
        private readonly AccountRepository _accountRepository = new AccountRepository();
        private int? _scriptIdFilter;
        private IList<SessionInfo> _sessionOptions;

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireLogin();
            _scriptIdFilter = ParseScriptIdFilter();

            if (!IsPostBack)
            {
                BindScriptFilter();
                BindSessions();
                BindCurrentUser();
                BindRecentReservations();
                FillContactInfo();
                UpdateBookingSummary();
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(ddlSessions.SelectedValue, out var sessionId))
            {
                ShowMessage("请选择有效场次。", false);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtContactName.Text) || string.IsNullOrWhiteSpace(txtPhone.Text))
            {
                ShowMessage("联系人和联系电话不能为空。", false);
                return;
            }

            if (!int.TryParse(txtPlayerCount.Text, out var playerCount) || playerCount <= 0 || playerCount > 8)
            {
                ShowMessage("预约人数请输入 1 到 8 之间的整数。", false);
                return;
            }

            var session = _repository.GetSessionById(sessionId);
            if (session == null || session.RemainingSeats <= 0)
            {
                BindSessions();
                UpdateBookingSummary();
                ShowMessage("当前场次已满或不可预约，请选择其他场次。", false);
                return;
            }

            if (session.RemainingSeats < playerCount)
            {
                ShowMessage("当前场次剩余名额不足，请减少人数或选择其他场次。", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var request = new BookingCreateRequest
            {
                UserId = currentUser.UserId,
                SessionId = sessionId,
                ContactName = txtContactName.Text.Trim(),
                Phone = txtPhone.Text.Trim(),
                PlayerCount = playerCount,
                Remark = txtRemark.Text.Trim()
            };

            var success = _repository.CreateReservation(request, out var reservationId, out var message);
            ShowMessage(message, success);

            if (success)
            {
                Response.Redirect("~/GameLobby.aspx?reservationId=" + reservationId, true);
                return;
            }

            BindSessions();
            UpdateBookingSummary();
        }

        private void BindSessions()
        {
            _sessionOptions = _repository.GetUpcomingSessions(50, _scriptIdFilter)
                .Where(session => session.RemainingSeats > 0)
                .ToList();

            ddlSessions.Items.Clear();
            foreach (var session in _sessionOptions)
            {
                var text = $"{session.SessionDateTime:MM-dd HH:mm} | {session.ScriptName} | {session.RoomName} | ￥{session.BasePrice:F0}/人 | 剩余 {session.RemainingSeats} 位";
                ddlSessions.Items.Add(new ListItem(text, session.Id.ToString()));
            }

            if (ddlSessions.Items.Count == 0)
            {
                ddlSessions.Items.Add(new ListItem("暂无可预约场次，请稍后再试", string.Empty));
                ddlSessions.Enabled = false;
                btnSubmit.Enabled = false;
                btnSubmit.Text = "暂无可预约场次";
                btnSubmit.CssClass = "btn-primary wide-button booking-submit-button booking-submit-disabled";
                ShowMessage("当前剧本的开放场次已经满员，暂时不能继续预约。请等待管理员新增排期，或选择其他剧本/场次。", false);
                return;
            }

            ddlSessions.Enabled = true;
            btnSubmit.Enabled = true;
            btnSubmit.Text = "提交预约";
            btnSubmit.CssClass = "btn-primary wide-button booking-submit-button";

            if (int.TryParse(Request.QueryString["sessionId"], out var sessionId))
            {
                var item = ddlSessions.Items.FindByValue(sessionId.ToString());
                if (item != null)
                {
                    ddlSessions.ClearSelection();
                    item.Selected = true;
                }
                return;
            }

            SelectBestSession();
        }

        protected void ddlSessions_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdateBookingSummary();
        }

        protected void txtPlayerCount_TextChanged(object sender, EventArgs e)
        {
            UpdateBookingSummary();
        }

        private void BindRecentReservations()
        {
            rptRecentReservations.DataSource = _repository.GetRecentReservations(6);
            rptRecentReservations.DataBind();
        }

        private void BindCurrentUser()
        {
            var currentUser = AuthManager.GetCurrentUser();
            var latestUser = _accountRepository.GetUserById(currentUser.UserId);
            if (latestUser == null)
            {
                AuthManager.SignOut();
                Response.Redirect("~/Login.aspx");
                return;
            }

            AuthManager.SignIn(AuthManager.CreateCurrentUser(latestUser));
            litWalletBalance.Text = latestUser.Balance.ToString("F2");
        }

        private void FillContactInfo()
        {
            var currentUser = AuthManager.GetCurrentUser();
            if (currentUser == null)
            {
                return;
            }

            if (string.IsNullOrWhiteSpace(txtContactName.Text))
            {
                txtContactName.Text = currentUser.DisplayName;
            }

            if (string.IsNullOrWhiteSpace(txtPhone.Text))
            {
                txtPhone.Text = currentUser.Phone;
            }
        }

        private void UpdateBookingSummary()
        {
            if (!int.TryParse(ddlSessions.SelectedValue, out var sessionId))
            {
                litSelectedSession.Text = "暂无可预约场次";
                litRemainingSeats.Text = "0";
                litUnitPrice.Text = "0.00";
                litEstimatedAmount.Text = "0.00";
                return;
            }

            var session = _repository.GetSessionById(sessionId);
            if (session == null || session.RemainingSeats <= 0)
            {
                litSelectedSession.Text = "当前场次不可预约";
                litRemainingSeats.Text = "0";
                litUnitPrice.Text = "0.00";
                litEstimatedAmount.Text = "0.00";
                return;
            }

            var playerCount = 0;
            if (!int.TryParse(txtPlayerCount.Text, out playerCount) || playerCount <= 0)
            {
                playerCount = 1;
            }

            litSelectedSession.Text = session.ScriptName + " / " + session.RoomName;
            litRemainingSeats.Text = session.RemainingSeats.ToString();
            litUnitPrice.Text = session.BasePrice.ToString("F2");
            litEstimatedAmount.Text = (session.BasePrice * playerCount).ToString("F2");
        }

        private void SelectBestSession()
        {
            if (_sessionOptions == null || _sessionOptions.Count == 0)
            {
                return;
            }

            var desiredPlayerCount = 1;
            if (int.TryParse(txtPlayerCount.Text, out var parsedPlayerCount) && parsedPlayerCount > 0)
            {
                desiredPlayerCount = parsedPlayerCount;
            }

            var preferredSession = _sessionOptions
                .Where(session => session.RemainingSeats >= desiredPlayerCount)
                .OrderByDescending(session => session.RemainingSeats)
                .ThenBy(session => session.SessionDateTime)
                .FirstOrDefault()
                ?? _sessionOptions
                    .OrderByDescending(session => session.RemainingSeats)
                    .ThenBy(session => session.SessionDateTime)
                    .FirstOrDefault();

            if (preferredSession == null)
            {
                return;
            }

            var selectedItem = ddlSessions.Items.FindByValue(preferredSession.Id.ToString());
            if (selectedItem == null)
            {
                return;
            }

            ddlSessions.ClearSelection();
            selectedItem.Selected = true;
        }

        private void BindScriptFilter()
        {
            if (!_scriptIdFilter.HasValue)
            {
                phScriptFilter.Visible = false;
                litBookingIntro.Text = "登录后可先充值站内余额，再按场次单价完成预约扣费，系统会同步写入预约记录与支付流水。";
                return;
            }

            var script = _repository.GetScriptDetail(_scriptIdFilter.Value);
            if (script == null)
            {
                phScriptFilter.Visible = false;
                litBookingIntro.Text = "当前筛选剧本不存在或未开放预约，下面将展示全部可预约场次。";
                _scriptIdFilter = null;
                return;
            }

            phScriptFilter.Visible = true;
            litCurrentScriptName.Text = script.Name;
            litBookingIntro.Text = "你正在预约《" + script.Name + "》，页面已自动筛选出这个剧本的可预约场次。";
        }

        private int? ParseScriptIdFilter()
        {
            if (!int.TryParse(Request.QueryString["scriptId"], out var scriptId) || scriptId <= 0)
            {
                return null;
            }

            return scriptId;
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = success ? "status-message success" : "status-message error";
            litMessage.Text = message;
        }
    }
}



