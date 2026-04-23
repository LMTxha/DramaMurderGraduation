namespace DramaMurderGraduation.Web.Models
{
    public class LiveSessionInfo
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Summary { get; set; }
        public string HostName { get; set; }
        public int ViewerCount { get; set; }
        public string CoverImage { get; set; }
        public string RouteUrl { get; set; }
        public string StatusText { get; set; }
        public int HeatScore { get; set; }
    }
}
