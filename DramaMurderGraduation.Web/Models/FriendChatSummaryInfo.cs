using System;

namespace DramaMurderGraduation.Web.Models
{
    public class FriendChatSummaryInfo
    {
        public int FriendUserId { get; set; }
        public string Username { get; set; }
        public string DisplayName { get; set; }
        public string AvatarUrl { get; set; }
        public string FavoriteGenre { get; set; }
        public string ReputationLevel { get; set; }
        public string LastMessagePreview { get; set; }
        public DateTime? LastMessageAt { get; set; }
        public int UnreadCount { get; set; }
        public bool IsPinned { get; set; }
        public bool IsHidden { get; set; }
    }
}
