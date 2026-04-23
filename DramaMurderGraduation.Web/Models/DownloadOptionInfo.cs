using System;

namespace DramaMurderGraduation.Web.Models
{
    public class DownloadOptionInfo
    {
        public int Id { get; set; }

        public string PlatformName { get; set; }

        public string PlatformCode { get; set; }

        public string IconText { get; set; }

        public string VersionText { get; set; }

        public string Summary { get; set; }

        public string DownloadUrl { get; set; }

        public DateTime ReleaseDate { get; set; }

        public int SortOrder { get; set; }
    }
}
