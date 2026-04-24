using System;
using System.Web;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    public partial class CheckInPassPage : System.Web.UI.Page
    {
        private readonly ContentRepository _repository = new ContentRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireApprovedUser();

            if (!IsPostBack)
            {
                BindPage();
            }
        }

        private void BindPage()
        {
            var currentUser = AuthManager.GetCurrentUser();
            if (currentUser == null || !int.TryParse(Request.QueryString["reservationId"], out var reservationId) || reservationId <= 0)
            {
                ShowNotFound();
                return;
            }

            var reservation = _repository.GetReservationDetail(reservationId, currentUser.IsAdmin ? (int?)null : currentUser.UserId);
            if (reservation == null)
            {
                ShowNotFound();
                return;
            }

            pnlNotFound.Visible = false;
            pnlPass.Visible = true;

            litReservationId.Text = reservation.Id.ToString();
            litScriptName.Text = Server.HtmlEncode(reservation.ScriptName);
            litSessionTime.Text = reservation.SessionDateTime.ToString("yyyy-MM-dd HH:mm");
            litRoomName.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(reservation.RoomName) ? "待安排" : reservation.RoomName);
            litHostName.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(reservation.HostName) ? "待分配" : reservation.HostName);
            litCheckInCode.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(reservation.CheckInCode) ? "待生成" : reservation.CheckInCode);
            litStatus.Text = Server.HtmlEncode(reservation.CheckedInAt.HasValue ? "已于 " + reservation.CheckedInAt.Value.ToString("MM-dd HH:mm") + " 完成核销" : reservation.Status);
            litArrivalAdvice.Text = Server.HtmlEncode(BuildArrivalAdvice(reservation.SessionDateTime, reservation.CheckedInAt.HasValue));
            imgQrCode.ImageUrl = BuildQrUrl(reservation.Id, reservation.CheckInCode);
            lnkOrderDetails.NavigateUrl = "OrderDetails.aspx?reservationId=" + reservation.Id;
        }

        private static string BuildQrUrl(int reservationId, string checkInCode)
        {
            var payload = "DM-CHECKIN|" + reservationId + "|" + (checkInCode ?? string.Empty).Trim();
            return "https://api.qrserver.com/v1/create-qr-code/?size=240x240&data=" + HttpUtility.UrlEncode(payload);
        }

        private static string BuildArrivalAdvice(DateTime sessionDateTime, bool checkedIn)
        {
            if (checkedIn)
            {
                return "已完成核销，可直接跟随现场 DM 引导入座。";
            }

            var minutes = (int)Math.Round((sessionDateTime - DateTime.Now).TotalMinutes);
            if (minutes <= 0)
            {
                return "当前已到开场时间，请尽快到店并出示核销码。";
            }

            if (minutes <= 30)
            {
                return "距离开场不足 30 分钟，建议现在出发。";
            }

            if (minutes <= 120)
            {
                return "距离开场不足 2 小时，请确认同行玩家和交通安排。";
            }

            return "建议开场前 20 分钟到店，方便核销和入场准备。";
        }

        private void ShowNotFound()
        {
            pnlNotFound.Visible = true;
            pnlPass.Visible = false;
        }
    }
}
