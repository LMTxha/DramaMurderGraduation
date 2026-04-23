using System;

namespace DramaMurderGraduation.Web.Models
{
    public class BlockedUserInfo
    {
        public int BlockedUserId { get; set; }
        public string Username { get; set; }
        public string DisplayName { get; set; }
        public string AvatarUrl { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
