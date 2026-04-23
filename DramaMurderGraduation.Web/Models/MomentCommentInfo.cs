using System;

namespace DramaMurderGraduation.Web.Models
{
    public class MomentCommentInfo
    {
        public int Id { get; set; }
        public int MomentId { get; set; }
        public int UserId { get; set; }
        public int? ParentCommentId { get; set; }
        public int ReplyDepth { get; set; }
        public string DisplayName { get; set; }
        public string ReplyToDisplayName { get; set; }
        public string AvatarUrl { get; set; }
        public string Content { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
