namespace DramaMurderGraduation.Web.Models
{
    public class SpectatorRoomInfo
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string ScriptName { get; set; }
        public string HostName { get; set; }
        public int ViewerCount { get; set; }
        public int HeatScore { get; set; }
        public string CoverImage { get; set; }
        public string RoomStatus { get; set; }
        public string RouteCode { get; set; }
    }
}
