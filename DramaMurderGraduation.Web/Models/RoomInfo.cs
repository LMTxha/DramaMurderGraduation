namespace DramaMurderGraduation.Web.Models
{
    public class RoomInfo
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Theme { get; set; }
        public int Capacity { get; set; }
        public string Description { get; set; }
        public string ImageUrl { get; set; }
        public string Status { get; set; }
        public int UpcomingSessionCount { get; set; }
        public int PrimarySessionId { get; set; }
    }
}
