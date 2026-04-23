using System;

namespace DramaMurderGraduation.Web.Models
{
    public class ChallengeInfo
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string CoverImage { get; set; }
        public DateTime EndTime { get; set; }
        public string RewardSummary { get; set; }
        public string StatusTag { get; set; }
        public string RouteUrl { get; set; }
    }
}
