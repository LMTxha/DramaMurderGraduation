using System;

namespace DramaMurderGraduation.Web.Models
{
    public class GameClueInfo
    {
        public int Id { get; set; }
        public string StageName { get; set; }
        public string Title { get; set; }
        public string Summary { get; set; }
        public string Detail { get; set; }
        public string ClueType { get; set; }
        public bool IsPublic { get; set; }
        public int SortOrder { get; set; }
        public string RevealMethod { get; set; }
        public DateTime RevealedAt { get; set; }
        public string UnlockedByName { get; set; }
    }
}
