using System;
using System.Linq;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// Rooms.aspx 页面后台逻辑，负责当前 Web Forms 页面的权限校验、数据绑定和事件处理。
    /// </summary>
    public partial class RoomsPage : System.Web.UI.Page
    {
        public RoomInfo SelectedRoom { get; private set; }
        public bool HasVisibleSessions { get; private set; }
        public bool HasMyRooms { get; private set; }

        /// <summary>
        /// 页面生命周期入口，负责权限校验和首次加载时的数据初始化。
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            var repository = new ContentRepository();
            var currentUser = AuthManager.GetCurrentUser();
            var rooms = repository.GetRooms().ToList();
            var sessions = repository.GetUpcomingSessions(20).ToList();
            var selectedRoomId = ParseRoomId();
            var myRooms = currentUser == null
                ? Enumerable.Empty<ReservationInfo>()
                : repository.GetReservationsForUser(currentUser.UserId, 30)
                    .Where(IsReentryReservation)
                    .OrderByDescending(reservation => reservation.SessionDateTime);

            SelectedRoom = rooms.FirstOrDefault(room => room.Id == selectedRoomId);
            if (SelectedRoom != null)
            {
                sessions = sessions.Where(session => session.RoomId == SelectedRoom.Id).ToList();
                myRooms = myRooms.Where(reservation => reservation.RoomId == SelectedRoom.Id);
            }

            HasVisibleSessions = sessions.Count > 0;
            var myRoomList = myRooms.ToList();
            HasMyRooms = myRoomList.Count > 0;

            rptRooms.DataSource = rooms;
            rptRooms.DataBind();

            rptMyRooms.DataSource = myRoomList;
            rptMyRooms.DataBind();

            rptSessions.DataSource = sessions;
            rptSessions.DataBind();
        }

        /// <summary>
        /// 获取页面展示或业务判断所需的数据。
        /// </summary>
        public string GetRoomCardClass(object roomId)
        {
            return SelectedRoom != null && SelectedRoom.Id == SafeToInt(roomId)
                ? "room-card click-card interactive-card room-card-active"
                : "room-card click-card interactive-card";
        }

        /// <summary>
        /// 获取页面展示或业务判断所需的数据。
        /// </summary>
        public string GetRoomSessionsUrl(object roomId)
        {
            return "Rooms.aspx?roomId=" + SafeToInt(roomId) + "#room-sessions";
        }

        /// <summary>
        /// 获取页面展示或业务判断所需的数据。
        /// </summary>
        public string GetRoomBookingUrl(object primarySessionId, object roomId)
        {
            var sessionId = SafeToInt(primarySessionId);
            return sessionId > 0
                ? "Booking.aspx?sessionId=" + sessionId
                : GetRoomSessionsUrl(roomId);
        }

        /// <summary>
        /// 获取页面展示或业务判断所需的数据。
        /// </summary>
        public string GetRoomBookingLabel(object primarySessionId)
        {
            return SafeToInt(primarySessionId) > 0 ? "最近一场可约" : "点击筛到本厅";
        }

        /// <summary>
        /// 获取页面展示或业务判断所需的数据。
        /// </summary>
        public string GetSessionHeading()
        {
            return SelectedRoom != null ? SelectedRoom.Name + " 的可约场次" : "近期开放场次";
        }

        /// <summary>
        /// 获取页面展示或业务判断所需的数据。
        /// </summary>
        public string GetSessionDescription()
        {
            return SelectedRoom != null
                ? "已经帮你筛到 " + SelectedRoom.Name + " 的开场安排，选好时间就能直接去预约。"
                : "点开房间卡片可以快速筛到对应场次，也可以直接从下面挑一场开玩。";
        }

        public string GetMyRoomHeading()
        {
            return SelectedRoom != null ? SelectedRoom.Name + " 的我的房间" : "我的房间";
        }

        public string GetMyRoomDescription()
        {
            return SelectedRoom != null
                ? "你在这个主题房间里已经占位的游戏会保留在这里，关掉网页后也能从这里继续进入。"
                : "只要没有主动退出游戏，已经预约的场次都会保留入口，回来后可以直接继续游戏。";
        }

        private static bool IsReentryReservation(ReservationInfo reservation)
        {
            return reservation != null &&
                (string.Equals(reservation.Status, "待确认", StringComparison.OrdinalIgnoreCase) ||
                 string.Equals(reservation.Status, "已确认", StringComparison.OrdinalIgnoreCase) ||
                 string.Equals(reservation.Status, "玩家已确认", StringComparison.OrdinalIgnoreCase) ||
                 string.Equals(reservation.Status, "已到店", StringComparison.OrdinalIgnoreCase));
        }

        private int? ParseRoomId()
        {
            return int.TryParse(Request.QueryString["roomId"], out var roomId) ? roomId : (int?)null;
        }

        /// <summary>
        /// 页面辅助方法，封装当前页面使用的局部业务逻辑。
        /// </summary>
        private static int SafeToInt(object value)
        {
            return value != null && int.TryParse(value.ToString(), out var parsed) ? parsed : 0;
        }
    }
}
