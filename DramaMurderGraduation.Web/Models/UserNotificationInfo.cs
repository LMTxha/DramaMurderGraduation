using System;

namespace DramaMurderGraduation.Web.Models
{
    public class UserNotificationInfo
    {
        public string NotificationKey { get; set; }
        public string Category { get; set; }
        public string Title { get; set; }
        public string Content { get; set; }
        public string TargetUrl { get; set; }
        public bool IsRead { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
