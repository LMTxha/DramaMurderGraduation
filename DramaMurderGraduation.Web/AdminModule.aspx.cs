using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// 后台模块详情页后台逻辑：根据地址栏 module 参数决定展示哪一类运营数据。
    /// </summary>
    public partial class AdminModulePage : Page
    {
        private readonly AccountRepository _accountRepository = new AccountRepository();
        private readonly ContentRepository _contentRepository = new ContentRepository();

        /// <summary>
        /// 页面加载时先校验后台权限，首次进入时再绑定模块数据。
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireAdminConsole();

            if (!IsPostBack)
            {
                BindModule();
            }
        }

        protected bool HasActionUrl(object value)
        {
            return !string.IsNullOrWhiteSpace(Convert.ToString(value));
        }

        /// <summary>
        /// 处理列表中的按钮命令，目前主要用于清理已结束的预约订单记录。
        /// </summary>
        protected void rptModuleItems_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "DeleteReservation")
            {
                return;
            }

            var currentUser = AuthManager.GetBackofficeUser();
            if (currentUser == null || !currentUser.CanManageOperations)
            {
                ShowMessage("当前账号不能删除预约订单信息。", false);
                return;
            }

            if (!int.TryParse(Convert.ToString(e.CommandArgument), out var reservationId) || reservationId <= 0)
            {
                ShowMessage("未找到要删除的订单信息。", false);
                return;
            }

            var success = _contentRepository.DeleteTerminalReservation(reservationId, currentUser.UserId, out var message);
            ShowMessage(message, success);
            BindModule();
        }

        /// <summary>
        /// 读取 module 参数并构造当前模块视图，统一设置标题、摘要、数量和列表数据。
        /// </summary>
        private void BindModule()
        {
            var currentUser = AuthManager.GetBackofficeUser();
            var moduleKey = (Request.QueryString["module"] ?? "reservations").Trim().ToLowerInvariant();
            var module = BuildModule(moduleKey, currentUser);

            litPageTitle.Text = module.Title + " | 后台模块详情";
            litModuleTitle.Text = module.Title;
            litModuleSummary.Text = module.Summary;
            lnkBackToAdmin.NavigateUrl = module.BackUrl;

            if (!module.Allowed)
            {
                pnlAccessDenied.Visible = true;
                litAccessDenied.Text = "当前账号没有查看该模块的权限。";
                rptModuleItems.DataSource = new List<AdminModuleItem>();
                rptModuleItems.DataBind();
                litModuleCount.Text = "0";
                return;
            }

            litModuleCount.Text = module.Items.Count.ToString();
            pnlEmpty.Visible = module.Items.Count == 0;
            rptModuleItems.DataSource = module.Items;
            rptModuleItems.DataBind();
        }

        /// <summary>
        /// 按模块标识分发到对应的数据构建方法，是后台总览与详情列表之间的路由入口。
        /// </summary>
        private AdminModuleView BuildModule(string moduleKey, CurrentUserInfo currentUser)
        {
            switch (moduleKey)
            {
                case "pending-users":
                    return BuildPendingUsersModule(currentUser);
                case "pending-recharge":
                    return BuildPendingRechargeModule(currentUser);
                case "pending-scripts":
                    return BuildPendingScriptsModule(currentUser);
                case "store-visits":
                    return BuildStoreVisitsModule(currentUser, "到店联系单", "集中查看所有到店咨询、试玩、改期和特殊接待需求。", null, "AdminReview.aspx#store-requests");
                case "reservations":
                    return BuildReservationsModule(currentUser, "预约订单", "集中查看预约订单、到店核销、支付状态和用户备注。", null, "AdminReview.aspx#reservation-orders");
                case "scripts":
                    return BuildScriptsModule(currentUser);
                case "today-store":
                    return BuildStoreVisitsModule(currentUser, "今日到店", "只展示今天计划到店的联系单，方便前台安排接待。", item => item.PreferredArriveTime.Date == DateTime.Today, "AdminReview.aspx#store-requests");
                case "today-reservations":
                    return BuildReservationsModule(currentUser, "今日预约", "只展示今天需要履约处理的预约订单。", item => item.SessionDateTime.Date == DateTime.Today, "AdminReview.aspx#reservation-orders");
                case "upcoming-sessions":
                    return BuildUpcomingSessionsModule(currentUser);
                case "announcements":
                    return BuildAnnouncementsModule(currentUser);
                case "arranged-store":
                    return BuildStoreVisitsModule(currentUser, "已安排到店", "展示已经安排房间或到店完成的联系单。", item => item.RequestStatus == "已安排排期" || item.RequestStatus == "已到店完成", "AdminReview.aspx#store-requests");
                case "confirmed-reservations":
                    return BuildReservationsModule(currentUser, "已确认预约", "展示已经确认或已经到店的预约订单。", item => item.Status == "已确认" || item.Status == "已到店", "AdminReview.aspx#reservation-orders");
                default:
                    return BuildReservationsModule(currentUser, "预约订单", "集中查看预约订单、到店核销、支付状态和用户备注。", null, "AdminReview.aspx#reservation-orders");
            }
        }

        /// <summary>
        /// 待审用户模块只允许成员管理权限查看，用于说明注册审核流程。
        /// </summary>
        private AdminModuleView BuildPendingUsersModule(CurrentUserInfo currentUser)
        {
            var allowed = currentUser != null && currentUser.CanManageMembers;
            var items = allowed
                ? _accountRepository.GetPendingUsers().Select(item => new AdminModuleItem
                {
                    Badge = item.ReviewStatus,
                    Title = item.DisplayName + " / " + item.Username,
                    PrimaryMeta = "手机号：" + item.Phone + " · 角色：" + DisplayRole(item.RoleCode),
                    SecondaryMeta = "注册时间：" + FormatDateTime(item.CreatedAt),
                    Description = string.IsNullOrWhiteSpace(item.ReviewRemark) ? "暂无审核备注" : item.ReviewRemark,
                    ActionText = "回到账号审核",
                    ActionUrl = "AdminReview.aspx"
                }).ToList()
                : new List<AdminModuleItem>();

            return new AdminModuleView("待审用户", "集中查看还未完成管理员审核的新注册账号。", "AdminReview.aspx", allowed, items);
        }

        /// <summary>
        /// 待审充值模块只允许财务权限查看，用于说明充值入账和钱包流水审核。
        /// </summary>
        private AdminModuleView BuildPendingRechargeModule(CurrentUserInfo currentUser)
        {
            var allowed = currentUser != null && currentUser.CanManageFinance;
            var items = allowed
                ? _accountRepository.GetPendingRechargeRequests().Select(item => new AdminModuleItem
                {
                    Badge = item.RequestStatus,
                    Title = item.DisplayName + " / ￥" + item.Amount.ToString("F2"),
                    PrimaryMeta = "充值单号：" + item.RechargeOrderNo + " · 方式：" + item.PaymentMethod,
                    SecondaryMeta = "提交时间：" + FormatDateTime(item.SubmittedAt),
                    Description = "付款账号：" + item.PaymentAccountMasked,
                    ActionText = "回到充值审核",
                    ActionUrl = "AdminReview.aspx"
                }).ToList()
                : new List<AdminModuleItem>();

            return new AdminModuleView("待审充值", "集中查看需要财务确认入账的充值申请。", "AdminReview.aspx", allowed, items);
        }

        /// <summary>
        /// 待审剧本模块展示创作者提交后的内容审核状态。
        /// </summary>
        private AdminModuleView BuildPendingScriptsModule(CurrentUserInfo currentUser)
        {
            var allowed = currentUser != null && currentUser.CanManageContent;
            var items = allowed
                ? _contentRepository.GetPendingScriptSubmissions().Select(item => new AdminModuleItem
                {
                    Badge = item.AuditStatus,
                    Title = item.Name,
                    PrimaryMeta = "作者：" + item.CreatorDisplayName + " · 类型：" + item.GenreName,
                    SecondaryMeta = "人数：" + item.PlayerMin + "-" + item.PlayerMax + " · 时长：" + item.DurationMinutes + " 分钟",
                    Description = item.Slogan,
                    ActionText = "回到剧本审核",
                    ActionUrl = "AdminReview.aspx#script-admin"
                }).ToList()
                : new List<AdminModuleItem>();

            return new AdminModuleView("待审剧本", "集中查看创作者提交后等待审核的剧本。", "AdminReview.aspx#script-admin", allowed, items);
        }

        /// <summary>
        /// 到店联系单模块可以按今日到店、已安排等条件过滤接待需求。
        /// </summary>
        private AdminModuleView BuildStoreVisitsModule(CurrentUserInfo currentUser, string title, string summary, Func<StoreVisitRequestInfo, bool> predicate, string backUrl)
        {
            var allowed = currentUser != null && currentUser.CanManageOperations;
            var query = allowed ? _contentRepository.GetStoreVisitRequests(999).AsEnumerable() : Enumerable.Empty<StoreVisitRequestInfo>();
            if (predicate != null)
            {
                query = query.Where(predicate);
            }

            var items = query.Select(item => new AdminModuleItem
            {
                Badge = item.RequestStatus,
                Title = item.ContactName + " · " + item.ScriptName,
                PrimaryMeta = "到店时间：" + FormatDateTime(item.PreferredArriveTime) + " · 人数：" + item.TeamSize,
                SecondaryMeta = "手机：" + item.PhoneMasked + " · 房间：" + EmptyText(item.AssignedRoomName),
                Description = string.IsNullOrWhiteSpace(item.Note) ? "暂无用户备注" : item.Note,
                ActionText = "回到联系单处理",
                ActionUrl = backUrl
            }).ToList();

            return new AdminModuleView(title, summary, backUrl, allowed, items);
        }

        /// <summary>
        /// 预约订单模块支持按今日、已确认等条件筛选，便于后台跟进履约状态。
        /// </summary>
        private AdminModuleView BuildReservationsModule(CurrentUserInfo currentUser, string title, string summary, Func<ReservationInfo, bool> predicate, string backUrl)
        {
            var allowed = currentUser != null && currentUser.CanManageOperations;
            var query = allowed ? _contentRepository.GetReservationsForAdmin(999).AsEnumerable() : Enumerable.Empty<ReservationInfo>();
            if (predicate != null)
            {
                query = query.Where(predicate);
            }

            var items = query.Select(item => new AdminModuleItem
            {
                Badge = item.Status,
                Title = "订单 #" + item.Id + " · " + item.ScriptName,
                PrimaryMeta = "开场：" + FormatDateTime(item.SessionDateTime) + " · 人数：" + item.PlayerCount + " · 支付：" + item.PaymentStatus,
                SecondaryMeta = "联系人：" + item.ContactName + " · 手机：" + item.PhoneMasked + " · 房间：" + item.RoomName,
                Description = string.IsNullOrWhiteSpace(item.Remark) ? "暂无玩家备注" : item.Remark,
                ActionText = "订单详情",
                ActionUrl = "OrderDetails.aspx?reservationId=" + item.Id,
                ReservationId = item.Id,
                CanDeleteReservation = CanDeleteReservation(item.Status)
            }).ToList();

            return new AdminModuleView(title, summary, backUrl, allowed, items);
        }

        /// <summary>
        /// 剧本总数模块汇总后台可管理的全部剧本条目。
        /// </summary>
        private AdminModuleView BuildScriptsModule(CurrentUserInfo currentUser)
        {
            var allowed = currentUser != null && currentUser.CanManageContent;
            var items = allowed
                ? _contentRepository.GetAllScriptsForAdmin().Select(item => new AdminModuleItem
                {
                    Badge = item.AuditStatus,
                    Title = item.Name,
                    PrimaryMeta = "类型：" + item.GenreName + " · 作者：" + item.CreatorDisplayName,
                    SecondaryMeta = "人数：" + item.PlayerMin + "-" + item.PlayerMax + " · 价格：￥" + item.Price.ToString("F2"),
                    Description = item.Slogan,
                    ActionText = "剧本详情",
                    ActionUrl = "ScriptDetails.aspx?id=" + item.Id
                }).ToList()
                : new List<AdminModuleItem>();

            return new AdminModuleView("剧本总数", "集中查看当前剧本库中全部剧本条目。", "AdminReview.aspx#script-admin", allowed, items);
        }

        /// <summary>
        /// 未来场次模块展示已经创建但尚未开始的可预约排期。
        /// </summary>
        private AdminModuleView BuildUpcomingSessionsModule(CurrentUserInfo currentUser)
        {
            var allowed = currentUser != null && currentUser.CanManageOperations;
            var items = allowed
                ? _contentRepository.GetUpcomingSessions(999).Select(item => new AdminModuleItem
                {
                    Badge = item.Status,
                    Title = item.ScriptName + " / " + item.RoomName,
                    PrimaryMeta = "开场：" + FormatDateTime(item.SessionDateTime) + " · 主持：" + item.HostName,
                    SecondaryMeta = "人数：" + item.ReservedPlayers + "/" + item.MaxPlayers + " · 剩余：" + item.RemainingSeats,
                    Description = string.IsNullOrWhiteSpace(item.HostBriefing) ? "暂无主持备注" : item.HostBriefing,
                    ActionText = "查看预约页",
                    ActionUrl = "Booking.aspx?sessionId=" + item.Id
                }).ToList()
                : new List<AdminModuleItem>();

            return new AdminModuleView("未来场次", "集中查看已创建但尚未开场的可预约排期。", "AdminReview.aspx#room-session-admin", allowed, items);
        }

        /// <summary>
        /// 公告模块展示站内运营通知，便于说明后台内容发布能力。
        /// </summary>
        private AdminModuleView BuildAnnouncementsModule(CurrentUserInfo currentUser)
        {
            var allowed = currentUser != null && (currentUser.CanManageOperations || currentUser.CanManageContent);
            var items = allowed
                ? _contentRepository.GetAnnouncements(999).Select(item => new AdminModuleItem
                {
                    Badge = item.IsImportant ? "重要" : "普通",
                    Title = item.Title,
                    PrimaryMeta = "发布时间：" + FormatDateTime(item.PublishDate),
                    SecondaryMeta = item.IsImportant ? "重要公告" : "普通公告",
                    Description = item.Summary,
                    ActionText = "回到公告发布",
                    ActionUrl = "AdminReview.aspx#announcements-admin"
                }).ToList()
                : new List<AdminModuleItem>();

            return new AdminModuleView("公告数量", "集中查看当前站内公告和运营通知。", "AdminReview.aspx#announcements-admin", allowed, items);
        }

        private static string FormatDateTime(DateTime value)
        {
            return value == DateTime.MinValue ? "未记录" : value.ToString("yyyy-MM-dd HH:mm");
        }

        private static string EmptyText(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? "未填写" : value;
        }

        private static string DisplayRole(string roleCode)
        {
            return new CurrentUserInfo { RoleCode = roleCode, ReviewStatus = "Approved" }.RoleDisplayName;
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = success ? "status-message success" : "status-message error";
            litMessage.Text = message;
        }

        private static bool CanDeleteReservation(string status)
        {
            return string.Equals(status, "已取消", StringComparison.Ordinal)
                   || string.Equals(status, "已完成", StringComparison.Ordinal);
        }

        private sealed class AdminModuleView
        {
            public AdminModuleView(string title, string summary, string backUrl, bool allowed, IList<AdminModuleItem> items)
            {
                Title = title;
                Summary = summary;
                BackUrl = backUrl;
                Allowed = allowed;
                Items = items ?? new List<AdminModuleItem>();
            }

            public string Title { get; private set; }
            public string Summary { get; private set; }
            public string BackUrl { get; private set; }
            public bool Allowed { get; private set; }
            public IList<AdminModuleItem> Items { get; private set; }
        }

        private sealed class AdminModuleItem
        {
            public string Badge { get; set; }
            public string Title { get; set; }
            public string PrimaryMeta { get; set; }
            public string SecondaryMeta { get; set; }
            public string Description { get; set; }
            public string ActionText { get; set; }
            public string ActionUrl { get; set; }
            public int ReservationId { get; set; }
            public bool CanDeleteReservation { get; set; }
        }
    }
}
