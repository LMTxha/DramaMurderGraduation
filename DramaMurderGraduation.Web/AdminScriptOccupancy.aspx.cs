using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// 剧本占用页后台逻辑，统计剧本排期、房间占用和相关预约情况。
    /// </summary>
    public partial class AdminScriptOccupancyPage : System.Web.UI.Page
    {
        private static readonly HashSet<string> ActiveReservationStatuses = new HashSet<string>(StringComparer.Ordinal)
        {
            "待确认",
            "已确认",
            "申请改期",
            "玩家已确认",
            "已到店"
        };

        private readonly ContentRepository _repository = new ContentRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireAdminConsole();

            var currentUser = AuthManager.GetCurrentUser();
            if (currentUser == null || !currentUser.CanManageOperations)
            {
                Response.Redirect("AdminReview.aspx", true);
                return;
            }

            if (!IsPostBack)
            {
                BindAll();
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindAll();
        }

        protected void rptReservations_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!string.Equals(e.CommandName, "CancelOccupancy", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            if (!int.TryParse(Convert.ToString(e.CommandArgument), out var reservationId))
            {
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _repository.ReviewReservation(
                reservationId,
                "已取消",
                null,
                "管理员在剧本占用情况中取消占用。",
                "门店已取消本次预约，占用名额已释放。",
                currentUser == null ? 0 : currentUser.UserId,
                out var message);

            ShowMessage(message, success);
            BindAll();
        }

        private void BindAll()
        {
            var selectedScriptId = GetSelectedScriptId();
            var scripts = _repository.GetScripts(txtKeyword.Text.Trim(), null);
            var activeReservations = _repository.GetReservationsForAdmin(999)
                .Where(item => ActiveReservationStatuses.Contains(item.Status))
                .ToList();

            var cards = scripts.Select(script =>
            {
                var reservations = GetRelatedReservations(script, activeReservations);
                return new ScriptOccupancyCard
                {
                    Id = script.Id,
                    Name = script.Name,
                    Slogan = script.Slogan,
                    CoverImage = script.CoverImage,
                    GenreName = script.GenreName,
                    Difficulty = script.Difficulty,
                    ActiveReservationCount = reservations.Count,
                    OccupiedPlayerCount = reservations.Sum(item => item.PlayerCount),
                    OccupiedRoomCount = reservations.Select(item => item.RoomName).Where(name => !string.IsNullOrWhiteSpace(name)).Distinct().Count(),
                    FutureSessionCount = script.UpcomingSessionCount,
                    SelectedCssClass = selectedScriptId == script.Id ? "is-selected" : string.Empty
                };
            }).ToList();

            litScriptCount.Text = cards.Count.ToString();
            rptScripts.DataSource = cards;
            rptScripts.DataBind();

            pnlScriptList.Visible = !selectedScriptId.HasValue;
            pnlScriptDetail.Visible = selectedScriptId.HasValue;
            BindSelectedScriptDetail(selectedScriptId, scripts, activeReservations);
        }

        private void BindSelectedScriptDetail(int? selectedScriptId, IList<ScriptInfo> scripts, IList<ReservationInfo> activeReservations)
        {
            if (!selectedScriptId.HasValue)
            {
                litPageHeading.Text = "剧本占用情况";
                litPageSubtitle.Text = "按剧本查看当前有效预约、玩家占用名额和房间场地安排，管理员可直接取消占用并释放名额。";
                litSelectedScriptName.Text = "选择一个剧本查看占用";
                litSelectedSummary.Text = "上方剧本卡片会显示当前占用订单、占用人数和占用场地数量。";
                BindSelectedSummary(0, 0, new List<string>());
                litSelectedFutureSessionCount.Text = "0";
                pnlEmptyDetail.Visible = false;
                rptReservations.DataSource = new List<ReservationInfo>();
                rptReservations.DataBind();
                return;
            }

            var selectedScript = scripts.FirstOrDefault(item => item.Id == selectedScriptId.Value)
                ?? _repository.GetScriptDetail(selectedScriptId.Value);

            var reservations = GetRelatedReservations(selectedScript, activeReservations)
                .OrderBy(item => item.SessionDateTime)
                .ThenBy(item => item.Id)
                .ToList();
            var occupiedRooms = reservations
                .Select(item => item.RoomName)
                .Where(name => !string.IsNullOrWhiteSpace(name))
                .Distinct(StringComparer.Ordinal)
                .ToList();
            var scriptName = selectedScript == null ? "剧本" : selectedScript.Name;

            litPageHeading.Text = scriptName + " 占用情况";
            litPageSubtitle.Text = "这里展示该剧本当前真实占用订单、占用人数、占用场地，以及每一笔仍占用名额的预约。";
            litSelectedScriptName.Text = scriptName + " 占用明细";
            litSelectedSummary.Text = "有效占用 " + reservations.Count + " 单，占用名额 " + reservations.Sum(item => item.PlayerCount) + " 个，涉及场地 " + occupiedRooms.Count + " 个。下方会列出每一笔真实占用订单。";
            BindSelectedSummary(reservations.Count, reservations.Sum(item => item.PlayerCount), occupiedRooms);
            litSelectedFutureSessionCount.Text = (selectedScript == null ? 0 : selectedScript.UpcomingSessionCount).ToString();
            pnlEmptyDetail.Visible = reservations.Count == 0;
            rptReservations.DataSource = reservations;
            rptReservations.DataBind();
        }

        private void BindSelectedSummary(int orderCount, int playerCount, IList<string> occupiedRooms)
        {
            litSelectedOrderCount.Text = orderCount.ToString();
            litSelectedPlayerCount.Text = playerCount.ToString();
            litSelectedRoomCount.Text = (occupiedRooms == null ? 0 : occupiedRooms.Count).ToString();
            litSelectedRoomNames.Text = occupiedRooms == null || occupiedRooms.Count == 0
                ? "暂无占用场地"
                : string.Join("、", occupiedRooms);
        }

        private int? GetSelectedScriptId()
        {
            if (int.TryParse(Request.QueryString["scriptId"], out var scriptId) && scriptId > 0)
            {
                return scriptId;
            }

            return null;
        }

        private static List<ReservationInfo> GetRelatedReservations(ScriptInfo script, IEnumerable<ReservationInfo> activeReservations)
        {
            if (script == null || activeReservations == null)
            {
                return new List<ReservationInfo>();
            }

            var scriptName = NormalizeScriptName(script.Name);
            return activeReservations
                .Where(item => item.ScriptId == script.Id ||
                    (!string.IsNullOrWhiteSpace(scriptName) &&
                     string.Equals(NormalizeScriptName(item.ScriptName), scriptName, StringComparison.OrdinalIgnoreCase)))
                .GroupBy(item => item.Id)
                .Select(group => group.First())
                .ToList();
        }

        private static string NormalizeScriptName(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return string.Empty;
            }

            return new string(value.Where(ch => !char.IsWhiteSpace(ch)).ToArray());
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = success ? "status-message" : "status-message error";
            litMessage.Text = Server.HtmlEncode(message);
        }

        private sealed class ScriptOccupancyCard
        {
            public int Id { get; set; }
            public string Name { get; set; }
            public string Slogan { get; set; }
            public string CoverImage { get; set; }
            public string GenreName { get; set; }
            public string Difficulty { get; set; }
            public int ActiveReservationCount { get; set; }
            public int OccupiedPlayerCount { get; set; }
            public int OccupiedRoomCount { get; set; }
            public int FutureSessionCount { get; set; }
            public string SelectedCssClass { get; set; }
            /*
            public string AvailabilityBadge => ActiveReservationCount > 0 ? "占用中" : FutureSessionCount > 0 ? "可预约" : "无未来排期";
            public string OccupancyBadge => ActiveReservationCount > 0 ? "占用中" : "空闲";
            */
            public string AvailabilityLabel => ActiveReservationCount > 0 ? "\u5360\u7528\u4e2d" : FutureSessionCount > 0 ? "\u53ef\u9884\u7ea6" : "\u65e0\u672a\u6765\u6392\u671f";
        }
    }
}
