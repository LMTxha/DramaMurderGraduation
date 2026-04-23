namespace DramaMurderGraduation.Web.Models
{
    public class ScriptInfo
    {
        public int Id { get; set; }
        public int GenreId { get; set; }
        public string GenreName { get; set; }
        public string Name { get; set; }
        public string Slogan { get; set; }
        public string StoryBackground { get; set; }
        public string FullScriptContent { get; set; }
        public string CoverImage { get; set; }
        public int DurationMinutes { get; set; }
        public int PlayerMin { get; set; }
        public int PlayerMax { get; set; }
        public string Difficulty { get; set; }
        public decimal Price { get; set; }
        public bool IsFeatured { get; set; }
        public string Status { get; set; }
        public string AuthorName { get; set; }
        public decimal AverageRating { get; set; }
        public int ReviewCount { get; set; }
        public int UpcomingSessionCount { get; set; }
        public int? CreatorUserId { get; set; }
        public string CreatorDisplayName { get; set; }
        public string AuditStatus { get; set; }
        public string AuditComment { get; set; }
        public System.DateTime? SubmittedAt { get; set; }
        public System.DateTime? ReviewedAt { get; set; }
    }
}
