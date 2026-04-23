using System;
using System.Linq;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public partial class RoomsPage : System.Web.UI.Page
    {
        public RoomInfo SelectedRoom { get; private set; }
        public bool HasVisibleSessions { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            var repository = new ContentRepository();
            var rooms = repository.GetRooms().ToList();
            var sessions = repository.GetUpcomingSessions(20).ToList();
            var selectedRoomId = ParseRoomId();

            SelectedRoom = rooms.FirstOrDefault(room => room.Id == selectedRoomId);
            if (SelectedRoom != null)
            {
                sessions = sessions.Where(session => session.RoomId == SelectedRoom.Id).ToList();
            }

            HasVisibleSessions = sessions.Count > 0;

            rptRooms.DataSource = rooms;
            rptRooms.DataBind();

            rptSessions.DataSource = sessions;
            rptSessions.DataBind();
        }

        public string GetRoomCardClass(object roomId)
        {
            return SelectedRoom != null && SelectedRoom.Id == SafeToInt(roomId)
                ? "room-card click-card interactive-card room-card-active"
                : "room-card click-card interactive-card";
        }

        public string GetRoomSessionsUrl(object roomId)
        {
            return "Rooms.aspx?roomId=" + SafeToInt(roomId) + "#room-sessions";
        }

        public string GetRoomBookingUrl(object primarySessionId, object roomId)
        {
            var sessionId = SafeToInt(primarySessionId);
            return sessionId > 0
                ? "Booking.aspx?sessionId=" + sessionId
                : GetRoomSessionsUrl(roomId);
        }

        public string GetRoomBookingLabel(object primarySessionId)
        {
            return SafeToInt(primarySessionId) > 0 ? "最近一场可约" : "点击筛到本厅";
        }

        public string GetSessionHeading()
        {
            return SelectedRoom != null ? SelectedRoom.Name + " 的可约场次" : "近期开放场次";
        }

        public string GetSessionDescription()
        {
            return SelectedRoom != null
                ? "已经帮你筛到 " + SelectedRoom.Name + " 的开场安排，选好时间就能直接去预约。"
                : "点开房间卡片可以快速筛到对应场次，也可以直接从下面挑一场开玩。";
        }

        private int? ParseRoomId()
        {
            return int.TryParse(Request.QueryString["roomId"], out var roomId) ? roomId : (int?)null;
        }

        private static int SafeToInt(object value)
        {
            return value != null && int.TryParse(value.ToString(), out var parsed) ? parsed : 0;
        }
    }
}
