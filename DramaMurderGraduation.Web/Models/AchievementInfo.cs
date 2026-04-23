using System;

namespace DramaMurderGraduation.Web.Models
{
    public class AchievementInfo
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string RarityTag { get; set; }
        public int ProgressValue { get; set; }
        public int ProgressTotal { get; set; }
        public DateTime? EarnedAt { get; set; }
    }
}
