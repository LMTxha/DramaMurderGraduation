namespace DramaMurderGraduation.Web.Models
{
    public class ScriptSubmissionRequest
    {
        public int GenreId { get; set; }
        public string Name { get; set; }
        public string Slogan { get; set; }
        public string StoryBackground { get; set; }
        public string CoverImage { get; set; }
        public int DurationMinutes { get; set; }
        public int PlayerMin { get; set; }
        public int PlayerMax { get; set; }
        public string Difficulty { get; set; }
        public decimal Price { get; set; }
        public string AuthorName { get; set; }
    }
}
