namespace DramaMurderGraduation.Web.Models
{
    public class PlayerProfileInfo
    {
        public int UserId { get; set; }
        public string DisplayName { get; set; }
        public string DisplayTitle { get; set; }
        public string Motto { get; set; }
        public string AvatarUrl { get; set; }
        public string FavoriteGenre { get; set; }
        public int JoinDays { get; set; }
        public int CompletedScripts { get; set; }
        public decimal WinRate { get; set; }
        public string ReputationLevel { get; set; }
    }
}
