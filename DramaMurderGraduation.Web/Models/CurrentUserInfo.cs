namespace DramaMurderGraduation.Web.Models
{
    public class CurrentUserInfo
    {
        public int UserId { get; set; }
        public string Username { get; set; }
        public string DisplayName { get; set; }
        public string PublicUserCode { get; set; }
        public string Phone { get; set; }
        public string RoleCode { get; set; }
        public string ReviewStatus { get; set; }
        public decimal Balance { get; set; }

        public bool IsAdmin
        {
            get { return string.Equals(RoleCode, "Admin", System.StringComparison.OrdinalIgnoreCase); }
        }

        public bool IsDm
        {
            get
            {
                return string.Equals(RoleCode, "DM", System.StringComparison.OrdinalIgnoreCase)
                    || string.Equals(RoleCode, "Host", System.StringComparison.OrdinalIgnoreCase)
                    || string.Equals(RoleCode, "Director", System.StringComparison.OrdinalIgnoreCase);
            }
        }

        public bool CanManageGameRoom
        {
            get { return IsAdmin || IsDm; }
        }
    }
}
