using System;

namespace DramaMurderGraduation.Web.Models
{
    public class ReviewInfo
    {
        public int Id { get; set; }
        public int ScriptId { get; set; }
        public string ScriptName { get; set; }
        public string ReviewerName { get; set; }
        public int Rating { get; set; }
        public string Content { get; set; }
        public DateTime ReviewDate { get; set; }
        public string HighlightTag { get; set; }
    }
}
