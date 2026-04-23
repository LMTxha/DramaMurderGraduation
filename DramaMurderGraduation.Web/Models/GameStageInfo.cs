using System;

namespace DramaMurderGraduation.Web.Models
{
    public class GameStageInfo
    {
        public int Id { get; set; }
        public string StageKey { get; set; }
        public string StageName { get; set; }
        public string StageDescription { get; set; }
        public int SortOrder { get; set; }
        public int DurationMinutes { get; set; }
        public string StatusText { get; set; }
        public bool IsCurrent { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
