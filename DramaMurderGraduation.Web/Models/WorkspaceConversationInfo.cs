using System;

namespace DramaMurderGraduation.Web.Models
{
    public class WorkspaceConversationInfo
    {
        public string ConversationKind { get; set; }
        public int ConversationId { get; set; }
        public string DisplayName { get; set; }
        public string AvatarUrl { get; set; }
        public string Subtitle { get; set; }
        public string LastMessagePreview { get; set; }
        public DateTime? LastMessageAt { get; set; }
        public int UnreadCount { get; set; }
        public bool IsPinned { get; set; }
        public bool IsHidden { get; set; }
        public bool IsMuted { get; set; }
        public int MemberCount { get; set; }
    }
}
