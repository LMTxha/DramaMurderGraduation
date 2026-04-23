using System;

namespace DramaMurderGraduation.Web.Models
{
    public class AdminReplyLogInfo
    {
        public int Id { get; set; }
        public string BusinessType { get; set; }
        public int BusinessId { get; set; }
        public int? AdminUserId { get; set; }
        public string AdminName { get; set; }
        public string ReplyContent { get; set; }
        public bool VisibleToUser { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
