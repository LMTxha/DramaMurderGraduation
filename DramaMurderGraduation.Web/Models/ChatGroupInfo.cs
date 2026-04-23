using System;

namespace DramaMurderGraduation.Web.Models
{
    public class ChatGroupInfo
    {
        public int GroupId { get; set; }
        public string Name { get; set; }
        public string AvatarUrl { get; set; }
        public string Announcement { get; set; }
        public int OwnerUserId { get; set; }
        public int MemberCount { get; set; }
        public string LastMessagePreview { get; set; }
        public DateTime? LastMessageAt { get; set; }
        public int UnreadCount { get; set; }
        public bool IsPinned { get; set; }
        public bool IsHidden { get; set; }
        public bool IsMuted { get; set; }
    }
}
