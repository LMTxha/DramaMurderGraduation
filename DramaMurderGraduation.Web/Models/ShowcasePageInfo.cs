using System.Collections.Generic;

namespace DramaMurderGraduation.Web.Models
{
    public class ShowcasePageInfo
    {
        public ShowcasePageInfo()
        {
            Stats = new List<ShowcaseStatInfo>();
            Sections = new List<ShowcaseSectionInfo>();
        }

        public int Id { get; set; }
        public string PageKey { get; set; }
        public string PageName { get; set; }
        public string Eyebrow { get; set; }
        public string HeroTitle { get; set; }
        public string HeroSummary { get; set; }
        public string HeroDescription { get; set; }
        public string BadgeText { get; set; }
        public string PrimaryActionText { get; set; }
        public string PrimaryActionUrl { get; set; }
        public string SecondaryActionText { get; set; }
        public string SecondaryActionUrl { get; set; }
        public IList<ShowcaseStatInfo> Stats { get; }
        public IList<ShowcaseSectionInfo> Sections { get; }
    }
}
