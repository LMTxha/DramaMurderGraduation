using System;

namespace DramaMurderGraduation.Web.Models
{
    public class FriendInfo
    {
        public int UserId { get; set; }
        public string Username { get; set; }
        public string DisplayName { get; set; }
        public string AvatarUrl { get; set; }
        public string FavoriteGenre { get; set; }
        public string ReputationLevel { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
