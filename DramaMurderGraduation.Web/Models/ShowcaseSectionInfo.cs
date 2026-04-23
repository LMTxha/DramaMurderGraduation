using System.Collections.Generic;

namespace DramaMurderGraduation.Web.Models
{
    public class ShowcaseSectionInfo
    {
        public ShowcaseSectionInfo()
        {
            Entries = new List<ShowcaseEntryInfo>();
        }

        public int Id { get; set; }
        public string SectionTitle { get; set; }
        public string SectionSummary { get; set; }
        public string LayoutCode { get; set; }
        public IList<ShowcaseEntryInfo> Entries { get; }
    }
}
