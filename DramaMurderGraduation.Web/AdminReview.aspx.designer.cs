namespace DramaMurderGraduation.Web
{
    public partial class AdminReviewPage
    {
        protected global::System.Web.UI.WebControls.Literal litPendingUserCount;
        protected global::System.Web.UI.WebControls.Literal litPendingRechargeCount;
        protected global::System.Web.UI.WebControls.Literal litStoreVisitCount;
        protected global::System.Web.UI.WebControls.Literal litReservationCount;
        protected global::System.Web.UI.WebControls.Literal litPendingScriptCount;
        protected global::System.Web.UI.WebControls.Literal litTotalScriptCount;
        protected global::System.Web.UI.WebControls.Literal litTodayStoreCount;
        protected global::System.Web.UI.WebControls.Literal litTodayReservationCount;
        protected global::System.Web.UI.WebControls.Literal litUpcomingSessionCount;
        protected global::System.Web.UI.WebControls.Literal litAnnouncementCount;
        protected global::System.Web.UI.WebControls.Literal litArrangedStoreCount;
        protected global::System.Web.UI.WebControls.Literal litConfirmedReservationCount;
        protected global::System.Web.UI.WebControls.Literal litPendingUserCountSummary;
        protected global::System.Web.UI.WebControls.Literal litPendingRechargeCountSummary;
        protected global::System.Web.UI.WebControls.Literal litStoreVisitCountSummary;
        protected global::System.Web.UI.WebControls.Literal litReservationCountSummary;
        protected global::System.Web.UI.WebControls.Panel pnlMessage;
        protected global::System.Web.UI.WebControls.Literal litMessage;
        protected global::System.Web.UI.WebControls.Repeater rptPendingUsers;
        protected global::System.Web.UI.WebControls.Repeater rptPendingRechargeRequests;
        protected global::System.Web.UI.WebControls.TextBox txtAdminKeyword;
        protected global::System.Web.UI.WebControls.DropDownList ddlStoreStatusFilter;
        protected global::System.Web.UI.WebControls.DropDownList ddlReservationStatusFilter;
        protected global::System.Web.UI.WebControls.DropDownList ddlAdminDateFilter;
        protected global::System.Web.UI.WebControls.Button btnApplyAdminFilter;
        protected global::System.Web.UI.WebControls.Button btnResetAdminFilter;
        protected global::System.Web.UI.WebControls.Repeater rptStoreVisitRequests;
        protected global::System.Web.UI.WebControls.Repeater rptReservationOrders;
        protected global::System.Web.UI.WebControls.Repeater rptAdminReplyLogs;
        protected global::System.Web.UI.WebControls.Repeater rptBusinessActionLogs;
        protected global::System.Web.UI.WebControls.DropDownList ddlScheduleScript;
        protected global::System.Web.UI.WebControls.DropDownList ddlScheduleRoom;
        protected global::System.Web.UI.WebControls.TextBox txtScheduleDateTime;
        protected global::System.Web.UI.WebControls.TextBox txtScheduleHostName;
        protected global::System.Web.UI.WebControls.TextBox txtSchedulePrice;
        protected global::System.Web.UI.WebControls.TextBox txtScheduleMaxPlayers;
        protected global::System.Web.UI.WebControls.Button btnCreateSession;
        protected global::System.Web.UI.WebControls.Repeater rptAdminRooms;
        protected global::System.Web.UI.WebControls.Repeater rptAdminSessions;
        protected global::System.Web.UI.WebControls.TextBox txtAnnouncementTitle;
        protected global::System.Web.UI.WebControls.TextBox txtAnnouncementSummary;
        protected global::System.Web.UI.WebControls.CheckBox chkAnnouncementImportant;
        protected global::System.Web.UI.WebControls.Button btnPublishAnnouncement;
        protected global::System.Web.UI.WebControls.Repeater rptAdminAnnouncements;
        protected global::System.Web.UI.WebControls.Repeater rptPendingScripts;
        protected global::System.Web.UI.WebControls.Repeater rptAllScripts;
    }
}
