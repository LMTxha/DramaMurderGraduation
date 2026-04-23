namespace DramaMurderGraduation.Web.Models
{
    public class RecommendationInfo
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Summary { get; set; }
        public string CoverImage { get; set; }
        public int PlayerCount { get; set; }
        public string Difficulty { get; set; }
        public decimal Rating { get; set; }
        public string HighlightTag { get; set; }
        public string DestinationUrl { get; set; }
    }
}
