using System;

namespace DramaMurderGraduation.Web.Models
{
    public class AnnouncementInfo
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Summary { get; set; }
        public DateTime PublishDate { get; set; }
        public bool IsImportant { get; set; }
    }
}
