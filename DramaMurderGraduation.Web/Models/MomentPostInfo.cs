using System;

namespace DramaMurderGraduation.Web.Models
{
    public class MomentPostInfo
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string DisplayName { get; set; }
        public string AvatarUrl { get; set; }
        public string Content { get; set; }
        public string ImageUrl { get; set; }
        public string LocationText { get; set; }
        public string Visibility { get; set; }
        public int LikeCount { get; set; }
        public int CommentCount { get; set; }
        public bool IsLikedByCurrentUser { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
