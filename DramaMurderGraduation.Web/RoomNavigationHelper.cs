using System.Web;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// Builds room navigation links used by reservation-related pages.
    /// </summary>
    public static class RoomNavigationHelper
    {
        public static string RenderRoomSelectLink(ReservationInfo reservation)
        {
            var roomName = reservation == null || string.IsNullOrWhiteSpace(reservation.RoomName)
                ? "待安排"
                : reservation.RoomName;
            var encodedName = HttpUtility.HtmlEncode(roomName);

            if (reservation == null || reservation.RoomId <= 0)
            {
                return encodedName;
            }

            var url = "Rooms.aspx?roomId=" + reservation.RoomId + "#room-sessions";
            return "<a class=\"room-select-link\" href=\"" + url + "\">" + encodedName + "</a>";
        }
    }
}
