namespace DramaMurderGraduation.Web.Models
{
    public class UserSettingsInfo
    {
        public int UserId { get; set; }
        public string Username { get; set; }
        public string DisplayName { get; set; }
        public string PublicUserCode { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string AvatarUrl { get; set; }
        public string FavoriteGenre { get; set; }
        public string Gender { get; set; }
        public string Region { get; set; }
        public string Signature { get; set; }
    }
}
